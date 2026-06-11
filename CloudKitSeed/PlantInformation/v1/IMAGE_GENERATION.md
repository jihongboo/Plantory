# PlantInformation Image Generation

This document describes how to regenerate the v1 PlantInformation pixel plant images.

## Outputs

- `source/ai-pixel-plants-contact-sheet.png`: original AI contact sheet.
- `source/removebg/<catalogID>.png`: transparent per-plant sources returned by remove.bg.
- `images/<catalogID>.png`: final `1254x1254` transparent PNGs used by CloudKit.

The checked-in generator prefers `source/removebg/<catalogID>.png` when present. If a remove.bg source is missing, it falls back to cropping `source/ai-pixel-plants-contact-sheet.png` and using local background cleanup.

Regenerate final images:

```bash
python3 CloudKitSeed/PlantInformation/v1/generate_pixel_images.py
```

## AI Contact Sheet

Generate a 5 columns x 4 rows pixel-art contact sheet in the same order as `catalog.json`:

```text
Monstera, Pothos, Snake Plant, ZZ Plant, Peace Lily,
Spider Plant, Rubber Plant, Fiddle Leaf Fig, Chinese Money Plant, Boston Fern,
Calathea, Heartleaf Philodendron, Aloe Vera, Echeveria, Jade Plant,
Ladyfinger Cactus, Moth Orchid, Anthurium, Lucky Bamboo, English Ivy
```

Prompt guidance:

```text
Small potted houseplant pixel-art sprites, warm beige preview background,
chunky pixels, dark brown/black outlines, terracotta pots, simple ground shadows,
clear distinctive silhouettes, no text, no labels, no watermark.
```

Save the selected image to:

```bash
CloudKitSeed/PlantInformation/v1/source/ai-pixel-plants-contact-sheet.png
```

## remove.bg

Do not commit API tokens. Pass the token as an environment variable only:

```bash
export REMOVE_BG_API_KEY="..."
```

Create contact-sheet cell crops:

```bash
mkdir -p tmp/removebg-inputs
python3 - <<'PY'
import json, struct, zlib
from pathlib import Path

root = Path("CloudKitSeed/PlantInformation/v1")
source = root / "source" / "ai-pixel-plants-contact-sheet.png"
out_dir = Path("tmp/removebg-inputs")
out_dir.mkdir(parents=True, exist_ok=True)
items = json.loads((root / "catalog.json").read_text())
cols, rows = 5, 4
overrides = {"hedera-helix": {"left": -52}}

def read_png(path):
    data = path.read_bytes()
    pos = 8
    width = height = channels = None
    idat = bytearray()
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if kind == b"IHDR":
            width, height, bit, color, comp, filt, inter = struct.unpack(">IIBBBBB", body)
            channels = 4 if color == 6 else 3
        elif kind == b"IDAT":
            idat.extend(body)
        elif kind == b"IEND":
            break
    raw = zlib.decompress(bytes(idat))
    stride = width * channels
    pixels = bytearray(width * height * 4)
    src = 0
    prev = bytearray(stride)
    for y in range(height):
        filter_type = raw[src]
        src += 1
        scan = bytearray(raw[src:src + stride])
        src += stride
        recon = bytearray(stride)
        for i, value in enumerate(scan):
            a = recon[i - channels] if i >= channels else 0
            b = prev[i]
            c = prev[i - channels] if i >= channels else 0
            if filter_type == 0:
                recon[i] = value
            elif filter_type == 1:
                recon[i] = (value + a) & 255
            elif filter_type == 2:
                recon[i] = (value + b) & 255
            elif filter_type == 3:
                recon[i] = (value + ((a + b) // 2)) & 255
            elif filter_type == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                predictor = a if pa <= pb and pa <= pc else b if pb <= pc else c
                recon[i] = (value + predictor) & 255
        for x in range(width):
            source_index = x * channels
            target_index = (y * width + x) * 4
            pixels[target_index:target_index + 3] = recon[source_index:source_index + 3]
            pixels[target_index + 3] = recon[source_index + 3] if channels == 4 else 255
        prev = recon
    return width, height, pixels

def write_png(path, width, height, pixels):
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        raw.extend(pixels[y * width * 4:(y + 1) * width * 4])
    def chunk(kind, body):
        payload = kind + body
        return struct.pack(">I", len(body)) + payload + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b"")
    )

source_width, source_height, source_pixels = read_png(source)
for index, item in enumerate(items):
    catalog_id = item["catalogID"]
    col = index % cols
    row = index // cols
    x0 = round(col * source_width / cols)
    x1 = round((col + 1) * source_width / cols)
    y0 = round(row * source_height / rows)
    y1 = round((row + 1) * source_height / rows)
    override = overrides.get(catalog_id, {})
    x0 = max(0, x0 + override.get("left", 0))
    x1 = min(source_width, x1 + override.get("right", 0))
    y0 = max(0, y0 + override.get("top", 0))
    y1 = min(source_height, y1 + override.get("bottom", 0))
    width = x1 - x0
    height = y1 - y0
    crop = bytearray(width * height * 4)
    for y in range(height):
        crop[y * width * 4:(y + 1) * width * 4] = source_pixels[((y0 + y) * source_width + x0) * 4:((y0 + y) * source_width + x1) * 4]
    write_png(out_dir / f"{catalog_id}.png", width, height, crop)
PY
```

Send each crop to remove.bg:

```bash
mkdir -p CloudKitSeed/PlantInformation/v1/source/removebg

for input in tmp/removebg-inputs/*.png; do
  name="$(basename "$input")"
  curl -sS -f \
    -H "X-Api-Key: ${REMOVE_BG_API_KEY}" \
    -F "image_file=@${input}" \
    -F "size=preview" \
    -F "format=png" \
    -o "CloudKitSeed/PlantInformation/v1/source/removebg/${name}" \
    "https://api.remove.bg/v1.0/removebg"
done
```

Then regenerate final CloudKit images:

```bash
python3 CloudKitSeed/PlantInformation/v1/generate_pixel_images.py
```

## Validation

```bash
find CloudKitSeed/PlantInformation/v1/source/removebg -name '*.png' | wc -l
find CloudKitSeed/PlantInformation/v1/images -name '*.png' | wc -l
sips -g pixelWidth -g pixelHeight -g hasAlpha CloudKitSeed/PlantInformation/v1/images/monstera-deliciosa.png
```

Expected result:

- 20 remove.bg source PNGs.
- 20 final image PNGs.
- Final images are `1254x1254` and `hasAlpha: yes`.
