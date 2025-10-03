# TogglrClient::FeatureHealth

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **feature_key** | **String** |  |  |
| **environment_key** | **String** |  |  |
| **enabled** | **Boolean** |  |  |
| **auto_disabled** | **Boolean** |  |  |
| **error_rate** | **Float** |  | [optional] |
| **threshold** | **Float** |  | [optional] |
| **last_error_at** | **Time** |  | [optional] |

## Example

```ruby
require 'togglr-client'

instance = TogglrClient::FeatureHealth.new(
  feature_key: null,
  environment_key: null,
  enabled: null,
  auto_disabled: null,
  error_rate: 0.15,
  threshold: 0.2,
  last_error_at: null
)
```

