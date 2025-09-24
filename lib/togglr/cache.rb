require 'lru_redux'

module Togglr
  class Cache
    class Entry
      attr_reader :value, :enabled, :found, :expires_at

      def initialize(value, enabled, found, ttl)
        @value = value
        @enabled = enabled
        @found = found
        @expires_at = Time.now + ttl
      end

      def expired?
        Time.now > @expires_at
      end
    end

    def initialize(size, ttl)
      @cache = LruRedux::TTL::Cache.new(size, ttl)
    end

    def get(key)
      entry = @cache[key]
      return nil if entry.nil? || entry.expired?

      entry
    end

    def set(key, value, enabled, found)
      entry = Entry.new(value, enabled, found, @cache.ttl)
      @cache[key] = entry
    end

    def clear
      @cache.clear
    end

    def size
      @cache.size
    end
  end
end

