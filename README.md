# YNX — Your Numbers eXposed

**A free, customisable character-stat HUD for Azeroth Survivors.**  
**Author:** Ynx · **Current version:** v0.10.1

YNX provides a compact overview of your character's stats, spells and observable damage procs. Choose what matters to your build, arrange it how you like, and keep your screen clean during a run.

**[⬇ Download YNX v0.10.1 (install-ready ZIP)](https://raw.githubusercontent.com/AlinFeraru/YNX/main/downloads/YNX-Your-Numbers-eXposed-v0.10.1.zip)** · [Configuration guide](docs/CONFIGURATION.md) · [Troubleshooting](docs/TROUBLESHOOTING.md) · [Changelog](CHANGELOG.md)

## Features

- **29 character statistics**, including critical chance, critical damage, haste, echo, armor, AoE, DoT and situational bonuses.
- **Build presets and named profiles** for quick switching between different HUD configurations.
- **Custom ordering**, stat separators and compact, grid or vertical layouts.
- **Milestone bars** for critical chance, haste, echo, armor and movement speed, with configurable thickness and colours.
- **Stat gain preview:** see an increase such as `25% +3.4%` highlighted temporarily before the value settles at `28.4%`.
- **10 colour themes** and HUD frame styles: Float (borderless), Soft, Box and Round.
- **Detailed LOOK settings:** layout, frame, font/icon sizing, colors, animation and bars.
- **Spell and observable proc tracking.** Proc entries are taken from the game's meter, and appear only when that source has registered damage.
- **Insights** for run information and spell performance using the data the game supplies.
- **Free X/Y positioning** (v0.10.1): drag past old virtual screen boundaries or enter exact coordinates.

## Install

### Desktop (Windows/Linux)

1. [Download the **v0.10.1 installer ZIP**](https://raw.githubusercontent.com/AlinFeraru/YNX/main/downloads/YNX-Your-Numbers-eXposed-v0.10.1.zip) (it contains one top-level `YNX` directory).
2. Extract the `YNX` folder to `benilla-config/AddOns/YNX/` next to your Azeroth Survivors executable.
3. Confirm that `benilla-config/AddOns/YNX/YNX.toc` exists (avoid an extra nested `YNX/YNX/` directory).
4. Restart the game or re-enter the world so the add-on loads.

### Browser version

Open **Options → AddOns** in the game and install the [downloadable add-on ZIP](https://raw.githubusercontent.com/AlinFeraru/YNX/main/downloads/YNX-Your-Numbers-eXposed-v0.10.1.zip).

### Updating

Replace the old `YNX` add-on folder. **Keep your SavedVariables** if you want to preserve your profiles and settings. The database variable currently used by YNX is `ABASettingsDB`.

## How to use

- **Click the HUD** to open Settings. The Settings window remains centered.
- **STATS → CORE / ADVANCED:** choose what to track.
- **STATS → ORDER:** move chosen stats and add optional separators.
- **STATS → PRESETS:** apply build presets or save/load named configurations.
- **SPELLS:** track spells and separately identified damage procs.
- **LOOK → LAYOUT:** adjust arrangement, scale, width, and edit/move/resize controls. Enter signed X/Y coordinates or use +/- nudges.
- **LOOK → FRAME:** choose FLOAT (no box), SOFT, BOX, or ROUND and adjust opacity/padding.
- **LOOK → TEXT / EFFECTS / BARS:** adjust the HUD's text, icons, animations and milestone gauges.

### Slash commands

`/ynx settings` · `/ynx lock` · `/ynx unlock` · `/ynx reset` · `/ynx stop` · `/ynx export` · `/ynx import <code>` · `/ynx debug`

For an explanation of configuration options and what YNX can and cannot detect, see the [Configuration guide](docs/CONFIGURATION.md).

## Known limitations

- The game's add-on interface is based on **WoW 1.12 / Lua 5.0**, not modern WoW APIs.
- Proc tracking can display **damage sources identified by the game's meter**; this does not mean every internal talent or proc activation can be observed.
- Source data and UI capabilities may change with game updates.
- This project is an independent community add-on, not an official Azeroth Survivors project.

## Issues and feedback

Open a GitHub Issue with the game version, add-on version, what you clicked, expected/actual behaviour, and the exact Lua error if one appears. Screenshots help.

## License

YNX is provided **free for players to download and use**. A separate source-code licence for redistribution or derivative works has **not yet been selected** by the author. If you want to contribute code or republish modified versions, contact Ynx first.

*The distributable game add-on lives in the `YNX/` folder. The root-level files are for project documentation.*
