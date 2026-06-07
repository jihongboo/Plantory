# CloudKit Schema

Record type: `PlantInformation`

Fields:

| Field | CloudKit Type | Notes |
|---|---:|---|
| `catalogID` | String | Stable product ID. Prefer using this as recordName too. |
| `commonName` | String | Default English display name. |
| `species` | String | Scientific name. |
| `overview` | String | Default English encyclopedia summary. |
| `image` | Asset | Transparent pixel plant PNG. |
| `careDifficulty` | String | `easy`, `moderate`, or `hard`. |
| `lightLevel` | String | `low`, `medium`, or `high`. |
| `waterLevel` | String | `low`, `medium`, or `high`. |
| `humidityLevel` | String | `low`, `medium`, or `high`. |
| `temperature` | String | Human-readable temperature range. |
| `diseaseRiskLevel` | String | `low`, `medium`, or `high`. |
| `fertilizerLevel` | String | `low`, `medium`, or `high`. |
| `localizedContentsJSON` | String | JSON map keyed by language tag, for example `{"en":{"commonName":"Monstera","overview":"...","tips":"..."},"zh-Hans":{"commonName":"龟背竹","overview":"...","tips":"..."}}`. |

Care detail copy for difficulty, light, water, humidity, disease risk, and fertilizer is derived in the app from the corresponding level field.

Recommended query:

```swift
let predicate = NSPredicate(value: true)
let query = CKQuery(recordType: "PlantInformation", predicate: predicate)
```
