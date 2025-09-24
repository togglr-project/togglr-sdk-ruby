module Togglr
  class Metrics
    def inc_evaluate_request; end
    def inc_evaluate_error(code); end
    def observe_evaluate_latency(duration); end
    def inc_cache_hit; end
    def inc_cache_miss; end
  end

  class NoOpMetrics < Metrics
    # No-op implementation
  end

  class StdoutMetrics < Metrics
    def initialize
      @counters = Hash.new(0)
    end

    def inc_evaluate_request
      @counters[:evaluate_requests] += 1
    end

    def inc_evaluate_error(code)
      @counters[:"evaluate_errors_#{code}"] += 1
    end

    def observe_evaluate_latency(duration)
      @counters[:total_latency] += duration
      @counters[:latency_count] += 1
    end

    def inc_cache_hit
      @counters[:cache_hits] += 1
    end

    def inc_cache_miss
      @counters[:cache_misses] += 1
    end

    def stats
      @counters.dup
    end
  end
end
