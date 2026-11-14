"""Draws the Material Glass skin's grain: a tiling 128x128 square of white whose alpha is soft noise, laid over the
glass at a low alpha to stand in for the blur the 3.3.5 client can't draw.

    py -I -X utf8 tools/make_grain.py           writes Skins/MaterialGlass/MaterialGlass.tga
    py -I -X utf8 tools/make_grain.py --check   fails if the committed texture differs

The noise is seeded, so the texture comes out the same every time. It's smoothed with its neighbors wrapping round
the edges, so the tiles meet without a seam.
"""
import os, random, sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'Skins', 'MaterialGlass', 'MaterialGlass.tga')
SIZE, SEED = 128, 0x6c617373
# center, edge and corner weights of the smoothing
WEIGHTS = (4, 2, 1)


def grain():
    rng = random.Random(SEED)
    raw = [[rng.random() for _ in range(SIZE)] for _ in range(SIZE)]
    total = WEIGHTS[0] + 4 * WEIGHTS[1] + 4 * WEIGHTS[2]
    soft = [[0.0] * SIZE for _ in range(SIZE)]
    for y in range(SIZE):
        for x in range(SIZE):
            v = 0.0
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    w = WEIGHTS[abs(dx) + abs(dy)]
                    v += w * raw[(y + dy) % SIZE][(x + dx) % SIZE]
            soft[y][x] = v / total
    lo = min(min(r) for r in soft)
    hi = max(max(r) for r in soft)
    img = Image.new('RGBA', (SIZE, SIZE))
    img.putdata([(255, 255, 255, round(255 * (v - lo) / (hi - lo))) for row in soft for v in row])
    return img


def main():
    img = grain()
    if '--check' in sys.argv:
        saved = Image.open(OUT).convert('RGBA')
        if saved.tobytes() != img.tobytes():
            sys.exit('grain is out of date: run tools/make_grain.py')
        print('grain up to date')
    else:
        os.makedirs(os.path.dirname(OUT), exist_ok=True)
        img.save(OUT, compression='tga_rle')
        print(f'{OUT}: {SIZE}x{SIZE}, {os.path.getsize(OUT)} bytes')


if __name__ == '__main__':
    main()
