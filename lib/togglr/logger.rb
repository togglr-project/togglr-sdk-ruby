module Togglr
  class Logger
    def debug(msg, **kwargs); end
    def info(msg, **kwargs); end
    def warn(msg, **kwargs); end
    def error(msg, **kwargs); end
  end

  class NoOpLogger < Logger
    # No-op implementation
  end

  class StdoutLogger < Logger
    def debug(msg, **kwargs)
      puts "[DEBUG] #{msg} #{format_kwargs(kwargs)}"
    end

    def info(msg, **kwargs)
      puts "[INFO] #{msg} #{format_kwargs(kwargs)}"
    end

    def warn(msg, **kwargs)
      puts "[WARN] #{msg} #{format_kwargs(kwargs)}"
    end

    def error(msg, **kwargs)
      puts "[ERROR] #{msg} #{format_kwargs(kwargs)}"
    end

    private

    def format_kwargs(kwargs)
      return '' if kwargs.empty?

      kwargs.map { |k, v| "#{k}=#{v}" }.join(' ')
    end
  end
end
