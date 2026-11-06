# YNX configuration guide

**Open the settings:** click the HUD or type `/ynx settings`.

## Stats

- **CORE / ADVANCED**: select the statistics displayed on the HUD. Off means hidden; on means displayed.
- **ORDER**: move selected statistics up or down. Optional horizontal/vertical dividers can separate groups; row spacing is adjustable.
- **PRESETS**: switch build layouts or save a personalised named configuration.

## Spells and damage procs

The SPELLS section separates learned abilities from **meter-identified damage procs**. A proc is listed when it has produced damage reported by the game's meter; hidden talent activations without observable damage cannot be counted or inferred.

## Look

- **LAYOUT**: position, scale, width, arrangement and X/Y coordinate inputs. Both positive and negative offsets are supported.
- **FRAME**: FLOAT (no border/background), SOFT (subtle panel), BOX (square border) and ROUND (rounded frame).
- **THEMES**: built-in colour palettes.
- **TEXT**: text/icon sizing, brightness and spacing.
- **EFFECTS / FX**: temporary gain highlights (for example `25% +3.4%` then `28.4%`) and pulse intensity.
- **BARS**: milestone gauges, visibility, colours and thickness for supported stats.

Some page labels may be shortened depending on the client UI.

## Positioning

The HUD uses coordinates relative to the game UI's top-left. X increases rightwards; Y increases downwards. Dragging or entering X/Y changes the same saved position. Use `/ynx reset` if the HUD is moved off-screen.

## Notes on values

The add-on reads game-provided values and cannot guarantee access to every hidden talent node, proc activation, gear source or boss mechanic. Milestone indicators are visual guides to documented thresholds.
