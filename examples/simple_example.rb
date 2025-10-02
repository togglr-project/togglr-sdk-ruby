#!/usr/bin/env ruby

require_relative '../lib/togglr'

# Create client with default configuration
client = Togglr::Client.new_with_defaults('your-api-key-here') do |config|
  config.base_url = 'http://localhost:8090'
  config.timeout = 1.0
  config.cache_enabled = true
  config.cache_size = 1000
  config.cache_ttl = 10
  config.retries = 3
end

begin
  # Build request context using builder methods
  context = Togglr::RequestContext.new
                                  .with_user_id('user123')
                                  .with_country('US')
                                  .with_user_email('user@example.com')
                                  .with_device_type('mobile')
                                  .with_os('iOS')
                                  .with_os_version('15.0')

  # Evaluate a feature
  feature_key = 'new_ui'
  value, enabled, found = client.evaluate(feature_key, context)

  if found
    puts "Feature #{feature_key}: enabled=#{enabled}, value=#{value}"
  else
    puts "Feature #{feature_key} not found"
  end

  # Use convenience method for boolean flags
  is_enabled = client.is_enabled(feature_key, context)
  puts "Feature #{feature_key} is enabled: #{is_enabled}"

  # Use default value fallback
  default_enabled = client.is_enabled_or_default(feature_key, context, false)
  puts "Feature #{feature_key} with default fallback: #{default_enabled}"

  # Health check
  health = client.health_check
  puts "Health check passed: #{health}"

  # Report an error for a feature
  begin
    health, is_pending = client.report_error(
      feature_key,
      'timeout',
      'Service did not respond in 5s',
      { service: 'payment-gateway', timeout_ms: 5000 }
    )
    puts "Error reported for #{feature_key}: pending=#{is_pending}"
    puts "Feature health: enabled=#{health.enabled}, auto_disabled=#{health.auto_disabled}"
  rescue StandardError => e
    puts "Failed to report error: #{e.message}"
  end

  # Get feature health
  begin
    health = client.get_feature_health(feature_key)
    puts "Feature health: enabled=#{health.enabled}, auto_disabled=#{health.auto_disabled}"
    puts "Error rate: #{health.error_rate}, threshold: #{health.threshold}"
  rescue StandardError => e
    puts "Failed to get feature health: #{e.message}"
  end

  # Simple health check
  begin
    is_healthy = client.is_feature_healthy(feature_key)
    puts "Feature #{feature_key} is healthy: #{is_healthy}"
  rescue StandardError => e
    puts "Failed to check feature health: #{e.message}"
  end
rescue StandardError => e
  puts "Error: #{e.message}"
ensure
  client.close
end
