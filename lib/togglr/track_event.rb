module Togglr
  class TrackEvent
    # Event types
    SUCCESS = 'success'.freeze
    FAILURE = 'failure'.freeze
    ERROR = 'error'.freeze

    attr_reader :variant_key, :event_type, :reward, :context, :created_at, :dedup_key

    def initialize(variant_key, event_type, options = {})
      @variant_key = variant_key
      @event_type = event_type
      @reward = options[:reward]
      @context = options[:context] || RequestContext.new
      @created_at = options[:created_at]
      @dedup_key = options[:dedup_key]
    end

    def self.new(variant_key, event_type, options = {})
      instance = allocate
      instance.send(:initialize, variant_key, event_type, options)
      instance
    end

    def with_reward(reward)
      @reward = reward
      self
    end

    def with_context(key, value)
      @context.set(key, value)
      self
    end

    def with_contexts(contexts)
      contexts.each { |key, value| @context.set(key, value) }
      self
    end

    def with_request_context(context)
      @context = context
      self
    end

    def with_created_at(created_at)
      @created_at = created_at
      self
    end

    def with_dedup_key(dedup_key)
      @dedup_key = dedup_key
      self
    end

    def to_h
      result = {
        'variant_key' => @variant_key,
        'event_type' => @event_type,
        'context' => @context.to_h
      }

      result['reward'] = @reward if @reward
      result['created_at'] = @created_at.iso8601 if @created_at
      result['dedup_key'] = @dedup_key if @dedup_key

      result
    end

    def to_s
      "#<Togglr::TrackEvent variant_key=#{@variant_key.inspect} " \
      "event_type=#{@event_type.inspect} reward=#{@reward.inspect} " \
      "context=#{@context.inspect} created_at=#{@created_at.inspect} " \
      "dedup_key=#{@dedup_key.inspect}>"
    end

    def inspect
      to_s
    end
  end
end
