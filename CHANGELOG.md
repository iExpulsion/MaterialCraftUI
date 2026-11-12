# Changelog

## 1.4.1

- **Window Scale Anchors:** `S.SetWindowScale` keeps each window's own anchor point in place, so a window pinned by
  its top right corner, such as a tracker, grows to the left instead of drifting sideways each time the size changes.

## 1.4.0

- **Window Scale:** `S.SetWindowScale` makes every window given `S.PixelScale` bigger or smaller than its designed
  size, for large screens and players who want bigger text. Windows keep their spot on the screen as they resize.
- **Table Group Headers:** `S.Table`'s group header rows no longer call `tooltip` or `onClick`, which were handed
  the header item as if it were a row's.

## 1.3.0

- **Pickers:** `S.Picker` is a searchable, scrolling list that opens under a button like a dropdown, for choices
  too many for a dropdown's menu, and `S.PickerButton` is the dropdown-looking button that opens it. It filters as
  you type and can toggle several entries in multi mode. It started in Synastria Companion.
- **Sliders:** `S.Slider` is a horizontal slider that snaps to its steps and shows its value beside it, formatted
  as you like. Material draws a thin track with an accent fill and handle, and Classic the Interface Options
  slider; skins can draw their own with `slider` and `paintSlider`. The demo's Forms page shows two.
- **Dropdowns in scroll frames:** a dropdown's menu now opens on UIParent at the dropdown's scale. Inside a scroll
  frame it stayed in the scroll frame's layer, under the controls below it, and was cut off at the frame's edge.

## 1.2.0

- **Drag to Reorder:** `S.Reorder` lets the rows of any list be dragged into a new order, and `S.Table`'s
  `onMove(from, to)` option uses it. The dragged row dims, an accent line shows where it will land, its name
  follows the cursor, and holding it at the top or bottom edge scrolls the list. Group header rows don't drag, and
  the release that ends a drag isn't a click. `S.Grip` draws the dotted grip for a drag handle.

## 1.1.0

- **Skins:** `S.UseSkin` switches how controls are drawn, not just their colors. Material, the flat look, is built
  in and stays the default. `S.Skins` lists them for a picker and `S.RegisterSkin` adds one.
- **Cognac Skin:** painted gold frames, plates and chips on dark glass, in `Skins/Cognac`.
- **Classic Skin:** the default UI's own look, in `Skins/Classic`: dialog-box windows, red panel buttons, gold text,
  tooltip-bordered menus and lists, the quest log's row highlight, and the Interface Options tabs, all from
  textures the client ships. A black fill over the see-through dialog background keeps windows and popups readable.
- **Skin-Aware Helpers:** `S.Frame`, `S.Well`, `S.Sidebar`, `S.NavEntry`, `S.Tab` and `S.Highlight` draw window
  frames, wells, sidebars, navigation entries, tabs and hover states in the current skin, and `S.metrics` says how much room a skin's border needs.
- **Tables:** `S.Table` is a virtual table with sortable, stretching columns, icons, group header rows, selection,
  a thin scroll bar and the mouse wheel, drawn in the current skin's well. The demo's Items page uses it.
- **Skinned Menus, Checkboxes and Dividers:** dropdown menus draw in the skin's menu style, and skins can draw
  checkboxes and the dividers under title bars, table headers and beside section headings. Classic and Cognac
  leave out the title bar rule; Cognac draws its gold divider, bezel checkboxes and card-framed text boxes, and its
  menus in the chamfered frame of the tooltip art. `S.Table`'s `plain` option is a bare list for inside a menu.
- **Vertical Dividers:** `S.VerticalDivider` divides two panes side by side: a 1px line, or Cognac's gold spear.
- **Pixel Alignment:** `S.PixelScale` scales a window so its units are whole screen pixels, so every edge and 1px
  border inside it lands on real pixels; `S.SnapPosition`, `S.PixelSize` and `S.Snap` go with it. The demo uses it.
- **Window Placement:** `S.PlaceWindow` puts a window at the shared default spot, top middle of the screen.
- **New Color Roles:** `rowHover`, `rowSelected`, `navSelected`, `arrow`, `scrollThumb` and `scrollThumbHover`.
- **Atlas Packer:** `tools/pack_art.py` packs a skin's art into one texture, shrinking each piece cleanly to suit
  the size it's drawn at, since the client has no mipmaps for TGA textures. `S.Art`, `S.PlaceArt`, `S.ArtPart` and
  `S.NineSlice` draw from it.
- **Sync Script:** names skins to copy along with the kit.
- **Multi-Line Inputs Keep Their Height:** a multi-line edit box sizes itself to its text, so a tall `S.Input`
  shrank or grew with what it held, and layouts and anything anchored below it used the wrong height. The edit box
  is now pinned inside `e.box`, a frame at the height asked for that its box is drawn on, and placing or sizing the
  input places or sizes `e.box`. Its text sits inside a skin's well frame.
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
