#!/usr/bin/env python3
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CATALOG = ROOT / "catalog.json"
IMAGES = ROOT / "images"
OUT = ROOT / "cktool-records"

STRING_FIELDS = [
    "catalogID",
    "commonName",
    "species",
    "overview",
    "photoURL",
    "imageFileName",
    "careDifficulty",
    "careDifficultyDescription",
    "lightLevel",
    "light",
    "waterLevel",
    "water",
    "humidityLevel",
    "humidityDescription",
    "temperature",
    "diseaseRiskLevel",
    "diseaseRiskDescription",
    "fertilizerLevel",
    "fertilizer",
    "tips",
]

INT64_FIELDS = [
    "sortOrder",
    "isPublished",
]


def ck_fields(item):
    fields = {}
    for key in STRING_FIELDS:
        fields[key] = {"type": "stringType", "value": item.get(key, "")}
    for key in INT64_FIELDS:
        fields[key] = {"type": "int64Type", "value": int(item[key])}

    image_path = (IMAGES / item["imageFileName"]).resolve()
    fields["image"] = {
        "type": "assetType",
        "value": item["imageFileName"],
    }
    return fields, image_path


def main():
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)

    upload_lines = [
        "#!/usr/bin/env bash",
        "set -euo pipefail",
        "",
        ': "${CK_TEAM_ID:?Set CK_TEAM_ID}"',
        ': "${CK_CONTAINER_ID:?Set CK_CONTAINER_ID, for example iCloud.com.example.Plantory}"',
        ': "${CK_ENVIRONMENT:=development}"',
        "",
        'CKTOOL="${CKTOOL:-xcrun cktool}"',
        "",
    ]

    catalog = json.loads(CATALOG.read_text())
    for item in catalog:
        record_dir = OUT / item["catalogID"]
        record_dir.mkdir()
        fields, image_path = ck_fields(item)
        (record_dir / "fields.json").write_text(
            json.dumps(fields, indent=2, ensure_ascii=False) + "\n"
        )
        (record_dir / "asset-path.txt").write_text(str(image_path) + "\n")

        upload_lines.extend([
            f'echo "Creating {item["catalogID"]}"',
            "${CKTOOL} create-record \\",
            '  --team-id "${CK_TEAM_ID}" \\',
            '  --container-id "${CK_CONTAINER_ID}" \\',
            '  --environment "${CK_ENVIRONMENT}" \\',
            "  --database-type public \\",
            "  --record-type PlantInformation \\",
            f"  --fields-file {record_dir / 'fields.json'} \\",
            f"  --asset-files {item['imageFileName']}={image_path}",
            "",
        ])

    upload_script = OUT / "upload_all.sh"
    upload_script.write_text("\n".join(upload_lines) + "\n")
    upload_script.chmod(0o755)
    print(f"Prepared {len(catalog)} records in {OUT}")
    print(f"Upload script: {upload_script}")


if __name__ == "__main__":
    main()
