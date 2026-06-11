#!/usr/bin/env python3
import json
import struct
import zlib
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CATALOG = ROOT / "catalog.json"
SOURCE = ROOT / "source" / "ai-pixel-plants-contact-sheet.png"
REMOVEBG_DIR = ROOT / "source" / "removebg"
OUT_DIR = ROOT / "images"

SOURCE_COLUMNS = 5
SOURCE_ROWS = 4
OUTPUT_SIZE = 1254
SPRITE_SCALE = 4

CELL_CROP_OVERRIDES = {
    "hedera-helix": {
        "left": -52,
    },
}


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
            width, height, bit, color, compression, filter_method, interlace = struct.unpack(">IIBBBBB", body)
            if bit != 8 or color not in (2, 6) or compression != 0 or filter_method != 0 or interlace != 0:
                raise ValueError(f"Unsupported PNG format: {path}")
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
            else:
                raise ValueError(f"Unsupported PNG filter: {filter_type}")
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
        return (
            struct.pack(">I", len(body))
            + payload
            + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)
        )

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def crop_cell(source_width, source_height, source_pixels, index, catalog_id):
    col = index % SOURCE_COLUMNS
    row = index // SOURCE_COLUMNS
    x0 = round(col * source_width / SOURCE_COLUMNS)
    x1 = round((col + 1) * source_width / SOURCE_COLUMNS)
    y0 = round(row * source_height / SOURCE_ROWS)
    y1 = round((row + 1) * source_height / SOURCE_ROWS)
    override = CELL_CROP_OVERRIDES.get(catalog_id, {})
    x0 = max(0, x0 + override.get("left", 0))
    x1 = min(source_width, x1 + override.get("right", 0))
    y0 = max(0, y0 + override.get("top", 0))
    y1 = min(source_height, y1 + override.get("bottom", 0))
    width = x1 - x0
    height = y1 - y0
    pixels = bytearray(width * height * 4)
    for y in range(height):
        start = ((y0 + y) * source_width + x0) * 4
        pixels[y * width * 4:(y + 1) * width * 4] = source_pixels[start:start + width * 4]
    return width, height, pixels


def max_channel_distance(a, b):
    return max(abs(a[0] - b[0]), abs(a[1] - b[1]), abs(a[2] - b[2]))


def remove_background(width, height, pixels):
    border_samples = []
    for x in range(width):
        for y in (0, height - 1):
            i = (y * width + x) * 4
            border_samples.append(tuple(pixels[i:i + 3]))
    for y in range(height):
        for x in (0, width - 1):
            i = (y * width + x) * 4
            border_samples.append(tuple(pixels[i:i + 3]))
    background = tuple(sum(color[i] for color in border_samples) // len(border_samples) for i in range(3))

    seen = bytearray(width * height)
    queue = deque()
    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if not (0 <= x < width and 0 <= y < height):
            continue
        point = y * width + x
        if seen[point]:
            continue
        i = point * 4
        rgb = tuple(pixels[i:i + 3])
        if max_channel_distance(rgb, background) > 58 or (rgb[1] < 170 and rgb[2] < 145):
            continue
        seen[point] = 1
        pixels[i + 3] = 0
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    for point in range(width * height):
        i = point * 4
        r, g, b, a = pixels[i:i + 4]
        if a == 0:
            continue
        warm_shadow = r > 165 and g > 135 and b > 95 and abs(r - g) < 65 and abs(g - b) < 75
        pale_background = max_channel_distance((r, g, b), background) < 42
        if warm_shadow or pale_background:
            pixels[i + 3] = 0
    return pixels


def keep_main_components(width, height, pixels):
    visited = bytearray(width * height)
    components = []
    for start in range(width * height):
        if visited[start] or pixels[start * 4 + 3] == 0:
            continue
        queue = deque([start])
        visited[start] = 1
        points = []
        while queue:
            point = queue.popleft()
            points.append(point)
            x = point % width
            y = point // width
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if not (0 <= nx < width and 0 <= ny < height):
                    continue
                neighbor = ny * width + nx
                if visited[neighbor] or pixels[neighbor * 4 + 3] == 0:
                    continue
                visited[neighbor] = 1
                queue.append(neighbor)
        components.append(points)

    if not components:
        return pixels
    components.sort(key=len, reverse=True)
    keep = set()
    largest = len(components[0])
    for component in components:
        xs = [point % width for point in component]
        ys = [point // width for point in component]
        component_width = max(xs) - min(xs) + 1
        component_height = max(ys) - min(ys) + 1
        horizontal_fragment = component_width > component_height * 5 and len(component) < largest * 0.08
        large_enough = len(component) >= max(120, largest * 0.025)
        if component is components[0] or (large_enough and not horizontal_fragment):
            keep.update(component)
    for point in range(width * height):
        if pixels[point * 4 + 3] > 0 and point not in keep:
            pixels[point * 4 + 3] = 0
    return pixels


def content_bounds(width, height, pixels):
    xs = []
    ys = []
    for y in range(height):
        for x in range(width):
            if pixels[(y * width + x) * 4 + 3] > 0:
                xs.append(x)
                ys.append(y)
    if not xs:
        return 0, 0, width, height
    return max(0, min(xs) - 4), max(0, min(ys) - 4), min(width, max(xs) + 5), min(height, max(ys) + 5)


def extract(width, height, pixels, box):
    x0, y0, x1, y1 = box
    out_width = x1 - x0
    out_height = y1 - y0
    out = bytearray(out_width * out_height * 4)
    for y in range(out_height):
        out[y * out_width * 4:(y + 1) * out_width * 4] = pixels[((y0 + y) * width + x0) * 4:((y0 + y) * width + x1) * 4]
    return out_width, out_height, out


def compose(width, height, pixels):
    out = bytearray(OUTPUT_SIZE * OUTPUT_SIZE * 4)
    max_sprite_size = OUTPUT_SIZE - 112
    scale = min(SPRITE_SCALE, max_sprite_size / width, max_sprite_size / height)
    scaled_width = round(width * scale)
    scaled_height = round(height * scale)
    origin_x = (OUTPUT_SIZE - scaled_width) // 2
    origin_y = min(OUTPUT_SIZE - scaled_height - 56, max(24, (OUTPUT_SIZE - scaled_height) // 2 + 40))
    for y in range(scaled_height):
        source_y = min(height - 1, int(y / scale))
        for x in range(scaled_width):
            source_x = min(width - 1, int(x / scale))
            source_index = (source_y * width + source_x) * 4
            rgba = pixels[source_index:source_index + 4]
            if rgba[3] == 0:
                continue
            target_index = ((origin_y + y) * OUTPUT_SIZE + origin_x + x) * 4
            out[target_index:target_index + 4] = rgba
    return out


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    source_width, source_height, source_pixels = read_png(SOURCE)
    catalog = json.loads(CATALOG.read_text())
    for index, item in enumerate(catalog):
        removebg_source = REMOVEBG_DIR / f"{item['catalogID']}.png"
        if removebg_source.exists():
            width, height, pixels = read_png(removebg_source)
        else:
            width, height, pixels = crop_cell(source_width, source_height, source_pixels, index, item["catalogID"])
            pixels = remove_background(width, height, pixels)
            pixels = keep_main_components(width, height, pixels)
        sprite_width, sprite_height, sprite = extract(width, height, pixels, content_bounds(width, height, pixels))
        final = compose(sprite_width, sprite_height, sprite)
        image_file_name = f"{item['catalogID']}.png"
        write_png(OUT_DIR / image_file_name, OUTPUT_SIZE, OUTPUT_SIZE, final)
        print(image_file_name)


if __name__ == "__main__":
    main()
