"""Packs the pieces a skin uses from its painted sheets into one atlas, losslessly, and writes the Lua table of
where each piece landed.

    py -I -X utf8 tools/pack_art.py art/cognac/pieces.json

pieces.json names each piece's rectangle on its source sheet ([x0, y0, x1, y1], pixels, end exclusive). A piece
with "trim" loses its fully transparent margins; the table records how much, as fractions of the original
rectangle, so the skin can still place it as if it were whole. Each piece is packed with a margin copied from
around it on its source sheet, so filtering at its edges samples the same pixels it did on the original. The atlas
is a power of two on each side, as the 3.3.5 client needs, saved as a run-length encoded TGA.

    --check    rebuild in memory and fail if the committed atlas or table differ, or if any piece's pixels changed
"""
import json, os, sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MARGIN = 2


def trimmed(sheet, rect):
    x0, y0, x1, y1 = rect
    box = sheet.crop(rect).getchannel('A').getbbox()
    if box is None:
        sys.exit(f'piece at {rect} is empty')
    return (x0 + box[0], y0 + box[1], x0 + box[2], y0 + box[3])


def max_rects(sizes, width, height):
    """MaxRects, best short side fit, largest boxes first: positions of (name, w, h) boxes in a width x height
    sheet, or None when they don't all fit."""
    free = [(0, 0, width, height)]
    spots = {}
    for name, w, h in sorted(sizes, key=lambda s: (-s[1] * s[2], s[0])):
        best = None
        for fx, fy, fw, fh in free:
            if w <= fw and h <= fh:
                score = (min(fw - w, fh - h), max(fw - w, fh - h))
                if best is None or score < best[0]:
                    best = (score, fx, fy)
        if best is None:
            return None
        _, x, y = best
        spots[name] = (x, y)
        placed, split = (x, y, x + w, y + h), []
        for fx, fy, fw, fh in free:
            r = (fx, fy, fx + fw, fy + fh)
            if placed[0] >= r[2] or placed[2] <= r[0] or placed[1] >= r[3] or placed[3] <= r[1]:
                split.append((fx, fy, fw, fh))
            else:
                if placed[0] > r[0]: split.append((r[0], r[1], placed[0] - r[0], fh))
                if placed[2] < r[2]: split.append((placed[2], r[1], r[2] - placed[2], fh))
                if placed[1] > r[1]: split.append((r[0], r[1], fw, placed[1] - r[1]))
                if placed[3] < r[3]: split.append((r[0], placed[3], fw, r[3] - placed[3]))
        free = [a for a in split if not any(a != b and a[0] >= b[0] and a[1] >= b[1]
                                            and a[0] + a[2] <= b[0] + b[2] and a[1] + a[3] <= b[1] + b[3] for b in split)]
    return spots


def build(spec):
    sheets = {k: Image.open(os.path.join(ROOT, p)).convert('RGBA') for k, p in spec['sheets'].items()}
    pieces = {}
    for name, p in spec['pieces'].items():
        sheet = sheets[p['sheet']]
        full = tuple(p['rect'])
        inner = trimmed(sheet, full) if p.get('trim') else full
        pieces[name] = (sheet, full, inner)
    sizes = [(n, i[2] - i[0] + 2 * MARGIN, i[3] - i[1] + 2 * MARGIN) for n, (_, _, i) in pieces.items()]
    # the smallest power-of-two sheet they fit in, the squarer one on a tie
    tries = sorted(((a, b) for a in (256, 512, 1024, 2048) for b in (256, 512, 1024, 2048)),
                   key=lambda s: (s[0] * s[1], abs(s[0] - s[1]), -s[0]))
    for w, h in tries:
        spots = max_rects(sizes, w, h)
        if spots:
            break
    atlas = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    table = {}
    for name, (sheet, full, inner) in pieces.items():
        x, y = spots[name]
        # the piece plus MARGIN pixels of what surrounds it on its sheet, clamped at the sheet's edges
        sx0, sy0 = inner[0] - MARGIN, inner[1] - MARGIN
        block = Image.new('RGBA', (inner[2] - inner[0] + 2 * MARGIN, inner[3] - inner[1] + 2 * MARGIN), (0, 0, 0, 0))
        cx0, cy0 = max(sx0, 0), max(sy0, 0)
        cx1, cy1 = min(inner[2] + MARGIN, sheet.width), min(inner[3] + MARGIN, sheet.height)
        block.paste(sheet.crop((cx0, cy0, cx1, cy1)), (cx0 - sx0, cy0 - sy0))
        atlas.paste(block, (x, y))
        px, py = x + MARGIN, y + MARGIN
        fw, fh = full[2] - full[0], full[3] - full[1]
        table[name] = {
            'coords': ((px) / w, (px + inner[2] - inner[0]) / w, (py) / h, (py + inner[3] - inner[1]) / h),
            'trim': ((inner[0] - full[0]) / fw, (inner[1] - full[1]) / fh, (full[2] - inner[2]) / fw, (full[3] - inner[3]) / fh),
            'at': (px, py, inner),
            'size': (fw, fh),
        }
    return atlas, table


def verify(spec, atlas, table):
    sheets = {k: Image.open(os.path.join(ROOT, p)).convert('RGBA') for k, p in spec['sheets'].items()}
    for name, p in spec['pieces'].items():
        px, py, inner = table[name]['at']
        w, h = inner[2] - inner[0], inner[3] - inner[1]
        got = atlas.crop((px, py, px + w, py + h))
        want = sheets[p['sheet']].crop(inner)
        if got.tobytes() != want.tobytes():
            sys.exit(f'{name}: packed pixels differ from the source')
        # what trimming dropped has to be fully transparent
        full = Image.new('RGBA', (p['rect'][2] - p['rect'][0], p['rect'][3] - p['rect'][1]), (0, 0, 0, 0))
        full.paste(want, (inner[0] - p['rect'][0], inner[1] - p['rect'][1]))
        if full.getchannel('A').tobytes() != sheets[p['sheet']].crop(tuple(p['rect'])).getchannel('A').tobytes():
            sys.exit(f'{name}: trimming dropped visible pixels')


def lua(spec, atlas, table):
    rel = os.path.relpath(os.path.join(ROOT, os.path.dirname(spec['output'])), ROOT).replace('\\', '/')
    lines = [
        f'-- Generated by tools/pack_art.py from {os.path.dirname(spec["sheets"][next(iter(spec["sheets"]))])}/pieces.json. Don\'t edit;',
        '-- change the pieces and run it again. Each piece: atlas coords u0, u1, v0, v1, then what trimming took off its',
        '-- left, top, right and bottom, as fractions of its original size, then that size in pixels.',
        'local _, NS = ...',
        'local S = NS.Style',
        f'S.RegisterAtlas("{spec["name"]}", "{os.path.splitext(os.path.basename(spec["output"]))[0]}", {{',
    ]
    for name in sorted(table):
        c, t = table[name]['coords'], table[name]['trim']
        nums = ', '.join([f'{v:.6f}' for v in c + t] + [str(v) for v in table[name]['size']])
        lines.append(f'\t{name} = {{ {nums} }},')
    lines.append('})')
    lines.append(f'-- {atlas.width}x{atlas.height}, in {rel}')
    return '\n'.join(lines) + '\n'


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    check = '--check' in sys.argv
    if len(args) != 1:
        sys.exit(__doc__)
    with open(os.path.join(ROOT, args[0]), encoding='utf8') as f:
        spec = json.load(f)
    atlas, table = build(spec)
    verify(spec, atlas, table)
    text = lua(spec, atlas, table)
    out, lua_path = os.path.join(ROOT, spec['output']), os.path.join(ROOT, spec['atlas'])
    if check:
        saved = Image.open(out).convert('RGBA')
        with open(lua_path, encoding='utf8') as f:
            same_lua = f.read() == text
        if saved.size != atlas.size or saved.tobytes() != atlas.tobytes() or not same_lua:
            sys.exit('atlas is out of date: run tools/pack_art.py ' + args[0])
        print('atlas up to date')
    else:
        os.makedirs(os.path.dirname(out), exist_ok=True)
        atlas.save(out, compression='tga_rle')
        with open(lua_path, 'w', encoding='utf8', newline='\n') as f:
            f.write(text)
        print(f'{out}: {atlas.width}x{atlas.height}, {os.path.getsize(out)} bytes; {len(table)} pieces')


if __name__ == '__main__':
    main()
