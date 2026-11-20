# v8 verification

Implemented in new BatService, CollectionService, and BrainrotIndex client scripts.
Existing integration edits are limited to bootstrap and StealService. World,
BaseService, conveyor, merchant, shield, wave, money, and existing client files
were not edited for this update. Existing workspace changes were retained.

Bat: free Tool, automatically restored within two seconds when absent from both
character and backpack, including after respawn. Server validates equipped tool,
alive players, ready states, rebirth exclusion, 1.2 second cooldown, seven stud
range, forward direction, and an unobstructed ray before applying a hit.
Server drives grip swing, sounds, impact highlight, and knockback, temporarily
owning target physics. Only player targets are considered. Cargo uses existing
returnRaid behavior: stolen/own pickup returns to its original stand; an
undelivered conveyor purchase is removed and refunded. No stand raid rules change.

Index: ViewportFrames clone the actual procedural character sculpts. Common,
Rare, Epic, Legendary, Mythic sections sort by base price. Search only matches
revealed names; locked cards have dark sculpts and ??? labels. Responsive grid,
scrolling rarity controls, collection progress, and session-independent discoveries
are included. Purchase carry and successful delivery record discovery. Rebirth
never clears discoveries. Existing historical discoveries cannot be reconstructed
because the previous game did not persist collection history.

DataStores open only within functions under pcall. Rebirth opens lazily on join;
collection opens during service startup. Collection saves merge discoveries with
UpdateAsync every 60 seconds, on exit, and on shutdown. If storage is unavailable,
session discoveries still work; durability during an outage cannot be guaranteed.

Executed successfully:
- /home/hatch/.local/bin/rojo build -o game.rbxl
- luau-compile on every .lua/.luau file in the workspace: 31 files, zero errors
- python3 tests/v8-regression.py: 9 assertions passed using mocked Roblox APIs

The older tests/base-regression.py targets the previous src/server layout and API;
it was not used as evidence for the extracted current source.

Still requires Roblox Studio / live multiplayer testing:
- Bootstrap full harbor and six safehouses; conveyor purchases and deliveries.
- Equip bat on desktop/touch/gamepad; visible swing, audible swing/impact,
  hit highlight, noticeable knockback, cooldown, death/respawn and tool recovery.
- Two players: cargo return/refund, range, forward arc, walls and shield barriers;
  verify repeated activation requests cannot bypass cooldown or hit unequipped.
- Standing units remain untouched; original steal, shield timing, merchant,
  tsunami, rebirth, and income behave as before.
- All 13 previews, dark locked silhouettes, unlocks, search, rarity filters,
  empty results, small-screen scrolling and resize.
- Rejoin with DataStore enabled, then test unavailable/throttled storage;
  confirm discoveries survive rebirth and persist across servers.

Build and syntax checks do not execute Roblox APIs, physics, rendering or audio.
No Studio runtime, multiplayer session, or publishing was performed here.
