require 'json'
require 'retries'
require 'digest'

# Load generated client files through main entry point
require_relative '../togglr-client'

module Togglr
  class Client
    def initialize(config)
      @config = config
      @cache = config.cache_enabled ? Cache.new(config.cache_size, config.cache_ttl) : nil

      # Initialize generated API client
      api_config = TogglrClient::Configuration.new
      api_config.api_key['Authorization'] = config.api_key
      api_config.ssl_verify = !config.insecure

      # Configure TLS certificates if provided
      if config.client_cert && config.client_key
        api_config.ssl_client_cert = config.client_cert
        api_config.ssl_client_key = config.client_key
      end

      if config.ca_cert
        api_config.ssl_ca_file = config.ca_cert
      end

      @api_client = TogglrClient::DefaultApi.new(TogglrClient::ApiClient.new(api_config))
    end

    def self.new_with_defaults(api_key, *options)
      config = Config.default(api_key)

      # Apply options
      options.each do |option|
        option.call(config) if option.respond_to?(:call)
      end

      yield(config) if block_given?
      new(config)
    end

    def evaluate(feature_key, context)
      evaluate_with_context(feature_key, context, @config.api_key)
    end

    def evaluate_with_context(feature_key, context, project_api_key)
      start_time = Time.now
      @config.metrics.inc_evaluate_request

      # Check cache first
      cache_key = build_cache_key(feature_key, context)
      if @cache
        entry = @cache.get(cache_key)
        if entry
          @config.metrics.inc_cache_hit
          @config.logger.debug('cache hit', feature_key: feature_key, cache_key: cache_key)
          return [entry.value, entry.enabled, entry.found]
        end
        @config.metrics.inc_cache_miss
      end

      # Make API call with retries
      result = with_retries(max_tries: @config.retries + 1) do
        evaluate_single(feature_key, context, project_api_key)
      end

      # Record metrics
      latency = Time.now - start_time
      @config.metrics.observe_evaluate_latency(latency)

      value, enabled, found, error = result
      if error
        @config.metrics.inc_evaluate_error(error.class.name)
        raise error
      end

      # Cache result if successful
      @cache&.set(cache_key, value, enabled, found)

      [value, enabled, found]
    end

    def is_enabled(feature_key, context)
      _, enabled, found = evaluate(feature_key, context)
      raise FeatureNotFoundError, "Feature #{feature_key} not found" unless found

      enabled
    end

    def is_enabled_or_default(feature_key, context, default_value)
      is_enabled(feature_key, context)
    rescue StandardError => e
      @config.logger.warn('evaluation failed, using default',
                          feature_key: feature_key, error: e.message, default: default_value)
      default_value
    end

    def health_check
      @api_client.sdk_v1_health_get
    rescue TogglrClient::ApiError => e
      raise "Health check failed with status #{e.code}: #{e.message}"
    end

    # Report an error for a feature
    def report_error(feature_key, error_type, error_message, context = {})
      error = report_error_with_retries(feature_key, error_type, error_message, context)
      raise error if error

      nil # Success - error queued for processing
    end

    # Get feature health information
    def get_feature_health(feature_key)
      health, error = get_feature_health_with_retries(feature_key)
      raise error if error

      health
    end

    # Check if feature is healthy (simple boolean check)
    def is_feature_healthy(feature_key)
      health = get_feature_health(feature_key)
      health.healthy?
    end

    def close
      @cache&.clear
    end

    private

    def build_cache_key(feature_key, context)
      context_hash = Digest::SHA256.hexdigest(context.to_h.to_json)[0, 16]
      "#{feature_key}:#{context_hash}"
    end

    def evaluate_single(feature_key, context, project_api_key)
      # Use the correct API method with request body as hash
      response = @api_client.sdk_v1_features_feature_key_evaluate_post(feature_key, context.to_h)

      [response.value, response.enabled, true, nil]
    rescue TogglrClient::ApiError => e
      case e.code
      when 404
        ['', false, false, nil] # Feature not found, not an error
      when 401
        [nil, nil, nil, UnauthorizedError.new('Authentication required')]
      when 400
        [nil, nil, nil, BadRequestError.new('Bad request')]
      when 500
        [nil, nil, nil, InternalServerError.new('Internal server error')]
      else
        [nil, nil, nil, APIError.new(e.code.to_s, e.message, e.code)]
      end
    end

    def with_retries(max_tries:)
      retries = 0
      begin
        yield
      rescue StandardError => e
        retries += 1
        raise e unless retries < max_tries && should_retry?(e)

        delay = calculate_backoff_delay(retries)
        @config.logger.debug('retrying after delay', attempt: retries, delay: delay)
        sleep(delay)
        retry
      end
    end

    def should_retry?(error)
      case error
      when NetworkError, TimeoutError, InternalServerError
        true
      else
        false
      end
    end

    def calculate_backoff_delay(attempt)
      delay = @config.backoff.base_delay
      (attempt - 1).times do
        delay = [delay * @config.backoff.factor, @config.backoff.max_delay].min
      end
      delay
    end

    def report_error_with_retries(feature_key, error_type, error_message, context)
      with_retries(max_tries: @config.retries + 1) do
        error = report_error_single(feature_key, error_type, error_message, context)
        raise error if error

        nil # Success
      end
    end

    def report_error_single(feature_key, error_type, error_message, context)
      error_report = TogglrClient::FeatureErrorReport.new(
        error_type: error_type,
        error_message: error_message,
        context: context
      )

      @api_client.report_feature_error(feature_key, error_report)
      # Success - error queued for processing
      nil
    rescue TogglrClient::ApiError => e
      case e.code
      when 401
        UnauthorizedError.new('Authentication required')
      when 400
        BadRequestError.new('Bad request')
      when 404
        FeatureNotFoundError.new("Feature #{feature_key} not found")
      when 500
        InternalServerError.new('Internal server error')
      else
        APIError.new(e.code.to_s, e.message, e.code)
      end
    end

    def get_feature_health_with_retries(feature_key)
      with_retries(max_tries: @config.retries + 1) do
        get_feature_health_single(feature_key)
      end
    end

    def get_feature_health_single(feature_key)
      api_health = @api_client.get_feature_health(feature_key)
      health = convert_feature_health(api_health)
      [health, nil] # health, error
    rescue TogglrClient::ApiError => e
      case e.code
      when 401
        [nil, UnauthorizedError.new('Authentication required')]
      when 400
        [nil, BadRequestError.new('Bad request')]
      when 404
        [nil, FeatureNotFoundError.new("Feature #{feature_key} not found")]
      when 500
        [nil, InternalServerError.new('Internal server error')]
      else
        [nil, APIError.new(e.code.to_s, e.message, e.code)]
      end
    end

    private

    def convert_feature_health(api_health)
      FeatureHealth.new({
        'feature_key' => api_health.feature_key,
        'environment_key' => api_health.environment_key,
        'enabled' => api_health.enabled,
        'auto_disabled' => api_health.auto_disabled,
        'error_rate' => api_health.error_rate,
        'threshold' => api_health.threshold,
        'last_error_at' => api_health.last_error_at
      })
    end
  end
end
