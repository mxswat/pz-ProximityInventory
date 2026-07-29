## Proximity Inventory — Build 42 Update

### Core fixes

- Removed PZAPI external dependency (PZAPI ships with Project Zomboid B42)
- Added `OnRefreshEnd` handler — force-selected container no longer resets after inventory refresh
- Added `patchMouseWheel` — fixes B42 zoom bug where scrolling while force-selected cycled the camera instead of containers
- Added right-click context menu on proxInv button (Force Selected / Highlight toggles)
- Added Shift+click on proxInv button to toggle force-select
- Added `manualContainerOverride` — clicking a real container while force-select is active keeps focus on it
- Fixed `UI_EN.txt` syntax errors (missing trailing commas)

### Translations

- Added `IG_UI.json`, `UI.json`, `Sandbox.json` alongside existing `.txt` files
- Added Italian (IT) translation
- Added Turkish (TR) translation
- Added French (FR) translation
- Added Ukrainian (UA) translation

### Notes

- The `b42` branch is now `master` (B42 code). The old B41 code lives on the `b41` branch.
- Requires PZ build 42+. B41 is no longer on the default branch.
