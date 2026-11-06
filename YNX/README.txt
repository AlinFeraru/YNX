YNX — Your Numbers eXposed v0.10.1
Author: Ynx

INSTALL
Windows/Linux: replace the previous YNX folder in benilla-config/AddOns/YNX/.
Browser client: Options -> AddOns -> install the ZIP.
Do not delete your saved variables if you want to keep profiles.

HOW TO USE
- Click the compact HUD to open Settings; Settings stays centered.
- STATS > CORE / ADVANCED: choose what to track (ON green; OFF grey).
- STATS > ORDER: reorder tracked stats with ^ / v. Use '-' or '|' after
  an entry to insert or remove a divider. Change row spacing below.
- STATS > PRESETS: built-in presets or named custom slots.
- LOOK > LAYOUT: size, layout, and combined MOVE+RESIZE lock.
  X is measured rightward from the UI's left origin; Y downward from its top origin.
  Type exact X/Y values and press Enter, or use +/- to nudge by 10 UI units.
  Dragging no longer clamps the HUD to the virtual UIParent rectangle.
  Signed X/Y values are supported; RESET POSITION or /ynx reset recovers a lost HUD.
  v0.10 saved positions migrate automatically to the new X/Y format.
- LOOK > THEMES: preview skins and choose border accent.
- LOOK > FRAME: FLOAT (no background/border), SOFT, BOX, ROUND; adjust padding and opacity.
  COMPACT, READABLE and SHOWCASE apply quick HUD style presets without changing tracked stats.
  All 3 style presets keep milestone bars on (COMPACT uses a slim 2px bar).
- LOOK > TEXT: icons, number size, icon brightness, icon-to-value spacing.
- LOOK > EFFECTS: optional delayed stat gain preview, pulse and colour highlights.
- LOOK > BARS: milestones for Crit, Haste, Echo, Armor and Speed, with preview, thickness and colours.
- SPELLS > PROCS: any proc damage source that the game's meter identifies.

STAT GAIN PREVIEW
If Critical Chance rises from 25% to 28.4%, the HUD briefly shows
'25% +3.4%' in green, then '28.4%'. The delay can be set from 1-5 seconds.
The text is driven by observed game statistics and does not predict upgrades.

COMMANDS
/ynx settings | lock | unlock | reset | stop | export | import <code> | debug

NOTES
Actual game behaviour can differ from a simulated client. Keep the
previous working ZIP until the new UI is verified in Azeroth Survivors.
