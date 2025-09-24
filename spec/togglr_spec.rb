require 'spec_helper'

RSpec.describe Togglr do
  it 'has a version number' do
    expect(Togglr::VERSION).not_to be nil
  end
end

RSpec.describe Togglr::RequestContext do
  let(:context) { Togglr::RequestContext.new }

  it 'supports chaining methods' do
    context
      .with_user_id('user123')
      .with_country('US')
      .with_device_type('mobile')
      .with_os('iOS')

    expect(context[Togglr::RequestContext::ATTR_USER_ID]).to eq('user123')
    expect(context[Togglr::RequestContext::ATTR_COUNTRY_CODE]).to eq('US')
    expect(context[Togglr::RequestContext::ATTR_DEVICE_TYPE]).to eq('mobile')
    expect(context[Togglr::RequestContext::ATTR_OS]).to eq('iOS')
  end

  it 'supports custom attributes' do
    context.set('custom_key', 'custom_value')
    expect(context['custom_key']).to eq('custom_value')
  end

  it 'converts to hash' do
    context.with_user_id('user123').with_country('US')
    hash = context.to_h
    expect(hash).to be_a(Hash)
    expect(hash[Togglr::RequestContext::ATTR_USER_ID]).to eq('user123')
  end
end

RSpec.describe Togglr::Config do
  it 'creates default configuration' do
    config = Togglr::Config.default('test-api-key')
    
    expect(config.api_key).to eq('test-api-key')
    expect(config.base_url).to eq('http://localhost:8090')
    expect(config.timeout).to eq(0.8)
    expect(config.retries).to eq(2)
    expect(config.cache_enabled).to be false
  end

  it 'allows configuration changes' do
    config = Togglr::Config.default('test-api-key')
    config.base_url = 'https://api.example.com'
    config.timeout = 2.0
    config.retries = 5
    config.cache_enabled = true
    config.cache_size = 1000
    config.cache_ttl = 30

    expect(config.base_url).to eq('https://api.example.com')
    expect(config.timeout).to eq(2.0)
    expect(config.retries).to eq(5)
    expect(config.cache_enabled).to be true
    expect(config.cache_size).to eq(1000)
    expect(config.cache_ttl).to eq(30)
  end
end

RSpec.describe Togglr::Cache do
  let(:cache) { Togglr::Cache.new(2, 0.1) } # 2 items, 0.1 second TTL

  it 'stores and retrieves values' do
    cache.set('key1', 'value1', true, true)
    entry = cache.get('key1')
    
    expect(entry).not_to be_nil
    expect(entry.value).to eq('value1')
    expect(entry.enabled).to be true
    expect(entry.found).to be true
  end

  it 'handles expiration' do
    cache.set('key1', 'value1', true, true)
    sleep(0.15) # Wait for expiration
    entry = cache.get('key1')
    
    expect(entry).to be_nil
  end

  it 'handles LRU eviction' do
    cache.set('key1', 'value1', true, true)
    cache.set('key2', 'value2', true, true)
    cache.set('key3', 'value3', true, true) # This should evict key1
    
    expect(cache.get('key1')).to be_nil
    expect(cache.get('key2')).not_to be_nil
    expect(cache.get('key3')).not_to be_nil
  end
end

