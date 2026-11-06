# YNX v0.10.1 — Free X/Y Positioning

**Your Numbers eXposed**, a customizable stat HUD for Azeroth Survivors.

This release replaces the previous constrained HUD dragging behavior with free X/Y positioning. HUD placement is now saved relative to the UI's top-left origin.

## Changes in this release

- Removed a movement clamp that could behave like an invisible box near the centre of the screen.
- Added **X/Y coordinates** in **LOOK → LAYOUT**, including exact input and 10-unit nudges.
- Preserved HUD position across UI-scale, width and size adjustments.
- Added migration for older saved positions.
- Retained `RESET POSITION` and `/ynx reset` for recovery.

## Also included from v0.10.0

- **Milestone bars** for Crit, Haste, Echo, Armor and Movement Speed.
- **HUD frame styles:** Float (borderless), Soft, Box and Round.
- **One-click appearance presets:** Compact, Readable and Showcase.
- Improved icon-to-number spacing and theme options.

## Installing

Use the release asset **`YNX-Your-Numbers-eXposed-v0.10.1.zip`**, not this repository-source archive. Extract its `YNX` folder into `benilla-config/AddOns/`, or upload the ZIP using the browser client's add-on installer.

Existing `ABASettingsDB` saved variables can be retained.

**Tested by the author in-game.** The creator's iterative builds were also checked with simulated Lua tests; these checks are not a certification of all game client versions.
