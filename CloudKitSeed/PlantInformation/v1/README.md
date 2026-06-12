# PlantInformation CloudKit Seed v1

This folder contains the first public PlantInformation catalog for Plantory.

Upload target:
- CloudKit database: Public Database
- Record type: `PlantInformation`
- Image URL field: `imageURL`
- Source data: `catalog.json`
- Image files: `images/*.png` uploaded to Supabase Storage
- cktool files: `cktool-records/`

The app should treat CloudKit Public Database as the source of truth for the plant encyclopedia. The app caches `PlantInformation` records in SwiftData for local-first display and refreshes them from Public Database.

The old CloudKit `image` Asset field is retired. It may still exist in the CloudKit schema because it was already active in production; new records should only write `imageURL`.

## Record Identity

Use `catalogID` as the stable product identifier. Recommended CloudKit `recordName` values match `catalogID`.

Example:

```text
catalogID: monstera-deliciosa
recordName: monstera-deliciosa
```

## Images

Each `catalogID` maps to a transparent-background pixel plant PNG in `images/` using `<catalogID>.png`. Upload those PNGs to Supabase Storage and store the public URL in the CloudKit `imageURL` field for the matching record.

The current v1 image pipeline uses one AI-generated contact sheet plus remove.bg cutouts:

- `source/ai-pixel-plants-contact-sheet.png`: original AI contact sheet, arranged in the same order as `catalog.json`.
- `source/removebg/<catalogID>.png`: per-plant transparent source PNGs returned by remove.bg.
- `images/<catalogID>.png`: final `1254x1254` transparent PNGs uploaded to Supabase Storage.

Regenerate final Supabase Storage image sources:

```bash
python3 CloudKitSeed/PlantInformation/v1/generate_pixel_images.py
```

Full workflow: [IMAGE_GENERATION.md](IMAGE_GENERATION.md).

## CloudKit

CloudKit Public Database is the remote source of truth for this catalog.

Full schema, token, upload, production release, and verification workflow: [CLOUDKIT.md](CLOUDKIT.md).

## First Release Scope

The v1 catalog contains 20 common beginner-friendly houseplants:

- Monstera
- Pothos
- Snake Plant
- ZZ Plant
- Peace Lily
- Spider Plant
- Rubber Plant
- Fiddle Leaf Fig
- Chinese Money Plant
- Boston Fern
- Calathea
- Heartleaf Philodendron
- Aloe Vera
- Echeveria
- Jade Plant
- Ladyfinger Cactus
- Moth Orchid
- Anthurium
- Lucky Bamboo
- English Ivy
