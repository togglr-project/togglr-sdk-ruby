module Togglr
  # Options module for configuring Togglr client
  module Options
    # Set the base URL for the API
    def self.with_base_url(url)
      ->(config) { config.base_url = url }
    end

    # Set insecure mode (skip SSL verification)
    def self.with_insecure
      ->(config) { config.insecure = true }
    end

    # Set request timeout
    def self.with_timeout(timeout)
      ->(config) { config.timeout = timeout }
    end

    # Set number of retries
    def self.with_retries(retries)
      ->(config) { config.retries = retries }
    end

    # Set backoff configuration
    def self.with_backoff(base_delay: nil, max_delay: nil, factor: nil)
      lambda do |config|
        config.backoff.base_delay = base_delay if base_delay
        config.backoff.max_delay = max_delay if max_delay
        config.backoff.factor = factor if factor
      end
    end

    # Enable caching
    def self.with_cache(size, ttl)
      lambda do |config|
        config.cache_enabled = true
        config.cache_size = size
        config.cache_ttl = ttl
      end
    end

    # Set logger
    def self.with_logger(logger)
      ->(config) { config.logger = logger }
    end

    # Set metrics collector
    def self.with_metrics(metrics)
      ->(config) { config.metrics = metrics }
    end

    # Set maximum connections
    def self.with_max_connections(max_connections)
      ->(config) { config.max_connections = max_connections }
    end
  end
end
