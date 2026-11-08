# Changelog

## v0.16.10 — Specialization themes, localization, HUD customization, and UI fixes (2026-11-08)

**Release:** [v0.16.10](https://github.com/AlinFeraru/YNX/releases/tag/v0.16.10) · [Download YNX.zip](https://github.com/AlinFeraru/YNX/releases/download/v0.16.10/YNX.zip)

This beta release includes:

- Added **27 specialization-inspired HUD background themes** and WoW class-colour border styling.
- Expanded to **Arcane, Modern, and Classic** reactive icon packs.
- Added seven interface languages: **English, Spanish, French, German, Simplified Chinese, Russian, and Korean**.
- Redesigned the Settings navigation and added individual artwork for menus and background panels.
- Added **All Stats** and the ability to combine multiple build sets without duplicating shared statistics.
- Added an option to hide the **%** symbol from percentage-based stat displays.
- Refined frame and layout controls, including FLOAT, BOX, and ROUND options.
- Improved visual preview and randomized two-stat gain-animation demos.
- Reduced redundant HUD redraws and unnecessary Settings texture updates.

### Hotfix 1

- Fixed a Lua runtime error when hovering over a colour-picker swatch (incorrect palette-label reference).

**Known release detail:** The installable **`YNX.zip`** attached to the release is the supported package. The repository source tree and GitHub-generated source-code archives may reflect an older version.

## v0.15.4 — Visual overhaul (2026-11-06)

Major update since v0.10.1:

- Redesigned 29 stat icons; retained the original icon set.
- Modernized Settings: icon-led menus, visual styles, and easier HUD movement (**MOVE HUD** → drag → **DONE**).
- Custom themes and hex colours, with in-game colour wheel for text, border, background, bars, and gain effects.
- Real-time HUD preview, adjustable width, and shared gain-animation renderer.
- Animated stat-change previews, icon pulses, and configurable progress-bar transitions.
- Customizable progress bars, build-goal/conversion/hard-cap markers, and compact sizing.
- Added stat-order row/column dividers and spacer elements.
- Class-independent spell/proc tracking with improved icon lookup.
- Fixed Settings title-bar hit regions and interaction/compatibility issues.

## v0.10.1 — X/Y positioning

- Free HUD dragging without the former virtual-screen clamp.
- Editable X and Y coordinates, 10-unit nudges, and saved position migration.

## v0.10.0 — Frame styles and bars

- Earlier FLOAT, SOFT, BOX, and ROUND HUD modes (SOFT was later removed as redundant).
- Milestone bars, appearance presets, padding, and spacing adjustments.

## v0.9.0 — Interface redesign

- Reorganized STATS, SPELLS, and LOOK.
- Stat ordering, separators, themes, and gain previews.

## v0.8.0 — Proc tracking

- Meter-labelled damage procs, named profiles, and visual options.
