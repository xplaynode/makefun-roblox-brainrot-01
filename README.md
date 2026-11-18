[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/xplaynode/makefun-roblox-brainrot-01/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/xplaynode/makefun-roblox-brainrot-01/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

# Noodle Knight's Brainrot Bay

An original 3D brainrot collection game for Roblox, built for make.fun's roblox-brainrot-01 bounty:
https://make.fun/bounty/roblox-brainrot-01

You spawn at your own base — a raised platform with six collection pads — beside a sunny spawn
field where absurd original characters wander: Sir Noodleknight, Turbo Toaster, Baron Von Bubbles,
Professor Picklehat, DJ Wafflebot, Madame Marshmallow, Captain Crumb, Robo Ravioli, Siren Sushi,
Wizard Wobble, Count Churro and the Mega Meatball Sage. Touch one to pick it up (one at a time),
carry it home and step on an empty pad to place it. Every placed character earns you cash every
second, forever, until you rebirth.

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

- **Rarity ladder** — Common (x1 income) → Rare (x3) → Epic (x8) → Legendary (x20) → Mythic (x50),
  rolled by spawn weight every time a character appears, shown in its floating label colour.
- **Mutations** — Golden (x2), Glitch (x3) and Rainbow (x5) mutations roll at spawn and multiply
  that character's income on top of its rarity.
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
