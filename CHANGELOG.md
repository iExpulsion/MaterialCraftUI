# Changelog

## Unreleased

- **Skins:** `S.UseSkin` switches how controls are drawn, not just their colors. Material, the flat look, is built
  in and stays the default. `S.Skins` lists them for a picker and `S.RegisterSkin` adds one.
- **Cognac Skin:** painted gold frames, plates and chips on dark glass, in `Skins/Cognac`.
- **Classic Skin:** the default UI's own look, in `Skins/Classic`: dialog-box windows, red panel buttons, gold text,
  tooltip-bordered menus and lists, and the quest log's row highlight, all from textures the client ships.
- **Skin-Aware Helpers:** `S.Frame`, `S.Well`, `S.Sidebar`, `S.NavEntry` and `S.Highlight` draw window frames,
  wells, sidebars, navigation entries and hover states in the current skin, and `S.metrics` says how much room a skin's border needs.
- **Tables:** `S.Table` is a virtual table with sortable, stretching columns, icons, group header rows, selection,
  a thin scroll bar and the mouse wheel, drawn in the current skin's well. The demo's Items page uses it.
- **Skinned Menus, Checkboxes and Dividers:** dropdown menus draw in the skin's menu style, and skins can draw
  checkboxes and the dividers under title bars, table headers and beside section headings. Classic and Cognac
  leave out the title bar rule; Cognac draws its gold divider, bezel checkboxes and card-framed text boxes, and its
  menus in the chamfered frame of the tooltip art. `S.Table`'s `plain` option is a bare list for inside a menu.
- **Pixel Alignment:** `S.PixelScale` scales a window so its units are whole screen pixels, so every edge and 1px
  border inside it lands on real pixels; `S.SnapPosition`, `S.PixelSize` and `S.Snap` go with it. The demo uses it.
- **New Color Roles:** `rowHover`, `rowSelected`, `navSelected`, `arrow`, `scrollThumb` and `scrollThumbHover`.
- **Atlas Packer:** `tools/pack_art.py` packs a skin's art into one texture, shrinking each piece cleanly to suit
  the size it's drawn at, since the client has no mipmaps for TGA textures. `S.Art`, `S.PlaceArt`, `S.ArtPart` and
  `S.NineSlice` draw from it.
- **Sync Script:** names skins to copy along with the kit.
- **Demo:** the theme dropdown includes Cognac and Classic.

## 1.0.0

The first public release.

- **Color Roles:** window, sidebar, panel and well surfaces, borders, an accent, text, and good, warning and bad
  colors, all drawn from Material 3 roles. The default is Material 3's baseline dark scheme.
- **Themes:** `S.SetTheme` swaps in your own accent or a whole Material 3 scheme. An accent given without
  `onPrimary` gets readable text worked out for it.
- **Controls:** buttons in five kinds (primary, secondary, ghost, danger and selected) with one shared disabled
  look, checkboxes, dropdowns, and one-line or multi-line inputs with placeholders.
- **Dismissing:** menus, popups and inputs let go on a click anywhere else, and `S.Dismiss` closes them all when a
  view changes. Nothing takes focus on its own.
- **Fonts:** the client's own fonts without their drop shadow, read again when UI addons such as ElvUI restyle them.
  Font objects are named after the addon that loads the kit.
- **Item Qualities:** `S.QualityColor` caches each quality's color and gives heirloom items their link color, which
  the 3.3.5 client's table leaves out.
- **Demo Addon:** `demo/MaterialCraftUIDemo` shows every control in one window, with a theme switcher. Type `/mcui`.
- **Sync Script:** `tools/sync_style.py` copies the kit into an addon and stamps the version it came from.
