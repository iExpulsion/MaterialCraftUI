"""Copies LuaMaterialUI's Style.lua into an addon, stamped with the commit it came from.

    py -I -X utf8 tools/sync_style.py <addon repo> <addon folder>

Each addon keeps a two-line tools/sync_style.py that calls this one with its own paths. The copy is committed in
the addon, so releases need nothing from this repo. LUAMATERIALUI overrides where this repo is (default: the
folder this script is in).
"""
import os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
LIB = os.environ.get('LUAMATERIALUI', os.path.dirname(HERE))


def git(*args):
    return subprocess.run(['git', '-C', LIB, *args], capture_output=True, text=True).stdout.strip()


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    repo, folder = sys.argv[1], sys.argv[2]
    src = os.path.join(LIB, 'Style.lua')
    dest = os.path.join(repo, folder, 'UI', 'Style.lua')
    rev = git('rev-parse', '--short', 'HEAD') or 'unknown'
    changed = git('status', '--porcelain', '--', 'Style.lua') != ''
    stamp = f'{rev}{" with uncommitted changes" if changed else ""}'
    with open(src, encoding='utf8', newline='') as f:
        body = f.read()
    header = f'-- Vendored from LuaMaterialUI {stamp}. Change it there, then run tools/sync_style.py.\n'
    with open(dest, 'w', encoding='utf8', newline='\n') as f:
        f.write(header + body)
    print(f'{dest}  <-  LuaMaterialUI {stamp}')


if __name__ == '__main__':
    main()
