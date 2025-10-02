# Togglr Ruby SDK

Ruby SDK for working with Togglr - feature flag management system.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'togglr-sdk'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install togglr-sdk
```

## Quick Start

```ruby
require 'togglr'

# Create client with default configuration
client = Togglr::Client.new_with_defaults('your-api-key-here') do |config|
  config.base_url = 'http://localhost:8090'
  config.timeout = 1.0
  config.cache_enabled = true
  config.cache_size = 1000
  config.cache_ttl = 10
end

# Create request context
context = Togglr::RequestContext.new
  .with_user_id('user123')
  .with_country('US')
  .with_device_type('mobile')

# Evaluate feature flag
value, enabled, found = client.evaluate('new_ui', context)

if found
  puts "Feature enabled: #{enabled}, value: #{value}"
end

client.close
```

## Configuration

### Creating a client

```ruby
# With default settings
client = Togglr::Client.new_with_defaults('api-key')

# With custom configuration
config = Togglr::Config.default('api-key')
config.base_url = 'https://api.togglr.com'
config.timeout = 2.0
config.retries = 3

client = Togglr::Client.new(config)
```

### Configuration options

```ruby
client = Togglr::Client.new_with_defaults('api-key') do |config|
  config.base_url = 'https://api.togglr.com'
  config.timeout = 2.0
  config.retries = 3
  config.cache_enabled = true
  config.cache_size = 1000
  config.cache_ttl = 10
  config.use_circuit_breaker = true
  config.max_connections = 100
end
```

## Usage

### Creating request context

```ruby
context = Togglr::RequestContext.new
  .with_user_id('user123')
  .with_user_email('user@example.com')
  .with_country('US')
  .with_device_type('mobile')
  .with_os('iOS')
  .with_os_version('15.0')
  .with_browser('Safari')
  .with_language('en-US')
```

### Evaluating feature flags

```ruby
# Full evaluation
value, enabled, found = client.evaluate('feature_key', context)

# Simple enabled check
is_enabled = client.is_enabled('feature_key', context)

# With default value
default_value = client.is_enabled_or_default('feature_key', context, false)
```

### Working with context

```ruby
# Custom attributes
context.set('custom_key', 'custom_value')

# Convert to hash
hash = context.to_h
```

## Error Reporting and Auto-Disable

The SDK supports reporting errors for features, which can trigger automatic disabling based on error rates:

```ruby
# Report an error for a feature
health, is_pending = client.report_error(
  'feature_key',
  'timeout',
  'Service did not respond in 5s',
  { service: 'payment-gateway', timeout_ms: 5000 }
)

puts "Error reported: pending=#{is_pending}"
puts "Feature health: enabled=#{health.enabled}, auto_disabled=#{health.auto_disabled}"
```

### Error Types

Supported error types:
- `timeout` - Service timeout
- `validation` - Data validation error
- `service_unavailable` - External service unavailable
- `rate_limit` - Rate limit exceeded
- `network` - Network connectivity issue
- `internal` - Internal application error

### Context Data

You can provide additional context with error reports:

```ruby
context = {
  service: 'payment-gateway',
  timeout_ms: 5000,
  user_id: 'user123',
  region: 'us-east-1'
}

client.report_error('feature_key', 'timeout', 'Service timeout', context)
```

## Feature Health Monitoring

Monitor the health status of features:

```ruby
# Get detailed health information
health = client.get_feature_health('feature_key')

puts "Feature: #{health.feature_key}"
puts "Enabled: #{health.enabled}"
puts "Auto Disabled: #{health.auto_disabled}"
puts "Error Rate: #{health.error_rate}"
puts "Threshold: #{health.threshold}"
puts "Last Error At: #{health.last_error_at}"

# Simple health check
is_healthy = client.is_feature_healthy('feature_key')
puts "Feature is healthy: #{is_healthy}"
```

### FeatureHealth Model

The `FeatureHealth` model provides:

- `feature_key` - The feature identifier
- `environment_key` - The environment identifier
- `enabled` - Whether the feature is enabled
- `auto_disabled` - Whether the feature was auto-disabled due to errors
- `error_rate` - Current error rate (0.0 to 1.0)
- `threshold` - Error rate threshold for auto-disable
- `last_error_at` - Timestamp of the last error
- `healthy?` - Boolean method to check if feature is healthy

## Caching

The SDK supports optional caching of evaluation results using LRU cache:

```ruby
client = Togglr::Client.new_with_defaults('api-key') do |config|
  config.cache_enabled = true
  config.cache_size = 1000  # number of items
  config.cache_ttl = 10     # TTL in seconds
end
```

## Retries

The SDK automatically retries requests on temporary errors:

```ruby
client = Togglr::Client.new_with_defaults('api-key') do |config|
  config.retries = 3
  config.backoff.base_delay = 0.1
  config.backoff.max_delay = 2.0
  config.backoff.factor = 2.0
end
```

## Logging and Metrics

```ruby
# Custom logger
logger = Togglr::StdoutLogger.new
client = Togglr::Client.new_with_defaults('api-key') do |config|
  config.logger = logger
end

# Custom metrics
metrics = Togglr::StdoutMetrics.new
client = Togglr::Client.new_with_defaults('api-key') do |config|
  config.metrics = metrics
end
```

## Error Handling

```ruby
begin
  value, enabled, found = client.evaluate('feature_key', context)
rescue Togglr::UnauthorizedError
  # Handle authorization error
rescue Togglr::BadRequestError
  # Handle bad request
rescue Togglr::NetworkError
  # Handle network error
rescue => e
  # Handle other errors
  puts "Error: #{e.message}"
end
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bundle exec console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Testing

```bash
# Run tests
bundle exec rspec

# Run with coverage
bundle exec rspec

# Run RuboCop
bundle exec rubocop

# Run all checks
bundle exec rake check
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rom8726/togglr-sdk-ruby.
