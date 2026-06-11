# PlantInformation CloudKit

This document describes the CloudKit Public Database setup and release workflow for the PlantInformation seed.

## Target

- Team ID: `CR7BE3B56R`
- Container ID: `iCloud.com.hongbo.Plantory`
- Database: Public Database
- Record type: `PlantInformation`
- Asset field: `image`
- Stable business identifier: `catalogID`

The app treats CloudKit Public Database as the remote source of truth. Local SwiftData storage is only a cache for local-first display and background refresh.

## Schema

Fields:

| Field | CloudKit Type | Notes |
|---|---:|---|
| `catalogID` | String | Stable product ID. Queryable. |
| `commonName` | String | Default English display name. Queryable. |
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
| `localizedContentsJSON` | String | JSON map keyed by language tag, for example `en` and `zh-Hans`. |

Do not add language-specific top-level text fields such as `commonNameZhHans`, `overviewZhHans`, or `tipsZhHans`. Multilingual display copy belongs in `localizedContentsJSON`.

Do not add a top-level `tips` field. Tips live inside `localizedContentsJSON`.

Care detail copy for difficulty, light, water, humidity, disease risk, and fertilizer is derived in the app from level fields.

## Local Seed Files

- `catalog.json`: source data.
- `images/<catalogID>.png`: final CloudKit image assets.
- `prepare_cktool_records.py`: converts `catalog.json` and `images/` into cktool field directories.
- `cktool-records/<catalogID>/fields.json`: record field payload.
- `cktool-records/<catalogID>/asset-path.txt`: image asset path.
- `cktool-records/upload_all.sh`: uploads all records.

Regenerate cktool payloads after catalog or image changes:

```bash
python3 CloudKitSeed/PlantInformation/v1/prepare_cktool_records.py
```

## Tokens

`xcrun cktool` is available from Xcode even when `cktool` is not directly in `PATH`.

Record operations require a CloudKit user token:

```bash
xcrun cktool save-token --type user --method keychain
```

Schema management requires a separate management token:

```bash
xcrun cktool save-token --type management --method keychain
```

## Development Upload

Set target environment:

```bash
export CK_TEAM_ID="CR7BE3B56R"
export CK_CONTAINER_ID="iCloud.com.hongbo.Plantory"
export CK_ENVIRONMENT="development"
```

If schema is missing, import or create it before uploading records. If the `PlantInformation` record type is missing, `cktool create-record` returns `not-found`.

Prepare payloads and upload:

```bash
python3 CloudKitSeed/PlantInformation/v1/prepare_cktool_records.py
CloudKitSeed/PlantInformation/v1/cktool-records/upload_all.sh
```

Before a repeated full upload, delete existing matching records to avoid duplicates:

```bash
xcrun cktool delete-records \
  --container-id iCloud.com.hongbo.Plantory \
  --environment development \
  --database-type public \
  --record-type PlantInformation \
  --filters 'catalogID != ""' \
  --dry-run false \
  --yes
```

Dry-run first when unsure:

```bash
xcrun cktool delete-records \
  --container-id iCloud.com.hongbo.Plantory \
  --environment development \
  --database-type public \
  --record-type PlantInformation \
  --filters 'catalogID != ""' \
  --dry-run true
```

Expected count after upload:

```text
Dry run. Found 20 matching records to delete.
```

## Production Release

Production schema cannot be imported with the same development `import-schema` flow. Deploy the schema from CloudKit Console first, then verify it exists:

```bash
xcrun cktool export-schema \
  --team-id CR7BE3B56R \
  --container-id iCloud.com.hongbo.Plantory \
  --environment production
```

The exported schema should include `RECORD TYPE PlantInformation` and the fields listed above.

Delete existing production records only after a dry-run confirms the intended count:

```bash
xcrun cktool delete-records \
  --container-id iCloud.com.hongbo.Plantory \
  --environment production \
  --database-type public \
  --record-type PlantInformation \
  --filters 'catalogID != ""' \
  --dry-run true
```

Then delete for real:

```bash
xcrun cktool delete-records \
  --container-id iCloud.com.hongbo.Plantory \
  --environment production \
  --database-type public \
  --record-type PlantInformation \
  --filters 'catalogID != ""' \
  --dry-run false \
  --yes
```

Upload to production:

```bash
export CK_TEAM_ID="CR7BE3B56R"
export CK_CONTAINER_ID="iCloud.com.hongbo.Plantory"
export CK_ENVIRONMENT="production"

python3 CloudKitSeed/PlantInformation/v1/prepare_cktool_records.py
CloudKitSeed/PlantInformation/v1/cktool-records/upload_all.sh
```

## Verification

Count records:

```bash
xcrun cktool delete-records \
  --container-id iCloud.com.hongbo.Plantory \
  --environment production \
  --database-type public \
  --record-type PlantInformation \
  --filters 'catalogID != ""' \
  --dry-run true
```

Query a sample:

```bash
xcrun cktool query-records \
  --team-id CR7BE3B56R \
  --container-id iCloud.com.hongbo.Plantory \
  --environment production \
  --database-type public \
  --record-type PlantInformation \
  --requested-fields catalogID commonName localizedContentsJSON image tips commonNameZhHans overviewZhHans tipsZhHans \
  --limit 1
```

Expected:

- 20 matching records.
- Sample includes `catalogID`, `commonName`, `localizedContentsJSON`, and `image`.
- Sample does not include old fields: `tips`, `commonNameZhHans`, `overviewZhHans`, `tipsZhHans`.

## Current Status

Development was previously uploaded with 20 `PlantInformation` records.

Production was also uploaded with 20 `PlantInformation` records after the schema was deployed from CloudKit Console. TestFlight builds read production Public Database records.

`upload-status.md` contains older development upload notes and historical cleanup details.
