module Togglr
  # Model for error reporting
  class ErrorReport
    attr_accessor :error_type, :error_message, :context

    def initialize(error_type, error_message, context = {})
      @error_type = error_type
      @error_message = error_message
      @context = context
    end

    def to_h
      {
        error_type: @error_type,
        error_message: @error_message,
        context: @context
      }
    end

    def self.new_with_context(error_type, error_message, context = {})
      new(error_type, error_message, context)
    end
  end

  # Model for feature health information
  class FeatureHealth
    attr_accessor :feature_key, :environment_key, :enabled, :auto_disabled, 
                  :error_rate, :threshold, :last_error_at

    def initialize(data = {})
      @feature_key = data['feature_key']
      @environment_key = data['environment_key']
      @enabled = data['enabled']
      @auto_disabled = data['auto_disabled']
      @error_rate = data['error_rate']
      @threshold = data['threshold']
      @last_error_at = data['last_error_at']
    end

    def healthy?
      !@auto_disabled && @enabled
    end

    def to_h
      {
        feature_key: @feature_key,
        environment_key: @environment_key,
        enabled: @enabled,
        auto_disabled: @auto_disabled,
        error_rate: @error_rate,
        threshold: @threshold,
        last_error_at: @last_error_at
      }
    end
  end
end
