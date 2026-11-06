# Troubleshooting

## Add-on does not load

1. Confirm the add-on exists at `benilla-config/AddOns/YNX/YNX.toc` for the desktop client. Avoid `YNX/YNX/YNX.toc`.
2. Restart the client (or return to the world when supported).
3. Check that your game build supports the documented Azeroth Survivors add-on APIs.

## HUD is off-screen

Type `/ynx reset` to restore default positioning. Then open **LOOK → LAYOUT** for numeric X/Y positioning.

## Progress bars are missing

Open **LOOK → BARS** and make sure the gauges are enabled. Their values require valid game statistics; some indicators may be hidden when a stat is unavailable.

## A proc is missing from SPELLS

A proc appears only when the game meter records it as a separate damage source. Passive bonuses and hidden talent triggers with no separately attributed damage aren't exposed.

## Report a bug

Open a GitHub Issue with your YNX version, game/client build, steps to reproduce, expected result, actual result, and any Lua error. Include a screenshot if relevant. Do not post account identifiers or SavedVariables containing personal information.
