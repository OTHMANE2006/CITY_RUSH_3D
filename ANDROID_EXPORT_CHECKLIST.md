# 📋 City Rush 3D — Android Export Checklist

## ✅ Completed in project

- [x] Godot version: **4.7.2 stable** (official Linux ARM64 build used in this workspace)
- [x] Main scene: `res://scenes/main/CityRushGame.tscn` (code-built world + UI)
- [x] Autoloads: GameManager, SaveSystem, AudioManager, CharacterManager
- [x] Renderer: `gl_compatibility` (mobile friendly)
- [x] Viewport: 720x1280 (portrait)
- [x] Android orientation: portrait (`screen_orientation=1`)
- [x] FPS: 60 (`Engine.max_fps = 60.0`) + automatic 30 FPS fallback (< ~1.75 GB RAM)
- [x] Android export preset: `CityRush3D`, architecture `arm64`, ETC2/ASTC textures enabled
- [x] Package name: `com.othman.cityrush3d`
- [x] Game name: `CITY RUSH 3D`
- [x] Export path: `build/city_rush_3d.apk`
- [x] Android permissions: none required (offline/local game; default manifest permissions sufficient)
- [x] Application icon: default (not customized) — `application/icon=""` in Android preset
- [x] Splash screen: default (not customized)
- [x] Asset inclusion: `export_filter="all_resources"` — audio/SFX/music + scripts + scene included
- [x] Missing resources / dependencies: none found (all `res://` paths verified, headless clean run)

## ✅ Final pre-export verification (this session)

- [x] `project.godot` inspected: gl_compatibility renderer, 720x1280 portrait, `screen_orientation=1`
- [x] Android export preset verified: `CityRush3D`, arm64, ETC2/ASTC, embed_pck, `application/package_name="com.othman.cityrush3d"`, `application/name="CITY RUSH 3D"`
- [x] Permissions / icon / splash checked
- [x] Final headless validation re-run after all edits: EXIT=0, no errors

## ⏳ Final step remaining

- [ ] Actual APK build on host with Android SDK/NDK/JDK/Gradle + Godot 4.7.2 Android export templates

## 🔲 Required host machine tools (NOT available in current container)

- [ ] Godot 4.7.2 **editor** with **Android export templates** installed
- [ ] Android SDK (platform / build-tools)
- [ ] Android NDK
- [ ] JDK 17
- [ ] Gradle (bundled with Godot tools or system)
- [ ] Keystore for release signing (debug keystore acceptable for debug APK)

## 🏗 Export commands

```bash
# Debug APK
godot --headless --path /root/projects/city_rush_3d --export-debug "CityRush3D" /root/projects/city_rush_3d/build/city_rush_3d.apk

# Release APK (after creating keystore)
godot --headless --path /root/projects/city_rush_3d --export "CityRush3D" /root/projects/city_rush_3d/build/city_rush_3d.apk
```

## 📱 Android install

```bash
adb install -v /root/projects/city_rush_3d/build/city_rush_3d.apk
```

Enable **Install from unknown apps** on the device.

## 🐞 Known current blockers (this environment)

- [ ] Android SDK / NDK / JDK / Gradle not installed → export cannot run here
- [ ] Godot headless Android export crashes (`double free or corruption (out)`, exit 134) — engine-level issue, must be retried on host with Android toolchain
- [ ] No physical Android device for on-device testing

## ✅ Post-export validation

- [ ] Install APK on device
- [ ] Launch → main menu renders
- [ ] Play 1 full run → game over → restart
- [ ] Verify FPS on low-end device (30 FPS fallback)
