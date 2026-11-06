"""Copies MaterialCraftUI's Style.lua into an addon, stamped with the version it came from: a tag such as v1.0.0,
or the tag plus the commits since (v1.0.0-2-gabc1234). Each skin named after it comes along too: its folder in
Skins (Atlas.lua, Skin.lua and its texture) goes to the addon's UI/Skins.

    py -I -X utf8 tools/sync_style.py <addon repo> <addon folder> [skin ...]

Each addon keeps a two-line tools/sync_style.py that calls this one with its own paths and skins. The copy is
committed in the addon, so releases need nothing from this repo. MATERIALCRAFTUI overrides where this repo is
(default: the folder this script is in). The addon's .toc lists UI\\Style.lua, then for each skin
UI\\Skins\\<Skin>\\Atlas.lua and UI\\Skins\\<Skin>\\Skin.lua.
"""
import os, shutil, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
LIB = os.environ.get('MATERIALCRAFTUI', os.path.dirname(HERE))


def git(*args):
    return subprocess.run(['git', '-C', LIB, *args], capture_output=True, text=True).stdout.strip()


def stamp_for(path):
    rev = git('describe', '--tags', '--always') or 'unknown'
    changed = git('status', '--porcelain', '--', path) != ''
    return f'{rev}{" with uncommitted changes" if changed else ""}'


def copy_lua(src, dest, stamp):
    with open(src, encoding='utf8', newline='') as f:
        body = f.read()
    header = f'-- Vendored from MaterialCraftUI {stamp}. Change it there, then run tools/sync_style.py.\n'
    with open(dest, 'w', encoding='utf8', newline='\n') as f:
        f.write(header + body)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    repo, folder, wanted = sys.argv[1], sys.argv[2], sys.argv[3:]
    ui = os.path.join(repo, folder, 'UI')
    stamp = stamp_for('Style.lua')
    copy_lua(os.path.join(LIB, 'Style.lua'), os.path.join(ui, 'Style.lua'), stamp)
    print(f'{os.path.join(ui, "Style.lua")}  <-  MaterialCraftUI {stamp}')
    for name in wanted:
        src = os.path.join(LIB, 'Skins', name)
        if not os.path.isdir(src):
            sys.exit(f'no skin {name} in {os.path.join(LIB, "Skins")}')
        dest = os.path.join(ui, 'Skins', name)
        os.makedirs(dest, exist_ok=True)
        skin_stamp = stamp_for(os.path.join('Skins', name))
        for file in sorted(os.listdir(src)):
            if file.endswith('.lua'):
                copy_lua(os.path.join(src, file), os.path.join(dest, file), skin_stamp)
            else:
                shutil.copyfile(os.path.join(src, file), os.path.join(dest, file))
        print(f'{dest}  <-  MaterialCraftUI {skin_stamp}')


if __name__ == '__main__':
    main()
