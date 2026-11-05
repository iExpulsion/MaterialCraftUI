"""Runs LuaMaterialUI's offline tests against a mocked 3.3.5 client.

Usage: py -I -X utf8 test/run.py [test.lua ...]   (default: every test/*_test.lua)
Each test loads Style.lua as an addon would, with an addon name and an addon table.
"""
import glob, os, sys
from lupa import lua51

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def run(path):
    L = lua51.LuaRuntime(unpack_returned_tuples=True)
    L.execute(open(os.path.join(HERE, 'mock.lua'), encoding='utf8').read())
    L.execute('NS = {}')
    loader = L.eval('function(src) local f, err = loadstring(src, "Style.lua") if not f then error(err) end f("TestAddon", NS) end')
    loader(open(os.path.join(ROOT, 'Style.lua'), encoding='utf8').read())
    L.execute(open(path, encoding='utf8').read())
    return L.globals().MOCK.failures


def main():
    paths = sys.argv[1:] or sorted(glob.glob(os.path.join(HERE, '*_test.lua')))
    failed = 0
    for path in paths:
        print(f'== {os.path.basename(path)}')
        failed += run(path)
    print('FAILED: %d' % failed if failed else 'all passed')
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()
