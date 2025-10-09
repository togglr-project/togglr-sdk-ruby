#!/usr/bin/env ruby

require_relative '../lib/togglr'

# Example of using TLS certificates for secure connection
client = Togglr::Client.new_with_defaults('your-api-key-here',
                                          Togglr::Options.with_base_url('https://your-server.com'),
                                          # Use client certificate and key for mutual TLS authentication
                                          Togglr::Options.with_client_cert_and_key('/path/to/client.crt', '/path/to/client.key'),
                                          # Use custom CA certificate for server verification
                                          Togglr::Options.with_ca_cert('/path/to/ca.crt'),
                                          Togglr::Options.with_timeout(5.0),
                                          Togglr::Options.with_retries(3)) do |config|
  config.logger = Togglr::NoOpLogger.new
end

begin
  # Build request context
  context = Togglr::RequestContext.new
                                  .with_user_id('user123')
                                  .with_country('US')
                                  .with_user_email('user@example.com')
                                  .with_device_type('desktop')
                                  .set('department', 'engineering')

  feature_key = 'secure_feature'

  # Evaluate feature with TLS authentication
  puts '=== TLS Secured Feature Evaluation ==='
  value, enabled, found = client.evaluate(feature_key, context)
  if found
    puts "Feature #{feature_key}: enabled=#{enabled}, value=#{value}"
  else
    puts "Feature #{feature_key} not found"
  end

  # Health check with TLS
  puts "\n=== TLS Secured Health Check ==="
  health = client.health_check
  puts "System health: #{health}"

  # Report error with TLS
  puts "\n=== TLS Secured Error Reporting ==="
  begin
    client.report_error(
      feature_key,
      'tls_error',
      'TLS connection issue',
      { protocol: 'TLS 1.3', cipher: 'AES-256-GCM' }
    )
    puts 'Error reported successfully via TLS'
  rescue StandardError => e
    puts "Failed to report error: #{e.message}"
  end

rescue StandardError => e
  puts "TLS Error: #{e.message}"
  puts "Backtrace: #{e.backtrace.first(5).join("\n")}"
ensure
  client.close
  puts "\nTLS client closed"
end
