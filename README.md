# Brainrot Blitz — Steal and Tsunami

[![make.fun](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/c/roblox-brainrot-01)
[![Rank](https://make.fun/badge/roblox-brainrot-01/nagajaja02-pixel/makefun-roblox-brainrot-01-v8/rank.svg)](https://make.fun/c/roblox-brainrot-01)
[![Reward](https://make.fun/badge/roblox-brainrot-01/nagajaja02-pixel/makefun-roblox-brainrot-01-v8/reward.svg)](https://make.fun/c/roblox-brainrot-01)

A Roblox "Steal a Brainrot" style game: buy brainrots off a conveyor, park them on your stands, earn cash, steal from rivals, and survive the tsunami waves. Built for the [roblox-brainrot-01](https://make.fun/c/roblox-brainrot-01) competition on make.fun.

**Play it live:** https://www.roblox.com/games/105239944014039 (place `105239944014039`, universe `10777463940`)

## What is in this version (v9)

- **30 brainrot characters** across 5 rarities (Common, Rare, Epic, Legendary, Mythic), each with a procedural 3D sculpt, price, and income rate. Mythic headliners: Bombardiro Crocodilo, La Vaca Saturno Saturnita, Bulan Badak Bumbum, Komodo Kosmik Komedini, Mahkota Ubur Uberini, Galaksi Angsa Gonggini.
- **Baseball bat** — free tool, server-validated swing, knockback, and steal/raid support. Auto-restores after respawn.
- **Character Index with 3D models** — one Index button opens a collection grid with real ViewportFrame sculpts per character, sorted by rarity, with search and locked silhouettes.
- **7 mutations** — Gold x2, Diamond x3, Rainbow x5, Electric x7, Poison x10, Cosmic x15, Celestial x25 — each with its own color, material, aura, and particles. Mutations persist permanently.
- **Regular events** (Meteor Shower, Golden Rush, Thunderstorm, Rainbow, Lucky Hour) and **admin events** (Cash Rain, Giant Brainrot, Disco Party, Cosmic Chaos, Secret Brainrot Rush), each with weather, sky, lighting, atmosphere, and music changes, plus countdowns and announcements.
- **Admin commands and panel** — `/blitz start`, `/blitz stop`, `/blitz spawn`, `/blitz mutate`, `/blitz money`, `/blitz speed`, `/blitz tp`, `/blitz bring`, `/blitz kick`, `/blitz announce` (admin UserId whitelisted, server-validated).
- **Live leaderboard UI** — top-right Ranks panel with Cash / Steals / Rebirths tabs, refreshing every few seconds.
- **Event notifications and raid/steal alerts**.
- **Gear Shop NPC** — walk up to the shopkeeper for Slap ($500), Speed Coil ($750), and Trap ($350), each with a 3D icon. No auto-buy.
- **Base expansion** — expand your safehouse upward (floor 2 with stairs) for more stands.
- **Varied world** — checkered ground, textured dirt-and-grass sea walls with trees, gray studded-brick safehouses, a Gear Shop stall, and a merchant.
- **Shield, rebirth, and wave shelter** mechanics, plus a tsunami wave that forces players to shelter.

## How to play

1. Open `game.rbxl` in Roblox Studio and press Play, or join the live experience above.
2. Buy brainrots from the conveyor and place them on your stands to earn cash.
3. Steal brainrots from other players' bases — but watch out for their bat and shield.
4. Expand your base, rebirth for bonuses, and collect all 30 characters in the Index.

## Repository layout

- `game.rbxl` — the built place file (Rojo build output, ready to open in Studio).
- `src/` — Luau source (server services, client UI, shared data).
- `screenshots/` — gameplay screenshots (screenshot 1 is the approved Roblox thumbnail).
- `icon.png` — 512x512 experience icon.
- `main.ts` — entrypoint: copies `game.rbxl` into the output directory (never deletes it).
- `PLAY.json` — play link and description code for the live experience.
- `default.project.json` — Rojo project.

## Build

```sh
rojo build default.project.json -o game.rbxl
```

## License

SPDX-License-Identifier: MIT
