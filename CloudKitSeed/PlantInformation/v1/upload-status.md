# Upload Status

Last upload: 2026-06-05

Target:

- Team ID: `CR7BE3B56R`
- Container ID: `iCloud.com.hongbo.Plantory`
- Environment: `development`
- Database: Public Database
- Record type: `PlantInformation`

Result:

- Schema imported with `PlantInformation`.
- Query indexes added for `___recordID`, `catalogID`, `commonName`, and `isPublished`.
- Sort index added for `sortOrder`.
- Duplicate records from earlier attempts were deleted.
- Final upload completed successfully.
- Verification dry-run found 20 published `PlantInformation` records.
- A full query by `isPublished == 1` returned records with all expected fields and image assets.

Verification commands:

```bash
xcrun cktool delete-records \
  --container-id iCloud.com.hongbo.Plantory \
  --environment development \
  --database-type public \
  --record-type PlantInformation \
  --filters 'isPublished == 1' \
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
  --filters 'isPublished == 1' \
  --limit 1
```

Latest final upload log:

```text
CloudKitSeed/PlantInformation/v1/cktool-records/upload-final-20260605-201555.log
```
