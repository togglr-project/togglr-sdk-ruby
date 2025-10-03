# TogglrClient::DefaultApi

All URIs are relative to *http://localhost:8090*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**get_feature_health**](DefaultApi.md#get_feature_health) | **GET** /sdk/v1/features/{feature_key}/health | Get health status of feature (including auto-disable state) |
| [**report_feature_error**](DefaultApi.md#report_feature_error) | **POST** /sdk/v1/features/{feature_key}/report-error | Report feature execution error (for auto-disable) |
| [**sdk_v1_features_feature_key_evaluate_post**](DefaultApi.md#sdk_v1_features_feature_key_evaluate_post) | **POST** /sdk/v1/features/{feature_key}/evaluate | Evaluate feature for given context |
| [**sdk_v1_health_get**](DefaultApi.md#sdk_v1_health_get) | **GET** /sdk/v1/health | Health check for SDK server |


## get_feature_health

> <FeatureHealth> get_feature_health(feature_key)

Get health status of feature (including auto-disable state)

### Examples

```ruby
require 'time'
require 'togglr-client'
# setup authorization
TogglrClient.configure do |config|
  # Configure API key authorization: ApiKeyAuth
  config.api_key['Authorization'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['Authorization'] = 'Bearer'
end

api_instance = TogglrClient::DefaultApi.new
feature_key = 'feature_key_example' # String | 

begin
  # Get health status of feature (including auto-disable state)
  result = api_instance.get_feature_health(feature_key)
  p result
rescue TogglrClient::ApiError => e
  puts "Error when calling DefaultApi->get_feature_health: #{e}"
end
```

#### Using the get_feature_health_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<FeatureHealth>, Integer, Hash)> get_feature_health_with_http_info(feature_key)

```ruby
begin
  # Get health status of feature (including auto-disable state)
  data, status_code, headers = api_instance.get_feature_health_with_http_info(feature_key)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <FeatureHealth>
rescue TogglrClient::ApiError => e
  puts "Error when calling DefaultApi->get_feature_health_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **feature_key** | **String** |  |  |

### Return type

[**FeatureHealth**](FeatureHealth.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## report_feature_error

> report_feature_error(feature_key, feature_error_report)

Report feature execution error (for auto-disable)

### Examples

```ruby
require 'time'
require 'togglr-client'
# setup authorization
TogglrClient.configure do |config|
  # Configure API key authorization: ApiKeyAuth
  config.api_key['Authorization'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['Authorization'] = 'Bearer'
end

api_instance = TogglrClient::DefaultApi.new
feature_key = 'feature_key_example' # String | 
feature_error_report = TogglrClient::FeatureErrorReport.new({error_type: 'timeout', error_message: 'Service X did not respond in 5s'}) # FeatureErrorReport | 

begin
  # Report feature execution error (for auto-disable)
  api_instance.report_feature_error(feature_key, feature_error_report)
rescue TogglrClient::ApiError => e
  puts "Error when calling DefaultApi->report_feature_error: #{e}"
end
```

#### Using the report_feature_error_with_http_info variant

This returns an Array which contains the response data (`nil` in this case), status code and headers.

> <Array(nil, Integer, Hash)> report_feature_error_with_http_info(feature_key, feature_error_report)

```ruby
begin
  # Report feature execution error (for auto-disable)
  data, status_code, headers = api_instance.report_feature_error_with_http_info(feature_key, feature_error_report)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => nil
rescue TogglrClient::ApiError => e
  puts "Error when calling DefaultApi->report_feature_error_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **feature_key** | **String** |  |  |
| **feature_error_report** | [**FeatureErrorReport**](FeatureErrorReport.md) |  |  |

### Return type

nil (empty response body)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## sdk_v1_features_feature_key_evaluate_post

> <EvaluateResponse> sdk_v1_features_feature_key_evaluate_post(feature_key, request_body)

Evaluate feature for given context

Returns feature evaluation result for given project and context. The project is derived from the API key. 

### Examples

```ruby
require 'time'
require 'togglr-client'
# setup authorization
TogglrClient.configure do |config|
  # Configure API key authorization: ApiKeyAuth
  config.api_key['Authorization'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['Authorization'] = 'Bearer'
end

api_instance = TogglrClient::DefaultApi.new
feature_key = 'feature_key_example' # String | 
request_body = { key: 3.56} # Hash<String, Object> | 

begin
  # Evaluate feature for given context
  result = api_instance.sdk_v1_features_feature_key_evaluate_post(feature_key, request_body)
  p result
rescue TogglrClient::ApiError => e
  puts "Error when calling DefaultApi->sdk_v1_features_feature_key_evaluate_post: #{e}"
end
```

#### Using the sdk_v1_features_feature_key_evaluate_post_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<EvaluateResponse>, Integer, Hash)> sdk_v1_features_feature_key_evaluate_post_with_http_info(feature_key, request_body)

```ruby
begin
  # Evaluate feature for given context
  data, status_code, headers = api_instance.sdk_v1_features_feature_key_evaluate_post_with_http_info(feature_key, request_body)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <EvaluateResponse>
rescue TogglrClient::ApiError => e
  puts "Error when calling DefaultApi->sdk_v1_features_feature_key_evaluate_post_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **feature_key** | **String** |  |  |
| **request_body** | [**Hash&lt;String, Object&gt;**](Object.md) |  |  |

### Return type

[**EvaluateResponse**](EvaluateResponse.md)

### Authorization

[ApiKeyAuth](../README.md#ApiKeyAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json


## sdk_v1_health_get

> <HealthResponse> sdk_v1_health_get

Health check for SDK server

### Examples

```ruby
require 'time'
require 'togglr-client'

api_instance = TogglrClient::DefaultApi.new

begin
  # Health check for SDK server
  result = api_instance.sdk_v1_health_get
  p result
rescue TogglrClient::ApiError => e
  puts "Error when calling DefaultApi->sdk_v1_health_get: #{e}"
end
```

#### Using the sdk_v1_health_get_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<HealthResponse>, Integer, Hash)> sdk_v1_health_get_with_http_info

```ruby
begin
  # Health check for SDK server
  data, status_code, headers = api_instance.sdk_v1_health_get_with_http_info
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <HealthResponse>
rescue TogglrClient::ApiError => e
  puts "Error when calling DefaultApi->sdk_v1_health_get_with_http_info: #{e}"
end
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**HealthResponse**](HealthResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

