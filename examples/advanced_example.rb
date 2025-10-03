#!/usr/bin/env ruby

require_relative '../lib/togglr'

# Create client with advanced configuration
client = Togglr::Client.new_with_defaults('your-api-key-here') do |config|
  config.base_url = 'http://localhost:8090'
  config.timeout = 2.0
  config.cache_enabled = true
  config.cache_size = 2000
  config.cache_ttl = 30
  config.retries = 5
  
  # Configure backoff
  config.backoff.base_delay = 0.2
  config.backoff.max_delay = 5.0
  config.backoff.factor = 1.5
end

begin
  # Build request context
  context = Togglr::RequestContext.new
                                  .with_user_id('user456')
                                  .with_country('CA')
                                  .with_user_email('user@example.ca')
                                  .with_device_type('desktop')
                                  .with_os('macOS')
                                  .with_os_version('12.0')
                                  .with_custom_attribute('subscription', 'premium')
                                  .with_custom_attribute('region', 'north')

  feature_key = 'advanced_analytics'

  # Evaluate feature
  puts "=== Feature Evaluation ==="
  value, enabled, found = client.evaluate(feature_key, context)
  if found
    puts "Feature #{feature_key}: enabled=#{enabled}, value=#{value}"
  else
    puts "Feature #{feature_key} not found"
  end

  # Test different error types
  puts "\n=== Error Reporting Examples ==="
  
  error_types = [
    ['timeout', 'Service timeout after 10s', { timeout_ms: 10000, service: 'analytics' }],
    ['validation', 'Invalid user data provided', { field: 'email', value: 'invalid-email' }],
    ['service_unavailable', 'External service is down', { service: 'database', region: 'us-east-1' }],
    ['rate_limit', 'Too many requests', { limit: 100, current: 150, window: '1m' }]
  ]

  error_types.each do |error_type, message, context_data|
    begin
      client.report_error(feature_key, error_type, message, context_data)
      puts "Reported #{error_type} error successfully - queued for processing"
    rescue StandardError => e
      puts "Failed to report #{error_type} error: #{e.message}"
    end
    puts
  end

  # Feature health monitoring
  puts "=== Feature Health Monitoring ==="
  
  begin
    health = client.get_feature_health(feature_key)
    puts "Feature: #{health.feature_key}"
    puts "Environment: #{health.environment_key}"
    puts "Enabled: #{health.enabled}"
    puts "Auto Disabled: #{health.auto_disabled}"
    puts "Error Rate: #{health.error_rate}"
    puts "Threshold: #{health.threshold}"
    puts "Last Error At: #{health.last_error_at}"
    puts "Is Healthy: #{health.healthy?}"
  rescue StandardError => e
    puts "Failed to get feature health: #{e.message}"
  end

  # Simple health check
  puts "\n=== Simple Health Check ==="
  begin
    is_healthy = client.is_feature_healthy(feature_key)
    puts "Feature #{feature_key} is healthy: #{is_healthy}"
  rescue StandardError => e
    puts "Health check failed: #{e.message}"
  end

  # Multiple features health check
  puts "\n=== Multiple Features Health Check ==="
  features = ['advanced_analytics', 'new_ui', 'beta_features', 'experimental_api']
  
  features.each do |feature|
    begin
      is_healthy = client.is_feature_healthy(feature)
      puts "Feature #{feature}: #{is_healthy ? 'healthy' : 'unhealthy'}"
    rescue StandardError => e
      puts "Feature #{feature}: error - #{e.message}"
    end
  end

  # Health check
  puts "\n=== System Health Check ==="
  health = client.health_check
  puts "System health: #{health}"

rescue StandardError => e
  puts "Error: #{e.message}"
  puts "Backtrace: #{e.backtrace.first(5).join("\n")}"
ensure
  client.close
  puts "\nClient closed"
end
