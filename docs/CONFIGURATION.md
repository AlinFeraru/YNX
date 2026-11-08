# YNX configuration guide — v0.16.10

Open Settings by clicking the HUD or typing **`/ynx settings`**.

## STATS

- **CORE / ADVANCED:** choose which statistics are shown on the HUD.
- **ORDER:** reorder tracked stats and add line or space elements.
- **SETS / PRESETS:** click a ready-made stat set to select it; click again to remove it. **Multiple sets can be enabled together**. Overlapping statistics appear once, not multiple times.
- **ALL STATS:** enable every supported statistic in one set.
- **Named profiles:** save and load your own stat selections and ordering.

If you manually customize individual stats, the selected preset combination may be cleared to reflect that custom configuration.

## SPELLS

Track supported learned abilities and separately recorded damage procs. The game must expose this information through its spell or damage systems. YNX cannot reliably identify every hidden activation or card effect.

## LOOK

- **LAYOUT:** choose vertical, horizontal, or grid arrangements; adjust columns and spacing.
- **THEMES:** choose a general palette and optionally a **class/specialization backdrop**. There are 27 spec-themed backdrops.
- **FRAME:** **FLOAT**, **BOX**, or **ROUND**. Adjust inner padding, background opacity, and border width. Set border width to 0 for a borderless panel.
- **TEXT:** choose the **Arcane**, **Modern**, or **Classic** icon pack; adjust fonts, labels, icon/number sizes, and whether percentage stats display a **%** symbol.
- **BARS:** customize supported milestone/progress gauges, thickness, width, colours, and markers.
- **FX:** adjust stat-gain previews, icon reactions, flashes, and animation timing.

The **live preview** lets you check appearance before closing Settings. The **PLAY HUD GAIN ANIMATION** control demonstrates two different selected stats when possible.

**MOVE HUD** lets you drag the HUD. Choose **DONE** to finish.

## INSIGHTS

Review the available run information, spell activity, trends, and in-addon notes. Content depends on what the game exposes.

## Language

Select **LANG** in the top bar. Options: English, Español, Français, Deutsch, Chinese (Simplified), Russian, and Korean. The interface may reload when changing language.

## Build goals and caps

- **Build goals** are configurable progress targets, not automatically verified global caps.
- **Conversion thresholds** and supported hard-cap markers apply only where the game data allows them to be calculated.
- YNX does **not** invent universal soft caps or estimate hidden effects that are unavailable through the API.

For individual values and restrictions, check the relevant in-addon tooltips.

## Settings and troubleshooting

SavedVariables (**`ABASettingsDB`**) stores configuration and profiles. Preserve SavedVariables when updating; replace only the addon folder.

If you lose the HUD position, try **`/ynx reset`**. See [Troubleshooting](TROUBLESHOOTING.md).

**Compatibility:** Azeroth Survivors' WoW 1.12 / Lua 5.0-compatible client.
