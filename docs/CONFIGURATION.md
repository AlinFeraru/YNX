# YNX configuration guide (v0.15.4)

Open Settings by clicking the HUD or typing `/ynx settings`.

## STATS

- **CORE / ADVANCED:** enable the statistics you want displayed.
- **ORDER:** reorder visible stats and insert separator or spacer elements.
- **PRESETS:** apply build layouts or save/load your named profiles.

## SPELLS

Manage learned abilities and damage procs reported by the game's built-in damage meter. Proc data cannot reveal every hidden effect. Icon lookup uses available class/spell data where possible.

## LOOK

- **LAYOUT:** vertical/horizontal/grid, columns, gaps, scale, manual width, X/Y.
- **THEMES:** choose a theme or enable custom colours; click colour swatches to open the wheel, or use hex values.
- **FRAME:** choose Float, Soft, Box, Round or Roundless; customize padding, borders and opacity.
- **TEXT:** choose modern/classic icons, font family, label style, icon and number sizing.
- **BARS:** milestone gauges, width/thickness, colours, animation and supported threshold markers.
- **FX:** gain preview duration, icon pulses, flashes and related effects.

The **live preview** shows selected stats with the chosen layout, styling and bar options. Its width controls adjust the real HUD width. **MOVE HUD** closes Settings so you can drag/resize the HUD; **DONE** returns to Settings.

### Cap and milestone terminology

- **Build goals** (e.g. 60%/75% Haste) are optional progress targets, not verified global caps.
- **Conversion thresholds:** Crit Chance 100% and Echo 100% have overflow effects.
- **Hard caps:** Armor normally 60% damage reduction (conditional Titan exception) and Movement Speed +120%.
- **Soft caps:** No universal soft-cap markers are presented without verified evidence. Individual abilities can have cooldown floors.

For interpretation, consult the in-add-on stat tooltips and `YNX/CAPS-AND-MILESTONES.md`.

## Position and saved settings

HUD position uses X/Y from top-left. Use `/ynx reset` if the HUD is lost. SavedVariables `ABASettingsDB` stores your settings and profiles and should be preserved when updating.

**Compatibility:** WoW 1.12 / Lua 5.0-compatible Azeroth Survivors client.
