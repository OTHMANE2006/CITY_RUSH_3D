# City Rush 3D

An original endless runner 3D mobile game inspired by the Subway Surfers genre, built with **Godot 4.7.2** and **GDScript**.

## Features

- Endless runner gameplay with 3 lanes (left / center / right)
- Auto-run forward with:
  - Swipe left / right → change lane
  - Swipe up → jump
  - Swipe down → slide
  - Keyboard (PC): arrows / A-D lane, Up/Space jump, Down/Shift slide
- Obstacles: moving trains, stationary trains, barriers, traffic cones, vehicles, wooden boxes, low & high obstacles
- Coins with collection animation, magnet power-up, score multiplier, shield, super sneakers, jetpack
- 10 original playable characters with unique colors and unlock prices
- In-game shop (characters, power-ups, coin packages) using virtual coins
- Missions: collect 100 coins, run 1000m, avoid 20 obstacles, use 3 power-ups
- Main menu / HUD / Game Over / Character Select / Shop / Missions / Settings UI
- Procedural city environment: railway tracks, buildings, bridges, tunnels, stations, street lights, billboards, trees, moving background
- Procedural endless level generation until crash
- Music + SFX (generated procedurally), music/SFX toggles
- Persistent local save (coins, best score, unlocks, selected character, settings, missions)

## Tech stack

- Engine: Godot 4.7.2 (stable) — Linux ARM64 build used in this environment
- Language: GDScript
- Rendering: Forward+ / Compatibility (gl_compatibility for low-end mobile)
- Orientation: Portrait (720x1280)

## Project structure

```
city_rush_3d/
├── project.godot
├── export_presets.cfg
├── assets/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── ...
├── scenes/
│   └── main/
│       └── CityRushGame.tscn
└── scripts/
    ├── core/
    ├── gameplay/
    ├── player/
    ├── systems/
    ├── ui/
    └── main/
```

## How to run

1. Install Godot 4.7.2.
2. Open the project folder `city_rush_3d`.
3. Run main scene: `CityRushGame.tscn`.

Headless validation run (this environment):

```bash
godot --headless --path /root/projects/city_rush_3d --quit-after 240
```

## Android optimization (Priority 9)

- Renderer: `gl_compatibility` (mobile) — low-end friendly.
- Target FPS: 60 (`Engine.max_fps = 60.0`), automatic 30 FPS fallback for devices with < ~1.75 GB RAM (`OS.get_memory_info`).
- Textures: ETC2/ASTC compression enabled for Android export preset.
- Shadows: directional light shadows enabled (map 1024, cascade 2).
- Fog + Filmic tonemap for cinematic depth.
- Object pooling: obstacle pool (12) and coin pool (12) — no per-spawn `queue_free`.
- Procedural low-poly world (no heavy meshes/textures).

## How to export Android APK

1. Install Godot 4.7.2 with Android export templates.
2. In Godot editor: Project → Export → select preset "CityRush3D" → Android.
3. Set export path `build/city_rush_3d.apk`.
4. Install Android SDK/NDK + Java + Gradle on host.
5. Export with `--export-debug "CityRush3D" <path>`.

> Note: Android export could not be executed in this container (no Android SDK/NDK/JDK/Gradle and a Godot headless export crash `double free or corruption`). Export must be run on a host with the Android toolchain.

## Remaining limitations

- No original 3D character model assets — characters are procedural capsule-based meshes.
- No real audio files from artists — SFX/music generated procedurally (WAV).
- 3D environment is low-poly procedural.
- Android SDK/NDK not available in this container, so APK export could not be executed here.
- Gameplay validated headless (script compile + runtime); visual/mobile performance tuning requires device testing.

## Controls

- Mobile: swipe left/right = lane, swipe up = jump, swipe down = slide.
- PC: Left/Right arrows or A/D = lane, Up/Space = jump, Down/Shift = slide.

## Save file

- Path: `user://save.cfg`
- Stores: coins, best score, unlocked characters, selected character, settings, mission progress.
