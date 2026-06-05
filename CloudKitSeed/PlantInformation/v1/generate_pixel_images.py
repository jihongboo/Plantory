#!/usr/bin/env python3
import json
import math
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CATALOG = ROOT / "catalog.json"
OUT_DIR = ROOT / "images"
SIZE = 1254
GRID = 66
SCALE = 18
OFFSET = (SIZE - GRID * SCALE) // 2

INK = (55, 45, 38, 255)
POT_DARK = (111, 78, 51, 255)
POT = (178, 121, 73, 255)
POT_LIGHT = (222, 168, 104, 255)
SOIL = (74, 51, 38, 255)
GREEN_DARK = (45, 101, 57, 255)
GREEN = (77, 151, 77, 255)
GREEN_LIGHT = (132, 194, 99, 255)
MINT = (140, 210, 155, 255)
CREAM = (246, 235, 190, 255)
WHITE = (248, 244, 226, 255)
PINK = (224, 112, 145, 255)
RED = (202, 69, 70, 255)
YELLOW = (242, 197, 83, 255)
PURPLE = (156, 111, 190, 255)
LIME = (174, 216, 90, 255)
BLUEGREEN = (69, 154, 132, 255)
SAGE = (119, 154, 110, 255)


def write_png(path, pixels):
    raw = bytearray()
    for y in range(SIZE):
        raw.append(0)
        start = y * SIZE * 4
        raw.extend(pixels[start:start + SIZE * 4])

    def chunk(kind, data):
        body = kind + data
        return (
            struct.pack(">I", len(data))
            + body
            + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)
        )

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def new_canvas():
    return bytearray(SIZE * SIZE * 4)


def put_px(pixels, x, y, color):
    if 0 <= x < GRID and 0 <= y < GRID:
        px = OFFSET + x * SCALE
        py = OFFSET + y * SCALE
        for yy in range(py, py + SCALE):
            row = yy * SIZE * 4
            for xx in range(px, px + SCALE):
                i = row + xx * 4
                pixels[i:i + 4] = bytes(color)


def rect(pixels, x, y, w, h, color):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            put_px(pixels, xx, yy, color)


def ellipse(pixels, cx, cy, rx, ry, color):
    for y in range(math.floor(cy - ry), math.ceil(cy + ry) + 1):
        for x in range(math.floor(cx - rx), math.ceil(cx + rx) + 1):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1:
                put_px(pixels, x, y, color)


def line(pixels, x0, y0, x1, y1, color, width=1):
    dx = abs(x1 - x0)
    dy = -abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx + dy
    x, y = x0, y0
    while True:
        rect(pixels, x - width // 2, y - width // 2, width, width, color)
        if x == x1 and y == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x += sx
        if e2 <= dx:
            err += dx
            y += sy


def pot(pixels, wide=False):
    x = 19 if wide else 22
    w = 28 if wide else 22
    rect(pixels, x, 48, w, 4, INK)
    rect(pixels, x + 2, 52, w - 4, 10, POT)
    rect(pixels, x + 4, 62, w - 8, 2, POT_DARK)
    rect(pixels, x + 4, 52, w - 8, 2, POT_LIGHT)
    rect(pixels, x + 2, 50, w - 4, 2, SOIL)
    rect(pixels, x, 48, 2, 4, POT_DARK)
    rect(pixels, x + w - 2, 48, 2, 4, POT_DARK)


def leaf(pixels, cx, cy, rx, ry, color=GREEN, vein=True):
    ellipse(pixels, cx, cy, rx, ry, color)
    ellipse(pixels, cx - rx * 0.25, cy - ry * 0.25, max(1, rx * 0.35), max(1, ry * 0.35), GREEN_LIGHT)
    if vein:
        line(pixels, round(cx), round(cy + ry * 0.75), round(cx), round(cy - ry * 0.75), GREEN_DARK, 1)


def flower(pixels, cx, cy, color):
    ellipse(pixels, cx, cy - 3, 3, 4, color)
    ellipse(pixels, cx - 4, cy, 4, 3, color)
    ellipse(pixels, cx + 4, cy, 4, 3, color)
    ellipse(pixels, cx, cy + 3, 3, 4, color)
    rect(pixels, cx - 1, cy - 1, 3, 3, YELLOW)


def draw_monstera(p):
    pot(p, True)
    for end in [(23, 28), (31, 20), (42, 27), (36, 14), (27, 17)]:
        line(p, 33, 50, end[0], end[1], GREEN_DARK, 2)
    for args in [(22, 27, 7, 10), (31, 20, 9, 12), (43, 27, 8, 11), (36, 14, 8, 10), (27, 17, 6, 9)]:
        leaf(p, *args, GREEN)
    for x, y in [(29, 19), (33, 25), (38, 16), (43, 28)]:
        rect(p, x, y, 2, 4, (0, 0, 0, 0))


def draw_trailing(p, leaf_color=GREEN, variegated=False):
    pot(p)
    for start, end in [((32, 49), (18, 29)), ((34, 49), (48, 28)), ((31, 50), (27, 17)), ((35, 50), (40, 18))]:
        line(p, *start, *end, GREEN_DARK, 2)
    for cx, cy in [(18, 29), (23, 34), (27, 17), (31, 25), (40, 18), (45, 27), (48, 28)]:
        leaf(p, cx, cy, 4, 5, leaf_color)
        if variegated:
            rect(p, cx, cy - 2, 2, 3, LIME)


def draw_snake(p):
    pot(p)
    for cx, h, color in [(25, 28, GREEN_DARK), (31, 35, GREEN), (37, 31, SAGE), (42, 24, GREEN_DARK)]:
        ellipse(p, cx, 48 - h // 2, 4, h // 2, color)
        line(p, cx, 48, cx, 48 - h, LIME, 1)


def draw_zz(p):
    pot(p)
    for x1 in [22, 28, 34, 40, 45]:
        line(p, 33, 50, x1, 18 + abs(34 - x1) // 2, GREEN_DARK, 2)
        for k in range(4):
            y = 24 + k * 5
            x = round(33 + (x1 - 33) * (k + 1) / 5)
            leaf(p, x - 2, y, 3, 4, GREEN)
            leaf(p, x + 3, y + 1, 3, 4, GREEN_LIGHT)


def draw_peace_lily(p):
    pot(p)
    for x in [24, 29, 35, 41]:
        line(p, 33, 50, x, 26, GREEN_DARK, 2)
        leaf(p, x, 31, 5, 9, GREEN)
    line(p, 34, 50, 38, 18, GREEN_DARK, 1)
    ellipse(p, 39, 17, 5, 7, WHITE)
    rect(p, 38, 16, 2, 5, YELLOW)


def draw_spider(p):
    pot(p, True)
    for x in range(17, 50, 4):
        line(p, 33, 50, x, 18 + abs(33 - x) // 2, GREEN_DARK, 1)
        line(p, 33, 50, x + 1, 19 + abs(33 - x) // 2, CREAM, 1)


def draw_rubber(p):
    pot(p)
    for end in [(24, 22), (30, 17), (39, 20), (43, 30)]:
        line(p, 33, 50, *end, GREEN_DARK, 2)
        leaf(p, end[0], end[1], 6, 8, GREEN_DARK)


def draw_fiddle(p):
    pot(p)
    line(p, 33, 50, 33, 15, POT_DARK, 2)
    for cx, cy in [(26, 31), (40, 29), (29, 21), (38, 18), (33, 12)]:
        leaf(p, cx, cy, 6, 8, GREEN)


def draw_pilea(p):
    pot(p)
    for cx, cy in [(25, 28), (33, 20), (42, 28), (29, 36), (38, 36)]:
        line(p, 33, 50, cx, cy, GREEN_DARK, 1)
        ellipse(p, cx, cy, 5, 5, GREEN_LIGHT)
        rect(p, cx - 1, cy - 1, 2, 2, GREEN_DARK)


def draw_fern(p):
    pot(p, True)
    for end in [(15, 27), (21, 19), (31, 15), (43, 19), (51, 28)]:
        line(p, 33, 50, *end, GREEN_DARK, 1)
        for k in range(6):
            x = round(33 + (end[0] - 33) * k / 6)
            y = round(50 + (end[1] - 50) * k / 6)
            ellipse(p, x - 2, y, 2, 2, GREEN)
            ellipse(p, x + 2, y, 2, 2, GREEN_LIGHT)


def draw_calathea(p):
    pot(p)
    for cx, cy in [(24, 29), (32, 21), (42, 29), (28, 38), (39, 39)]:
        line(p, 33, 50, cx, cy, GREEN_DARK, 2)
        leaf(p, cx, cy, 7, 10, SAGE)
        line(p, cx - 3, cy, cx + 3, cy, CREAM, 1)


def draw_aloe(p):
    pot(p)
    for end in [(20, 19), (27, 14), (33, 11), (39, 15), (47, 20), (26, 31), (41, 31)]:
        line(p, 33, 50, *end, BLUEGREEN, 4)
        line(p, 33, 50, *end, MINT, 1)


def draw_echeveria(p):
    pot(p)
    for r, color in [(14, BLUEGREEN), (10, MINT), (6, GREEN_LIGHT)]:
        for a in range(0, 360, 45):
            cx = 33 + math.cos(math.radians(a)) * r * 0.55
            cy = 33 + math.sin(math.radians(a)) * r * 0.35
            leaf(p, cx, cy, 4, 7, color, False)


def draw_jade(p):
    pot(p)
    line(p, 33, 50, 33, 25, POT_DARK, 3)
    for cx, cy in [(25, 34), (41, 33), (28, 24), (38, 22), (33, 17)]:
        line(p, 33, 38, cx, cy, POT_DARK, 2)
        ellipse(p, cx, cy, 5, 5, GREEN)


def draw_cactus(p):
    pot(p)
    for cx, h in [(26, 24), (33, 34), (41, 26)]:
        ellipse(p, cx, 48 - h // 2, 4, h // 2, GREEN)
        for y in range(48 - h + 3, 48, 5):
            rect(p, cx - 1, y, 1, 1, CREAM)
            rect(p, cx + 2, y + 1, 1, 1, CREAM)


def draw_orchid(p):
    pot(p)
    line(p, 33, 50, 33, 18, GREEN_DARK, 1)
    leaf(p, 27, 40, 7, 5, GREEN)
    leaf(p, 39, 41, 7, 5, GREEN)
    flower(p, 33, 18, PURPLE)
    flower(p, 25, 25, PINK)
    flower(p, 42, 27, WHITE)


def draw_anthurium(p):
    pot(p)
    for cx, cy in [(25, 33), (40, 34), (32, 24)]:
        line(p, 33, 50, cx, cy, GREEN_DARK, 2)
        leaf(p, cx, cy, 6, 8, GREEN)
    line(p, 34, 50, 42, 20, GREEN_DARK, 1)
    leaf(p, 43, 19, 6, 7, RED, False)
    rect(p, 42, 18, 2, 5, YELLOW)


def draw_bamboo(p):
    pot(p, True)
    for x in [27, 33, 39]:
        rect(p, x, 18, 3, 34, GREEN)
        for y in range(22, 49, 7):
            rect(p, x - 1, y, 5, 1, GREEN_DARK)
        leaf(p, x - 4, 21, 4, 3, GREEN_LIGHT)
        leaf(p, x + 6, 29, 4, 3, GREEN_LIGHT)


DRAWERS = {
    "monstera-deliciosa": draw_monstera,
    "epipremnum-aureum": lambda p: draw_trailing(p, GREEN, True),
    "dracaena-trifasciata": draw_snake,
    "zamioculcas-zamiifolia": draw_zz,
    "spathiphyllum-wallisii": draw_peace_lily,
    "chlorophytum-comosum": draw_spider,
    "ficus-elastica": draw_rubber,
    "ficus-lyrata": draw_fiddle,
    "pilea-peperomioides": draw_pilea,
    "nephrolepis-exaltata": draw_fern,
    "goeppertia-orbifolia": draw_calathea,
    "philodendron-hederaceum": lambda p: draw_trailing(p, GREEN_LIGHT, False),
    "aloe-barbadensis-miller": draw_aloe,
    "echeveria-elegans": draw_echeveria,
    "crassula-ovata": draw_jade,
    "mammillaria-elongata": draw_cactus,
    "phalaenopsis-amabilis": draw_orchid,
    "anthurium-andraeanum": draw_anthurium,
    "dracaena-sanderiana": draw_bamboo,
    "hedera-helix": lambda p: draw_trailing(p, SAGE, True),
}


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    catalog = json.loads(CATALOG.read_text())
    for item in catalog:
        pixels = new_canvas()
        DRAWERS[item["catalogID"]](pixels)
        write_png(OUT_DIR / item["imageFileName"], pixels)
        print(item["imageFileName"])


if __name__ == "__main__":
    main()
