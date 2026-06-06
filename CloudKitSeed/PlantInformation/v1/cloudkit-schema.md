# CloudKit Schema

Record type: `PlantInformation`

Fields:

| Field | CloudKit Type | Notes |
|---|---:|---|
| `catalogID` | String | Stable product ID. Prefer using this as recordName too. |
| `commonName` | String | Display name. |
| `commonNameZhHans` | String | Simplified Chinese display name. Falls back to `commonName` when empty. |
| `species` | String | Scientific name. |
| `overview` | String | Short encyclopedia summary. |
| `overviewZhHans` | String | Simplified Chinese encyclopedia summary. Falls back to `overview` when empty. |
| `image` | Asset | Transparent pixel plant PNG. |
| `careDifficulty` | String | `easy`, `moderate`, or `hard`. |
| `lightLevel` | String | `low`, `medium`, or `high`. |
| `waterLevel` | String | `low`, `medium`, or `high`. |
| `humidityLevel` | String | `low`, `medium`, or `high`. |
| `temperature` | String | Human-readable temperature range. |
| `diseaseRiskLevel` | String | `low`, `medium`, or `high`. |
| `fertilizerLevel` | String | `low`, `medium`, or `high`. |
| `tips` | String | Practical quick tip. |
| `tipsZhHans` | String | Simplified Chinese quick tip. Falls back to `tips` when empty. |

Care detail copy for difficulty, light, water, humidity, disease risk, and fertilizer is derived in the app from the corresponding level field.

Recommended query:

```swift
let predicate = NSPredicate(value: true)
let query = CKQuery(recordType: "PlantInformation", predicate: predicate)
```
