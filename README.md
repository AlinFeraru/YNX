# YNX — Your Numbers eXposed

**Your build. Your stats. Your HUD.**

YNX is a customizable character-stat HUD for **Azeroth Survivors**. Keep the information that matters to your build visible, track upgrades, and tailor the HUD to your preferred playstyle.

**Current release: [v0.16.10 (beta, hotfix 1)](https://github.com/AlinFeraru/YNX/releases/tag/v0.16.10)**

[**Download YNX.zip**](https://github.com/AlinFeraru/YNX/releases/download/v0.16.10/YNX.zip) · [SurvivorsForge](https://forge.rezondes.net/addons/ynx) · [Report a bug or suggest a feature](https://github.com/AlinFeraru/YNX/issues/new/choose)

## Features

- **29 tracked statistics** including Damage, Crit, Haste, Echo, Armor, survivability, movement, Luck, and DoT effects.
- **Three reactive icon packs:** Arcane, Modern, and Classic, with visual reactions to stat gains.
- **27 specialization-themed HUD backdrops**, with WoW class-colour borders and an independent palette system.
- **Flexible layouts:** vertical, horizontal, grid, columns, spacing, ordering, separators, and manual positioning.
- **Build presets you can combine:** select multiple sets without duplicating shared stats; includes **All Stats** and named saved profiles.
- **Custom appearance:** frame shape, border width, transparency, text size, icon size, bar styles, and optional % symbols.
- **Live HUD preview** with gain-animation testing and customizable milestone indicators.
- **Spell and proc tracking** for abilities and separately recorded damage sources exposed by the game.
- **Seven interface languages:** English, Spanish, French, German, Simplified Chinese, Russian, and Korean.

YNX can display only data exposed by the game. Not all hidden card, talent, or proc effects are available to addons.

## Install

**SurvivorsForge:** Install YNX through the [SurvivorsForge listing](https://forge.rezondes.net/addons/ynx).

**Manual installation:**
1. Download **[YNX.zip](https://github.com/AlinFeraru/YNX/releases/download/v0.16.10/YNX.zip)** from the release assets.
2. Extract the single **`YNX`** folder into your game's addons directory (commonly **`benilla-config/AddOns/`** for the Azeroth Survivors desktop client).
3. Confirm the result is **`benilla-config/AddOns/YNX/YNX.toc`** — **not** **`YNX/YNX/YNX.toc`**.
4. Restart the game.

**Updating:** Replace the existing **`YNX`** addon folder with the new one. Preserve your SavedVariables (**`ABASettingsDB`**) to keep layouts, colours, tracking choices, and profiles. If an update behaves oddly, remove the old addon folder before extracting again, rather than mixing versions.

> **Important:** Install the **`YNX.zip` release asset**. GitHub's automatically generated *Source code (zip/tar.gz)* archives represent the tagged repository snapshot and may not match the current addon build. The release asset is the authoritative installable package for v0.16.10.

## Getting started

Open Settings by clicking the HUD or using **`/ynx settings`**. The interface is organized into four main sections:

| Section | What it controls |
| --- | --- |
| **STATS** | Pick stats, combine build sets, organize HUD order, and save profiles. |
| **SPELLS** | Track available abilities and recorded damage procs. |
| **LOOK** | Change layout, icon pack, specialization backdrop, frame, text, bars, and animations. |
| **INSIGHTS** | Inspect the supported run, spell, trend, and reference information. |

To move your HUD, click **MOVE HUD**, drag it, then choose **DONE**. Select a language using the **LANG** control in the top bar.

Common commands: **`/ynx settings`**, **`/ynx unlock`**, **`/ynx lock`**, **`/ynx reset`**. Use **`/ynx`** to see additional commands.

See [Configuration](docs/CONFIGURATION.md), [Troubleshooting](docs/TROUBLESHOOTING.md), [Release notes](RELEASE_NOTES-v0.16.10.md), and the [Changelog](CHANGELOG.md).

## Feedback

Found a visual problem, incorrect stat, Lua error, or a feature worth adding? Please [open a GitHub issue](https://github.com/AlinFeraru/YNX/issues/new/choose) or comment on [SurvivorsForge](https://forge.rezondes.net/addons/ynx/comments). Include the addon version, steps to reproduce, and screenshots or the exact Lua error when possible.

## Compatibility and source

YNX targets the **WoW 1.12 / Lua 5.0-compatible** environment used by Azeroth Survivors. The addon is an independent community project and is not officially affiliated with Azeroth Survivors or Blizzard.

**Source availability:** The **`YNX/`** folder on **`main`** is now synchronized with the v0.16.10 release asset. The existing **v0.16.10 tag** was created before that sync, so GitHub's automatically generated *Source code* archives for that tag still reflect the earlier commit. For installation, use the uploaded **`YNX.zip`** asset.

**Licensing:** No separate source-code redistribution or derivative-works license has been selected. Contact the author before redistributing modified source.
