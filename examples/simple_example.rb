#!/usr/bin/env ruby

require_relative '../lib/togglr'

# Create client with default configuration
client = Togglr::Client.new_with_defaults('42b6f8f1-630c-400c-97bd-a3454a07f700',
                                          Togglr::Options.with_base_url('http://localhost:8090'),
                                          Togglr::Options.with_insecure,
                                          Togglr::Options.with_timeout(1.0),
                                          Togglr::Options.with_cache(1000, 10),
                                          Togglr::Options.with_retries(3)) do |config|
  # Additional configuration can be set in the block
  config.logger = Togglr::NoOpLogger.new
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
    client.report_error(
      feature_key,
      'timeout',
      'Service did not respond in 5s',
      { service: 'payment-gateway', timeout_ms: 5000 }
    )
    puts 'Error reported successfully - queued for processing'
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

  # Track events for analytics
  # Track impression event (recommended for each evaluation)
  impression_context = Togglr::RequestContext.new
                                      .with_user_id('user123')
                                      .with_country('US')
                                      .with_device_type('mobile')

  impression_event = Togglr::TrackEvent.new('A', Togglr::TrackEvent::SUCCESS)
                                      .with_request_context(impression_context)
                                      .with_dedup_key('impression-user123-new_ui')

  begin
    client.track_event(feature_key, impression_event)
    puts 'Impression event tracked successfully'
  rescue StandardError => e
    puts "Error tracking impression event: #{e.message}"
  end

  # Track conversion event with reward
  conversion_context = Togglr::RequestContext.new
                                           .with_user_id('user123')
                                           .set('conversion_type', 'purchase')
                                           .set('order_value', 99.99)

  conversion_event = Togglr::TrackEvent.new('A', Togglr::TrackEvent::SUCCESS)
                                      .with_reward(1.0)
                                      .with_request_context(conversion_context)
                                      .with_dedup_key('conversion-user123-new_ui')

  begin
    client.track_event(feature_key, conversion_event)
    puts 'Conversion event tracked successfully'
  rescue StandardError => e
    puts "Error tracking conversion event: #{e.message}"
  end

  # Track error event
  error_context = Togglr::RequestContext.new
                                      .with_user_id('user123')
                                      .set('error_type', 'timeout')
                                      .set('error_message', 'Service did not respond in 5s')

  error_event = Togglr::TrackEvent.new('B', Togglr::TrackEvent::ERROR)
                                 .with_request_context(error_context)
                                 .with_dedup_key('error-user123-new_ui')

  begin
    client.track_event(feature_key, error_event)
    puts 'Error event tracked successfully'
  rescue StandardError => e
    puts "Error tracking error event: #{e.message}"
  end
rescue StandardError => e
  puts "Error: #{e.message}"
ensure
  client.close
end
