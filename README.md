# LuaMaterialUI

A flat dark style kit for World of Warcraft 3.3.5 addons, built on Material 3 color roles: surfaces, one accent
color, 1px borders, hover and press state layers, and Material's filled, tonal and text button kinds.

It's one file, `Style.lua`, that each addon ships its own copy of. Nothing is shared at runtime, so updating one
addon never changes another.

## What's In It

- **Colors:** `S.colors` (window, sidebar, panel, well, border, accent, text, muted, good, warn, bad...),
  `S.QualityColor(q)`, `S.Hex(color, text)`.
- **Spacing:** `S.PAD`, `S.GAP`, `S.CONTROL_H`.
- **Text:** `S.Text`, `S.FontString`, `S.SetFont`, `S.RefreshFonts` (reads the stock fonts again, for UI addons
  that restyle them), `S.Count`.
- **Shapes:** `S.Panel`, `S.Solid`, `S.Rule`, `S.ScrollBar`, `S.SectionHeading`.
- **Controls:** `S.Button` (kinds `primary`, `secondary`, `selected`, `danger`, `ghost`; `SetText`, `SetLabel`,
  `SetKind`), `S.AddArrow`, `S.Check`, `S.Dropdown`, `S.Input` (one line, or several with `lines`).
- **Closing things:** `S.Dismiss`, `S.OnDismiss`, `S.CloseMenus`, `S.TrackPopup`, `S.TrackInput`. A press anywhere
  else closes open menus and popups and takes focus from inputs.

## Using It in an Addon

1. List `UI\Style.lua` in the addon's `.toc`, before anything that uses it.
2. Read it as `NS.Style` from the addon table (`local _, NS = ...`). Font objects are named after the addon, so
   copies in different addons never clash.
3. Add a two-line `tools/sync_style.py` to the addon that runs this repo's `tools/sync_style.py` with the addon's
   repo and folder. Run it after changing the kit here, test the addon, and commit the copy.

## Tests

```bash
py -I -X utf8 test/run.py
```

The tests need [lupa](https://pypi.org/project/lupa/).
