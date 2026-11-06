# Azeroth Build Analyzer 0.3.1 — Caps and Milestones

**Checked on 2026-11-05.** Mechanics are reported from community inspection of the game's executable and from the live addon feed, not from playing this build on your particular installation. They may vary in future patches. The addon's indicators use live `AZS_STATS` values.

| Mechanic | What the game does | ABA display | Classification |
|---|---|---|---|
| Armor / Damage Reduction | Normally capped at 60%. Titan capstone raises to 70%. Some talents benefit from above-cap Armor; crowd-mitigation gear can apply afterwards. | Red when default cap is reached, with a Titan exception in the tooltip. | **Hard cap (conditional)** |
| Movement Speed | Movement multiplier stops at x2.20, i.e. +120%. Typical base 7 yd/s, max 15.4 yd/s. | Red at +120%. | **Hard cap** |
| Critical Chance | At 100% eligible hits always crit; excess % converts 1:1 into additional Crit Damage. | Gold at 100%, with overflow. | **Milestone, not hard cap** |
| Echo | At 100%, an extra strike is guaranteed; each further 100% guarantees another. | Gold at 100%, overflow shown. | **Milestone, not hard cap** |
| Haste | The game displays the fraction removed from cooldown; there is no global 75% hard cap. A common spell cooldown minimum is 0.25s, Hellfire 0.5s; Divine Shield has its own behavior. | User targets 60% and 75%, blue progress/gold complete. A spell at its cooldown minimum shows [MIN]. | **Personal milestones + per-spell floor** |
| Area | No global percent cap verified. The game's **spell reach** (yards, not area %) gains logarithmically past 70yd. A spell's radius continues to scale in the normal way. | Explanation in Area hover, no false 70%-Area cap bar. | **Conditional soft reach threshold** |
| DoT applications | The base DoT copy count per target grows with level, up to four. | Research note only until a stable per-target counter is confirmed in the addon feed. | **Mechanic-specific hard max** |
| Luck | No global cap documented. It alters rarity odds; odds vary nonlinearly. | No fixed cap bar. | **No known global cap** |
| Crit Damage, Damage, Pickup, XP, Gold, extra targets | No universal cap established in researched sources. | Current value; no invented limit. | **Unknown / no verified global cap** |

**Key distinction:** A *goal* tells you how close you are to your preferred build, not where the game's stat stops working. *Reached* or *completed* on Crit/Echo means guaranteed activation, not that further investment is wasted. A *hard cap* means the stated stat's direct effect cannot grow further absent an explicit exception.

**Titan detection caveat:** The published addon API does not expose an explicit “Titan capstone active” boolean. ABA shows 60% as the **default** Armor cap and explains Titan's 70% exception. If it receives a value beyond 60%, the gauge changes to 70%. In a Titan build already sitting at exactly 60%, the gauge cannot know the cap was raised, so consult the tooltip.

## Sources
- Source-inspection-based Guide.lua, especially mechanics at lines ~8–52, ~1219, ~1508 and ~1588: https://github.com/morderous/survivor-ui/blob/main/SurvivorUI/Guide.lua
- SurvivorUI Classic release notes explaining haste, Echo and Speed: https://github.com/morderous/survivorui-classic
- Azeroth Survivors public addon API, AZS_STATS and AZS_SPELLS: https://github.com/migwynkriid13/SurvivorsDragonUi/blob/main/docs/AzerothSurvivors-Addon-API-2026-10-15.txt
- Alternative community description of default Armor and Titan: https://azerothsurvivorsgame.com/builds/

## Test your build
- Start a run and check that the tracker reports Armor %, Haste %, Crit % and Speed as on the game's native character panel.
- In Settings choose **CRIT ONLY**. Only Crit Chance and Crit Damage should remain; every equipped spell still appears below.
- Enable Echoes in Settings: this changes to **CUSTOM** and shows Echoes alongside your selected stats.
- During level-up the overlay should appear as a horizontal strip at the top, not cover the three offered cards (the first pick has four).
- Hover a stat label to see its cap logic. Hover a spell to see available spell tooltip text and observed run damage.
- Version may change thresholds; report if your on-screen value differs from what this guide describes.
