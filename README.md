# YNX — Your Numbers eXposed

**Your build. Your stats. Your HUD.**

YNX is a customizable character-stat HUD for **Azeroth Survivors**. Track 29 stats, follow upgrades during runs, and design a compact HUD around your build.

**Latest version: v0.15.4** · **Author: Ynx**

[Download the latest release](https://github.com/AlinFeraru/YNX/releases/latest) · [SurvivorsForge](https://forge.rezondes.net/addons/ynx) · [Report an issue or suggest a feature](https://github.com/AlinFeraru/YNX/issues/new/choose)

## Features

- **29 character statistics:** Damage, Crit, Haste, Echo, Armor, movement, Luck, DoT bonuses, and more.
- **Modern HUD art:** redesigned icons with an optional classic icon pack, adjustable fonts, sizes and spacing.
- **Animated upgrades:** gain previews, icon pulses, colour flashes and smooth milestone bars.
- **Appearance editor:** ten themes, visual frame styles, a built-in colour wheel, manual palettes and adjustable transparency.
- **Layout controls:** vertical, horizontal and grid arrangements; custom ordering, dividers, spacers, row/column gaps and direct drag-to-position.
- **Live HUD preview:** choose your stats and style, resize the HUD and try the gain animation from Settings.
- **Build presets and profiles:** swap configurations without losing your preferred selections.
- **Spell and proc tracking:** displays learned abilities and observable proc damage supplied by the game's meter, with class-independent icon matching.
- **Milestone indicators:** distinguish personal build goals, Crit/Echo conversion thresholds and supported hard caps; avoid inventing soft caps.

## Install

**SurvivorsForge:** Install YNX using the SurvivorsForge launcher.

**Manual:**
1. Download the **`YNX.zip`** asset from the [latest GitHub release](https://github.com/AlinFeraru/YNX/releases/latest).
2. Extract the `YNX` folder into `benilla-config/AddOns/`.
3. Confirm `benilla-config/AddOns/YNX/YNX.toc` exists, then restart Azeroth Survivors.

**Updating:** Replace the old add-on folder, but keep your SavedVariables to retain profiles, colours and settings (`ABASettingsDB`).

## Getting started

Click the HUD or type `/ynx settings`. The Settings window has four sections: **STATS**, **SPELLS**, **LOOK**, and **INSIGHTS**.

To reposition the HUD, click **MOVE HUD** in Settings, drag the HUD to its new position, then click **DONE**. The LOOK pages provide layouts, themes, frame styles, text/icons, bars and animation effects.

Commands: `/ynx settings`, `/ynx unlock`, `/ynx lock`, `/ynx reset`; type `/ynx` for more options.

See the [configuration guide](docs/CONFIGURATION.md), [changelog](CHANGELOG.md), and [troubleshooting guide](docs/TROUBLESHOOTING.md).

## Feedback and issues

**Found a bug, an incorrect stat threshold or a UI issue? Have a suggestion?**
Please leave a comment on [SurvivorsForge](https://forge.rezondes.net/addons/ynx/comments) or [open a GitHub issue](https://github.com/AlinFeraru/YNX/issues/new/choose). Include your version, what happened, reproduction steps, and a screenshot or exact Lua error when possible.

## Technical notes

YNX targets the game's **WoW 1.12 / Lua 5.0-compatible** add-on environment. Proc tracking is limited to damage sources exposed by Azeroth Survivors; it cannot identify every hidden effect or activation.

The [v0.15.4 release ZIP](https://github.com/AlinFeraru/YNX/releases/tag/v0.15.4) is the installable, security-scanned artifact. The `YNX/` folder in this repository contains add-on source and bundled game textures.

YNX is an independent community project, not officially affiliated with Azeroth Survivors.

**License:** No separate source-code redistribution/derivative-works licence has been selected. Contact the author before redistributing modified source.
