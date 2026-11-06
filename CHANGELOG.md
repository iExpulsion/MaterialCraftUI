# Changelog

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
