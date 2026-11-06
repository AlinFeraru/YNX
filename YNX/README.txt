YNX — Your Numbers eXposed 0.15.4
Author: Ynx
Azeroth Survivors / WoW 1.12 / Lua 5.0

INSTALL
Extract YNX/ into benilla-config/AddOns/YNX/ and restart the game.
Browser client: install the ZIP from Options > AddOns.
Keep your SavedVariables (ABASettingsDB) to preserve existing selections,
profiles, positions, class-specific tracking and colour settings.

CONTROLS
Click the HUD to open Settings. Drag the Settings title bar to move it.
M (upper right): close Settings and enter HUD move/resize mode.
Drag anywhere on the HUD; drag the corner grip to resize; click DONE to
return to Settings. R: center Settings. X: close.
The HUD and Settings store their positions independently.

NEW SETTINGS
LOOK has six clear icon-led pages, with a persistent live HUD preview:
 LAYOUT — columns, width, position, row/column gaps and padding.
 THEMES — visual theme tiles, six-colour custom palette and colour picker.
 FRAME  — pictorial frame selectors, opacity, shape and visual presets.
 TEXT   — icon/text/both modes, fonts, sizes, modern/classic icon packs.
 BARS   — bar length, thickness, fill, animation, goal and cap markers,
          width presets, bar X/Y offset, and ready-screen visibility.
 FX     — gain previews, pulse, colour flashes and animation presets.

The live preview uses your selected stats, order, frame, gap and bar settings.
Drag the preview's <> handle to resize the real HUD, or click -/+ below it.
The PLAY HUD GAIN ANIMATION button simulates a gain without changing stats.
It calls the same animation routine used by the real HUD.

STATS > CORE / ADVANCED: choose which of the 29 stats to display.
STATS > ORDER: rearrange stats with ^/v. Press + on a stat to insert:
  ROW LINE: a full-row divider between groups of stats.
  COL LINE: a column-height divider between grid columns.
  SPACER: a blank full row.
Inserted elements appear in ORDER as their own rows. Press X to remove.
Select ORDER to reveal separator/spacer thickness, length and gap controls
in the right-hand panel beside the HUD preview.
STATS > PRESETS: built-in stat presets and three named custom profiles.
SPELLS > ABILITIES / PROCS: track actual game-provided spell/proc sources.
INSIGHTS: view available run and spell metrics.

BAR BEHAVIOUR
'Bars on ready screen' means show the milestones before moving to start a run
when the game supplies a valid numeric value.
The new recommended bar length is 72% of stat-cell width, and it is
configurable between 30% and 120%. Existing custom settings are preserved
except a previous untouched 100% default migrates once to 72%.
Goal and hard-cap markers have separate toggles. Haste 60% is a build
GOAL, not a universal soft cap. Armor and movement-speed caps are shown
where game data permits. The soft-cap option never invents unverified caps.

THEMES & CUSTOM COLOURS
Click a swatch for the in-game colour picker; hex values are also accepted.
Manual palette accepts six-digit RGB colours (for example #44CCEE) for:
main text, secondary text, background, border, bar fill and gain effect.
Click a swatch or APPLY to set a colour, or disable 'Use my colours' for theme colours.
Changing to a theme resets use of the manual palette without losing hex values.

COMMANDS
/ynx settings | lock | unlock | reset | stop | export | import <code> | debug

UPDATING
Keep a backup of the previous release ZIP before upgrading.
Do not delete SavedVariables when replacing the addon folder.
