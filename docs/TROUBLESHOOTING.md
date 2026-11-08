# YNX troubleshooting (v0.16.10)

## The addon does not load

1. Install the **`YNX.zip`** asset from the [v0.16.10 release](https://github.com/AlinFeraru/YNX/releases/tag/v0.16.10). Do not install GitHub's generated source-code ZIP.
2. Verify that **`YNX.toc`** is directly inside the addon folder, for example **`benilla-config/AddOns/YNX/YNX.toc`**, not **`YNX/YNX/YNX.toc`**.
3. Remove any old **`YNX`** addon folder before extracting the new version to avoid mixing files from two builds.
4. Restart Azeroth Survivors.
5. Confirm you are using the supported game/client build.

## A Lua error appears

Copy the **entire error message**, including the filename, line number, and function or variable name. Report it using the [bug report form](https://github.com/AlinFeraru/YNX/issues/new/choose).

For errors involving missing images or UI elements, first verify the complete release archive was extracted, including the **`Media/`** folder.

**Colour-picker tooltip error:** v0.16.10 contains the palette-label hotfix. If you still see an error mentioning **`paletteLabels`**, remove the old addon folder completely and install the current release ZIP.

## The HUD is off-screen

Try **`/ynx reset`**. Open **LOOK → LAYOUT** to adjust coordinates and layout.

## The menu/header/background image looks wrong

- Make sure all asset files are under **`YNX/Media/`**.
- Do not mix old and new addon versions.
- Restart the client after replacing the folder.
- Report the UI scale, game resolution, and a screenshot if the issue persists.

## Progress bars are missing

Open **LOOK → BARS** and confirm bars are enabled. Some indicators require a supported stat value, threshold, or current game state.

## A tracked spell or proc is missing

Some procs appear only when the game records them as separate damage sources. Passive bonuses and hidden effects without attributed damage may not be available to YNX.

## Settings or profiles reset unexpectedly

Preserve **`ABASettingsDB`** in the game's SavedVariables area when replacing the addon. Do not delete account/character SavedVariables as part of a routine update.

## Report a bug

Include the installed YNX version, client version if known, reproduction steps, expected and actual results, exact Lua error, and screenshots. Please do **not** post private account details or SavedVariables containing personal information.
