# Neon Endless Runner 🟦🟥

A mobile **2D endless runner** made with **Godot 4.7** — a neon square sprints
forward automatically, and your only job is to **tap the screen to jump** over
incoming blocks. The world scrolls faster and faster, the score grows with the
distance travelled, and one touch of a block ends the run.

## Features

- 📱 Portrait mobile resolution **720×1280**, stretch mode `canvas_items`
- 👆 Touch input (with *touch-from-mouse* emulation for desktop testing)
- 🟦 Neon-styled player drawn procedurally (`_draw()`), no art assets required
- ♾️ Endless obstacle spawner with growing speed (`320 → 980 px/s`)
- 💯 Real-time score counter and a neon **Game Over** screen with a **Restart**
- 🤖 GitHub Actions CI/CD that exports an installable **APK** on every push

## Project layout

```
project.godot              # project config (portrait 720x1280, touch emulation)
export_presets.cfg         # Android export preset (APK, no Gradle)
scenes/
  main.tscn                # main scene: world + ground + HUD + spawner
  player.tscn              # CharacterBody2D player with collision shape
  obstacle.tscn            # Area2D deadly block
scripts/
  main.gd                  # game state, difficulty ramp, score, UI wiring
  player.gd                # gravity, tap-to-jump, neon drawing, death
  spawner.gd               # spawns/moves/recycles obstacles
  obstacle.gd              # neon block visual + kill-on-touch
.github/workflows/
  android-build.yml        # CI: Godot 4.7.2 + Android SDK -> APK artifact
```

## Running locally

1. Install [Godot 4.7](https://godotengine.org/download) (standard build).
2. Open the repository folder as a project and press **F5**.
3. Click / tap anywhere to jump. Press <kbd>Space</kbd> / <kbd>↑</kbd> too if
   you prefer the keyboard.

## Android export (manual)

1. Install **OpenJDK 17** and the **Android SDK** (platform-tools,
   `platforms;android-35`, `build-tools;35.0.1`).
2. In *Editor → Editor Settings → Export → Android*, set **Java SDK Path** and
   **Android SDK Path**.
3. Download export templates via *Editor → Manage Export Templates*.
4. *Project → Export → Android → Export Project* (the `Android` preset is
   already configured).

## CI/CD — automatic APK builds

Workflow: [`.github/workflows/android-build.yml`](.github/workflows/android-build.yml)

| Trigger | When |
| --- | --- |
| `push` to `main` | every merge/push to main |
| `pull_request` to `main` | validation on PRs |
| `workflow_dispatch` | manual run from the Actions tab |

What it does on `ubuntu-latest`:

1. Installs **Java 17** and the **Android SDK** (`android-actions/setup-android`).
2. Installs **Godot 4.7.2 + export templates**
   (`chickensoft-games/setup-godot`).
3. Generates an Android **debug keystore** and points Godot's editor settings
   at the SDK/JDK/keystore.
4. Imports the project, runs a **headless smoke test**, then exports
   `build/neon-endless-runner.apk` (`--export-debug`).
5. Uploads the APK as the **`NeonEndlessRunner-APK`** artifact
   (downloadable from the workflow run page for 30 days).

> The CI build is signed with a freshly generated **debug** key so it can be
> installed on any device for testing. For Play Store releases, add your own
> release keystore via the `GODOT_ANDROID_KEYSTORE_RELEASE_*` environment
> variables and switch the export step to `--export-release`.
