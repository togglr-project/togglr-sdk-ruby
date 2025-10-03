require 'faraday'
require 'json'
require 'retries'
require 'digest'

module Togglr
  class Client
    def initialize(config)
      @config = config
      @connection = build_connection
      @cache = config.cache_enabled ? Cache.new(config.cache_size, config.cache_ttl) : nil
    end

    def self.new_with_defaults(api_key)
      config = Config.default(api_key)
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
        make_api_call(feature_key, context, project_api_key)
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
      response = @connection.get('/sdk/v1/health')
      raise "Health check failed with status #{response.status}" unless response.success?

      JSON.parse(response.body)
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

    def build_connection
      Faraday.new(url: @config.base_url) do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
        conn.options.timeout = @config.timeout
        conn.options.open_timeout = @config.timeout
      end
    end

    def build_cache_key(feature_key, context)
      context_hash = Digest::SHA256.hexdigest(context.to_h.to_json)[0, 16]
      "#{feature_key}:#{context_hash}"
    end

    def make_api_call(feature_key, context, project_api_key)
      response = @connection.post("/sdk/v1/features/#{feature_key}/evaluate") do |req|
        req.headers['Authorization'] = project_api_key
        req.body = context.to_h
      end

      case response.status
      when 200
        data = response.body
        [data['value'], data['enabled'], true, nil]
      when 404
        ['', false, false, nil] # Feature not found, not an error
      when 401
        [nil, nil, nil, UnauthorizedError.new('Authentication required')]
      when 400
        [nil, nil, nil, BadRequestError.new('Bad request')]
      when 500
        [nil, nil, nil, InternalServerError.new('Internal server error')]
      else
        error_data = response.body
        error_code = error_data.dig('error', 'code') || 'unknown'
        error_message = error_data.dig('error', 'message') || 'Unknown error'
        [nil, nil, nil, APIError.new(error_code, error_message, response.status)]
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
      error_report = ErrorReport.new(error_type, error_message, context)
      
      response = @connection.post("/sdk/v1/features/#{feature_key}/report-error") do |req|
        req.headers['Authorization'] = @config.api_key
        req.body = error_report.to_h
      end

      case response.status
      when 202
        # 202 response means success - error queued for processing
        nil # Success, no error
      when 401
        UnauthorizedError.new('Authentication required')
      when 400
        BadRequestError.new('Bad request')
      when 404
        FeatureNotFoundError.new("Feature #{feature_key} not found")
      when 500
        InternalServerError.new('Internal server error')
      else
        error_data = response.body
        error_code = error_data.dig('error', 'code') || 'unknown'
        error_message = error_data.dig('error', 'message') || 'Unknown error'
        APIError.new(error_code, error_message, response.status)
      end
    end

    def get_feature_health_with_retries(feature_key)
      with_retries(max_tries: @config.retries + 1) do
        get_feature_health_single(feature_key)
      end
    end

    def get_feature_health_single(feature_key)
      response = @connection.get("/sdk/v1/features/#{feature_key}/health") do |req|
        req.headers['Authorization'] = @config.api_key
      end

      case response.status
      when 200
        data = response.body
        [FeatureHealth.new(data), nil] # health, error
      when 401
        [nil, UnauthorizedError.new('Authentication required')]
      when 400
        [nil, BadRequestError.new('Bad request')]
      when 404
        [nil, FeatureNotFoundError.new("Feature #{feature_key} not found")]
      when 500
        [nil, InternalServerError.new('Internal server error')]
      else
        error_data = response.body
        error_code = error_data.dig('error', 'code') || 'unknown'
        error_message = error_data.dig('error', 'message') || 'Unknown error'
        [nil, APIError.new(error_code, error_message, response.status)]
      end
    end
  end
end
