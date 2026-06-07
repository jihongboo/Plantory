# Upload Status

Last upload: 2026-06-06
Last schema cleanup: 2026-06-06
Last localization schema update: 2026-06-06

Target:

- Team ID: `CR7BE3B56R`
- Container ID: `iCloud.com.hongbo.Plantory`
- Environment: `development`
- Database: Public Database
- Record type: `PlantInformation`

Result:

- Schema imported with `PlantInformation`.
- Query indexes added for `___recordID`, `catalogID`, and `commonName`.
- Duplicate records from earlier attempts were deleted.
- Final upload completed successfully.
- Verification dry-run found 20 `PlantInformation` records.
- A full query returned records with all expected fields and image assets.
- Local seed files now store localized `commonName`, `overview`, and `tips` values inside `localizedContentsJSON`.
- Development schema cleanup removed unused `photoURL`, `imageFileName`, `sortOrder`, and `isPublished` fields.
- Local schema files now use `localizedContentsJSON` instead of language-specific top-level text fields.
- Development schema cleanup removed long care-description fields: `careDifficultyDescription`, `light`, `water`, `humidityDescription`, `diseaseRiskDescription`, and `fertilizer`.
- Care detail copy is now derived in the app from `careDifficulty`, `lightLevel`, `waterLevel`, `humidityLevel`, `diseaseRiskLevel`, and `fertilizerLevel`.

Verification commands:

```bash
xcrun cktool delete-records \
  --container-id iCloud.com.hongbo.Plantory \
  --environment development \
  --database-type public \
  --record-type PlantInformation \
  --dry-run true
```

Expected output:

```text
Dry run. Found 20 matching records to delete.
```

Sample query:

```bash
xcrun cktool query-records \
  --team-id CR7BE3B56R \
  --container-id iCloud.com.hongbo.Plantory \
  --environment development \
  --database-type public \
  --record-type PlantInformation \
  --limit 1
```

Latest final upload log:

```text
CloudKitSeed/PlantInformation/v1/cktool-records/upload-final-20260605-201555.log
```
