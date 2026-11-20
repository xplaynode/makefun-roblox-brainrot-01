[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/xplaynode/makefun-roblox-brainrot-01/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/xplaynode/makefun-roblox-brainrot-01/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

# Noodle Knight's Brainrot Bay

An original 3D brainrot collection game for Roblox, built for make.fun's roblox-brainrot-01 bounty:
https://make.fun/bounty/roblox-brainrot-01

You spawn at your own base — a raised platform with six collection pads — beside a sunny spawn
field on a dressed island (ocean, sand shores, a lighthouse, lantern posts, palm trees and extra
trees) where 40 absurd original characters wander: Sir Noodleknight, Turbo Toaster, Baron Von Bubbles,
Professor Picklehat, DJ Wafflebot, Madame Marshmallow, Captain Crumb, Robo Ravioli, Siren Sushi,
Wizard Wobble, Count Churro, the Mega Meatball Sage and 28 more noodle, knight, bay and food
creations up to Grand Noodle Neptune. Touch one to pick it up (one at a time),
carry it home and step on an empty pad to place it. Every placed character earns you cash every
second, forever, until you rebirth. A collection index in the HUD tracks which of the 40 you have
placed, and every third tsunami cycle a Golden Runaway appears — placing it pays a bonus 500 cash.

## How to play

1. Run into the central yellow spawn field and touch a wandering character to carry it.
2. Carry it back to your base and touch one of your six pads to place it.
3. Watch your cash climb in the HUD. Fill all six pads, favouring high rarities.
4. When the tsunami warning hits (10 seconds), dash back onto your base platform: the wave sweeps
   the whole map every 90 seconds, and if it touches you while you are carrying a character
   outside your base, you lose the catch.
5. Press the Rebirth button in the HUD when you can afford it to reset your cash and collection
   for a permanent +50% income multiplier per rebirth.

## Systems

- **Rarity ladder (8 rarities)** — Common (x1 income) → Uncommon (x2) → Rare (x3) → Epic (x8) →
  Legendary (x20) → Divine (x80) → Mythic (x50) → Brainrot (x150),
  rolled by spawn weight every time a character appears, shown in its floating label colour.
- **Mutations (8 mutations)** — Golden (x2), Glitch (x3), Diamond (x4), Rainbow (x5), Shadow (x6)
  and Cosmic (x10) mutations roll at spawn and multiply
  that character's income on top of its rarity, alongside the plain unmutated roll.
- **40 brainrots** — a roster of 40 original characters, each with its own colour and scale,
  wandering the field (up to 18 at once), bobbing and spinning as they roam, with heads,
  sparkles on Epic and above and a glow on Legendary and above.
- **Golden Runaway event** — every third tsunami cycle one extra Golden character spawns with a
  gold light and a "GOLDEN RUNAWAY - " label; placing it on a pad pays a one-time bonus of 500 cash.
- **Collection index** — the INDEX button in the HUD lists all 40 characters; placed characters
  show in their own colour, the rest stay hidden as "???".
- **Dressed island** — ocean and sand framing the island, a lighthouse on the north-east water
  edge, lantern posts around the field and paths, palm trees at the edges, extra trees and rocks,
  and a neon arch over the spawn.
- **Visual pass** — primitive-built character models with eyes and hats, larger character models with rarity glow rings, low drifting clouds, dressed spawn with welcome arch, checkerboard island
  with paths, dressed bases, a giant noodle-bowl centerpiece, drifting clouds and bobbing buoys,
  rarity name cards, styled HUD with event banner, glowing pedestals, marquee bulbs, colored zone lighting, lamp light pools, bloom and sun rays, real shadows, a blocky voxel terrain skin (grass/dirt/sand patchwork, cube trees, flat slab clouds), a blocky village (cafe, shop, cottage, market stalls) and a modern city block (apartment tower, road with crosswalk, street lamps).
- **Rebirth** — costs 1,000 cash times your rebirth count plus one; resets cash to 100 and clears
  your pads, and permanently multiplies all income by +50% per rebirth.
- **Tsunami wave** — every 90 seconds a wall of water sweeps the map west to east. Your base
  platform is a safe zone; anywhere else, carrying a catch when the wave reaches you loses it.
- **HUD** — a ScreenGui over the 3D world showing cash, rebirths, income per second, what you are
  carrying, the wave countdown (turning red in the warning window) and the Rebirth button.

## Layout

- `default.project.json` — the Rojo project: the whole 3D world (ground, spawn field, four base
  plots with platforms and pads, pillars, trees, signs, the tsunami wave part, SpawnLocation,
  Lighting) plus the script mounts.
- `src/server/init.server.luau` — the server: leaderstats, base claiming, spawning and wandering,
  touch-to-carry, pads, the income loop, rebirths and the wave cycle.
- `src/client/Hud.client.luau` — the client HUD and Rebirth button (a RemoteEvent to the server).
- `src/shared/Config.luau` — the shared roster, rarity ladder and mutation table.
- `game.rbxl` — the place Rojo builds from the project above.
- `main.ts` — the handover program: copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to
  `/output` and writes `/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy,
  unchanged.

## Run it

Build the place (Rojo 7.x):

    rojo build default.project.json --output game.rbxl

Hand it in as the grader does, writing `out/` in place of `/output`:

    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

## License

MIT — see `LICENSE` (SPDX-License-Identifier: MIT).
