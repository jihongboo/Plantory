# CloudKit Schema

Record type: `PlantInformation`

Fields:

| Field | CloudKit Type | Notes |
|---|---:|---|
| `catalogID` | String | Stable product ID. Prefer using this as recordName too. |
| `commonName` | String | Display name. |
| `species` | String | Scientific name. |
| `overview` | String | Short encyclopedia summary. |
| `image` | Asset | Transparent pixel plant PNG. |
| `imageFileName` | String | Local seed helper field, optional in CloudKit. |
| `photoURL` | String | Optional external reference URL. Empty in v1. |
| `careDifficulty` | String | `easy`, `moderate`, or `hard`. |
| `careDifficultyDescription` | String | Short care difficulty explanation. |
| `lightLevel` | String | `low`, `medium`, or `high`. |
| `light` | String | Human-readable light guidance. |
| `waterLevel` | String | `low`, `medium`, or `high`. |
| `water` | String | Human-readable watering guidance. |
| `humidityLevel` | String | `low`, `medium`, or `high`. |
| `humidityDescription` | String | Human-readable humidity guidance. |
| `temperature` | String | Human-readable temperature range. |
| `diseaseRiskLevel` | String | `low`, `medium`, or `high`. |
| `diseaseRiskDescription` | String | Common care risks. |
| `fertilizerLevel` | String | `low`, `medium`, or `high`. |
| `fertilizer` | String | Human-readable fertilizer guidance. |
| `tips` | String | Practical quick tip. |
| `sortOrder` | Int64 | Encyclopedia ordering. |
| `isPublished` | Int64 | Use `1` for visible records. |

Recommended query:

```swift
let predicate = NSPredicate(format: "isPublished == 1")
let query = CKQuery(recordType: "PlantInformation", predicate: predicate)
query.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
```
