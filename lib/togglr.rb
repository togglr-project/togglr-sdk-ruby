require_relative 'togglr/version'
require_relative 'togglr/config'
require_relative 'togglr/client'
require_relative 'togglr/request_context'
require_relative 'togglr/track_event'
require_relative 'togglr/errors'
require_relative 'togglr/cache'
require_relative 'togglr/logger'
require_relative 'togglr/metrics'
require_relative 'togglr/models'
require_relative 'togglr/options'

module Togglr
  class Error < StandardError; end
end
