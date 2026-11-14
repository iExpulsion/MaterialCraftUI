"""Draws the Material Glass skin's frost: a tiling 128x128 square of white whose alpha is soft, cloudy noise, laid
over the glass at a low alpha so the pane looks unevenly milky, standing in for the blur the 3.3.5 client can't
draw. Fine per-pixel noise read as TV static in game, so this is white noise under a Gaussian blur: soft blobs with
no grid, many of a size so no one of them marks where the tiles repeat. The skin draws it at twice its size.

    py -I -X utf8 tools/make_grain.py           writes Skins/MaterialGlass/MaterialGlass.tga
    py -I -X utf8 tools/make_grain.py --check   fails if the committed texture differs

The noise is seeded, so the texture comes out the same every time. It's blurred as a 3x3 block of itself and the
middle kept, so the blur wraps round the edges and the tiles meet without a seam.
"""
import os, random, sys
from PIL import Image, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'Skins', 'MaterialGlass', 'MaterialGlass.tga')
SIZE, SEED, BLUR, CLIP = 128, 0x6c617373, 3.5, 2


def frost():
    rng = random.Random(SEED)
    noise = Image.new('L', (SIZE, SIZE))
    noise.putdata([rng.randrange(256) for _ in range(SIZE * SIZE)])
    block = Image.new('L', (SIZE * 3, SIZE * 3))
    for y in range(3):
        for x in range(3):
            block.paste(noise, (x * SIZE, y * SIZE))
    soft = block.filter(ImageFilter.GaussianBlur(BLUR)).crop((SIZE, SIZE, SIZE * 2, SIZE * 2))
    values = list(soft.tobytes())
    # stretched between the 2nd and 98th percentiles, so no single darkest or brightest spot stands out and marks
    # every repeat of the tile
    ranked = sorted(values)
    lo, hi = ranked[len(ranked) * CLIP // 100], ranked[len(ranked) * (100 - CLIP) // 100]
    img = Image.new('RGBA', (SIZE, SIZE))
    img.putdata([(255, 255, 255, round(255 * min(max((v - lo) / (hi - lo), 0), 1))) for v in values])
    return img


def main():
    img = frost()
    if '--check' in sys.argv:
        saved = Image.open(OUT).convert('RGBA')
        if saved.tobytes() != img.tobytes():
            sys.exit('frost texture is out of date: run tools/make_grain.py')
        print('frost texture up to date')
    else:
        os.makedirs(os.path.dirname(OUT), exist_ok=True)
        img.save(OUT, compression='tga_rle')
        print(f'{OUT}: {SIZE}x{SIZE}, {os.path.getsize(OUT)} bytes')


if __name__ == '__main__':
    main()
