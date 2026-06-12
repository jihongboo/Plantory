# Upload Status

Last upload: 2026-06-12
Last schema cleanup: 2026-06-06
Last localization schema update: 2026-06-06
Last image refresh: 2026-06-11
Current image storage plan: Supabase Storage public URLs stored in CloudKit `imageURL`; the old CloudKit `image` Asset field is retired and should not be read or written.

Target:

- Team ID: `CR7BE3B56R`
- Container ID: `iCloud.com.hongbo.Plantory`
- Environments: `development`, `production`
- Database: Public Database
- Record type: `PlantInformation`

Result:

- Development schema imported with `PlantInformation.imageURL`; production schema was deployed from CloudKit Console.
- Query indexes added for `___recordID`, `catalogID`, and `commonName`.
- Existing 20 records were deleted from both development and production.
- 20 records were recreated in both development and production from `cktool-records/`.
- Verification dry-run found 20 `PlantInformation` records in both environments.
- Production sample query returned Supabase Storage `imageURL` values.
- The old `image` asset field may still exist in schema because CloudKit rejected removing an active production field.
- Local seed files now store localized `commonName`, `overview`, and `tips` values inside `localizedContentsJSON`.
- Development schema cleanup removed unused `photoURL`, `imageFileName`, `sortOrder`, and `isPublished` fields.
- Local schema files now use `localizedContentsJSON` instead of language-specific top-level text fields.
- Development schema cleanup removed long care-description fields: `careDifficultyDescription`, `light`, `water`, `humidityDescription`, `diseaseRiskDescription`, and `fertilizer`.
- Care detail copy is now derived in the app from `careDifficulty`, `lightLevel`, `waterLevel`, `humidityLevel`, `diseaseRiskLevel`, and `fertilizerLevel`.
- AI-generated pixel plant images are now hosted in Supabase Storage and referenced from CloudKit by `imageURL`.
- Production was refreshed for TestFlight access on 2026-06-12.

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
