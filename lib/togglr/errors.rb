module Togglr
  class Error < StandardError; end

  class UnauthorizedError < Error; end
  class ForbiddenError < Error; end
  class NotFoundError < Error; end
  class TooManyRequestsError < Error; end
  class NetworkError < Error; end
  class TimeoutError < Error; end
  class InvalidConfigError < Error; end
  class FeatureNotFoundError < Error; end
  class BadRequestError < Error; end
  class InternalServerError < Error; end

  class APIError < Error
    attr_reader :code, :message, :status_code

    def initialize(code, message, status_code)
      @code = code
      @message = message
      @status_code = status_code
      super(message)
    end
  end
end
