require_relative 'lib/togglr/version'

Gem::Specification.new do |spec|
  spec.name          = 'togglr-sdk'
  spec.version       = Togglr::VERSION
  spec.authors       = ['Roman']
  spec.email         = ['roman@example.com']

  spec.summary       = 'Ruby SDK for Togglr feature flag management system'
  spec.description   = 'A Ruby SDK for working with Togglr - feature flag management system'
  spec.homepage      = 'https://github.com/rom8726/togglr-sdk-ruby'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.0.0'

  spec.files = Dir.glob('{lib,spec}/**/*') + %w[README.md LICENSE Gemfile]
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.7'
  spec.add_dependency 'lru_redux', '~> 1.1'
  spec.add_dependency 'retries', '~> 0.0.5'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
