# TogglrClient::FeatureErrorReport

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **error_type** | **String** |  |  |
| **error_message** | **String** |  |  |
| **context** | **Hash&lt;String, Object&gt;** |  | [optional] |

## Example

```ruby
require 'togglr-client'

instance = TogglrClient::FeatureErrorReport.new(
  error_type: timeout,
  error_message: Service X did not respond in 5s,
  context: null
)
```

