# Brainrot Blitz v7

[![Competition](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Rank](https://make.fun/badge/roblox-brainrot-01/nagajaja02-pixel/makefun-roblox-brainrot-01-v7/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Reward](https://make.fun/badge/roblox-brainrot-01/nagajaja02-pixel/makefun-roblox-brainrot-01-v7/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

An incremental harbor tycoon update with server-validated basketball combat, polished harbor lighting, cached global cash/steal/rebirth boards, forty collectible creatures, a paginated 3D collection index, rebirth progress, seven recurring events, and six protected admin events.

[Play the existing experience](https://www.roblox.com/games/105239944014039). Local source changes must be published separately before they appear live.

Build with `~/.local/bin/rojo build -o game.rbxl`. Run `python3 tests/run.py` for source compilation and deterministic module tests. Run `MAKEFUN_OUTPUT_DIR=/tmp/blitz-output node main.ts` to package the prebuilt place without removing the output directory. The entrypoint never builds the place.

Admin access is configured by numeric user ID in `src/server/AdminConfig.luau`. The server also permits the owner of a user-owned experience by default. Group-owned experiences require explicit trusted IDs. There is no public admin command or client-controlled whitelist.

Events begin after two minutes, last ninety seconds, and rotate every ten minutes. Admin events use the same exclusive event slot and restoration path. Rewards add through the original money service; base income and rebirth rules retain their original formulas. New collection and leaderboard stores are separate from the original rebirth store.

Tests use lightweight Roblox substitutes for module logic, not Roblox rendering or live DataStores. Studio playtesting and mobile performance measurements remain necessary before publishing. No copyrighted visual or animation assets were added: the update uses original primitive geometry and procedural effects.
