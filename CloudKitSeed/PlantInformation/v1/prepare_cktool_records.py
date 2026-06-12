#!/usr/bin/env python3
import json
import os
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CATALOG = ROOT / "catalog.json"
OUT = ROOT / "cktool-records"

STRING_FIELDS = [
    "catalogID",
    "commonName",
    "species",
    "overview",
    "careDifficulty",
    "lightLevel",
    "waterLevel",
    "humidityLevel",
    "temperature",
    "diseaseRiskLevel",
    "fertilizerLevel",
    "localizedContentsJSON",
    "imageURL",
]


def image_base_url():
    value = os.environ.get("PLANT_INFORMATION_IMAGE_BASE_URL", "").strip()
    if not value:
        raise SystemExit(
            "Set PLANT_INFORMATION_IMAGE_BASE_URL, for example "
            "https://example.supabase.co/storage/v1/object/public/Plantory"
        )

    return value.rstrip("/")


def ck_fields(item, base_url):
    fields = {}
    for key in STRING_FIELDS:
        value = item.get(key, "")
        if key == "imageURL" and not value:
            value = f"{base_url}/{item['catalogID']}.png"
        fields[key] = {"type": "stringType", "value": value}

    return fields


def main():
    base_url = image_base_url()

    if OUT.exists():
        for child in OUT.iterdir():
            if child.suffix == ".log":
                continue
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()
    OUT.mkdir(parents=True, exist_ok=True)

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
        fields = ck_fields(item, base_url)
        (record_dir / "fields.json").write_text(
            json.dumps(fields, indent=2, ensure_ascii=False) + "\n"
        )

        upload_lines.extend([
            f'echo "Creating {item["catalogID"]}"',
            "${CKTOOL} create-record \\",
            '  --team-id "${CK_TEAM_ID}" \\',
            '  --container-id "${CK_CONTAINER_ID}" \\',
            '  --environment "${CK_ENVIRONMENT}" \\',
            "  --database-type public \\",
            "  --record-type PlantInformation \\",
            f"  --fields-file {record_dir / 'fields.json'}",
            "",
        ])

    upload_script = OUT / "upload_all.sh"
    upload_script.write_text("\n".join(upload_lines) + "\n")
    upload_script.chmod(0o755)
    print(f"Prepared {len(catalog)} records in {OUT}")
    print(f"Upload script: {upload_script}")


if __name__ == "__main__":
    main()
