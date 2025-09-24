module Togglr
  class Config
    attr_accessor :base_url, :api_key, :timeout, :retries, :backoff,
                  :cache_enabled, :cache_size, :cache_ttl, :use_circuit_breaker,
                  :logger, :metrics, :max_connections

    def initialize(api_key)
      @base_url = 'http://localhost:8090'
      @api_key = api_key
      @timeout = 0.8 # seconds
      @retries = 2
      @backoff = Backoff.new
      @cache_enabled = false
      @cache_size = 100
      @cache_ttl = 5 # seconds
      @use_circuit_breaker = false
      @logger = NoOpLogger.new
      @metrics = NoOpMetrics.new
      @max_connections = 100
    end

    def self.default(api_key)
      new(api_key)
    end

    class Backoff
      attr_accessor :base_delay, :max_delay, :factor

      def initialize
        @base_delay = 0.1 # seconds
        @max_delay = 2.0 # seconds
        @factor = 2.0
      end
    end
  end
end
