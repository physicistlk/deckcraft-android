## 2026-11-05

- Rebased onto DeckCraft 0.15.1 (pin 9bac60ff). Port patch regenerated. APK 0.15.1.

# Changelog

- Re-port to upstream v0.16.0 (commit a3e2254d). Port patch regenerated; resolved conflicts in app/files.rs, backstage/info.rs, dialogs/body.rs. APK `deckcraft-0.16.0-arm64-v8a-20261107.apk` (2026-11-07).

## v0.3.0 — 2026-11-04 (rebased on DeckCraft 0.15.0)

| | |
|---|---|
| APK | `deckcraft-0.15.0-arm64-v8a-20261104.apk` — sha256 `7a13376511f43b9b31f0696f09f8fbf490397261090a4e5ed8fb5eee76615bfd` |
| Built from | upstream `storytold/deckcraft` @ `3e178d8f5a59c787a6a53a7ed0f052b3e4a1489f` (v0.15.0, tag `v0.15.0`) + regenerated `patches/0001-deckcraft-android-port.patch` |
| Package | `ai.storyteller.deckcraft` — versionName `0.15.0`, versionCode `16781056`, minSdk 26, targetSdk 35 |
| ABI | `arm64-v8a` only |
| Signature | local test key (Mode A); not an official DeckCraft key |

### Changed
- **Rebased onto DeckCraft 0.15.0** (pin `3e178d8f`): the port patch was regenerated from the v0.15.0 tree (9 files: Cargo.lock, Cargo.toml, ui-egui app.rs / app/files.rs / backstage/info.rs / dialogs/body.rs / lib.rs / save_dialogs.rs (new) / services.rs) and verified with `git apply --check` against a pristine `v0.15.0` archive.
- Build verified on Linux with NDK r27.2.12479018, build-tools 35.0.0, JDK 25, cargo-apk 0.10.0; `verify-apk-linux.sh` passed (signature, AArch64, 16 KB LOAD alignment, `android_main`/`ANativeActivity_onCreate` exports).

## v0.2.1 — 2026-10-30 (system clipboard)

| | |
|---|---|
| APK | `deckcraft-0.12.0-arm64-v8a-20261030.apk` — sha256 in `SHA256SUMS.txt` beside the build |
| Built from | upstream `storytold/deckcraft` @ `29f0f7772c47aa2bfb74fcbb0c4d3b1503300849` (v0.12.0) + this repository at the commit that built it |
| Package | `ai.storyteller.deckcraft` — versionName `0.12.0`, versionCode `16780288`, minSdk 26, targetSdk 35 |
| ABI | `arm64-v8a` only |
| Signature | local test key (Mode A); not an official DeckCraft key |

### Changed
- **The system clipboard works for text (`src/clipboard.rs`).** Ctrl+C/X/V now produce
  `Event::Copy`/`Cut`/`Paste` — the Android backend never reports modifiers, so `egui-winit` never
  did — Paste reads `ClipboardManager` through JNI, and `OutputCommand::CopyText` is written back
  with `ClipData.newPlainText`. Plain text only: the picture and HTML clipboard fields on `Services`
  stay unset.

### Unchanged
- Everything in v0.2.0: the 0.12.0 rebase, asynchronous save dialogs, the in-app picker,
  two-finger scrolling, modifier tracking, preferences written while the app runs and the theme
  fixes.

### Notes
Built and verified on Linux with NDK r27.2.12479018, build-tools 36.0.0, JDK 21 and cargo-apk 0.10.0.
The clipboard's JNI path was not exercised on a device as part of this build (no device was
connected); its key handling and publishing are covered by unit tests.

## v0.2.0 — 2026-10-28 (rebased on DeckCraft 0.12.0)

| | |
|---|---|
| APK | `deckcraft-0.12.0-arm64-v8a-20261028.apk` — 52.5 MB (50.1 MiB), sha256 in `SHA256SUMS.txt` beside the build |
| Built from | upstream `storytold/deckcraft` @ `29f0f7772c47aa2bfb74fcbb0c4d3b1503300849` (v0.12.0) + this repository at the commit that built it |
| Package | `ai.storyteller.deckcraft` — versionName `0.12.0`, versionCode `16780288`, minSdk 26, targetSdk 35 |
| ABI | `arm64-v8a` only |
| Signature | local test key (Mode A); not an official DeckCraft key |
| Fonts | `craft-fonts` @ `37827adc41fd165f9a9234ac40f94dbad353aa69`, embedded and required at build time |

### Changed
- **Upstream moved from 0.5.0 to 0.12.0**, seven minor releases of editing, layout, export and UI
  work. The port follows the current `Services`, `open_async(purpose, id)`, `InboxEvent`,
  `raw_input_hook(ctx)` and egui 0.37 APIs instead of the 0.5.0 shapes.
- **The asynchronous save seam was re-applied to the 0.12 tree.** `pick_save_async` still lives in
  `Services`, but the save code moved from `dialogs.rs`/`lib.rs` to `app/files.rs` and
  `save_dialogs.rs`; the patch follows it. Save As and every Export ask for a path between frames
  and run on the frame the answer arrives, so the presentation learns its own file.
- **Backstage's Save/Download wording and the close dialog now know about the asynchronous
  picker.** An asynchronous host counts as having a save dialog, and closing a dirty presentation
  waits for the save it just started instead of treating it as a browser download.
- **Fonts are embedded from `craft-fonts`.** 0.12's font build input is required for a release
  build; the port's Linux script sets `CRAFT_FONTS_REQUIRED=1`, so a fontless APK cannot be
  mistaken for a good one.
- **The vendored winit is the fork revision upstream 0.12 pins**, with the same Android wheel and
  hover patches re-applied. `Cargo.toml` pointing at `vendor/winit` is the tracked upstream change
  that carries it.
- Added the Linux build/verify scripts (`scripts/*-linux.sh`); `build-apk-linux.sh` now verifies
  the artifact it produced.

### Unchanged
- Two-finger scrolling, modifier tracking (including Ctrl from the physical key), preferences
  written atomically while the app runs, the `Android/media/<package>/Fonts` folder, the in-app
  picker and the `config_changes` / fullscreen theme fixes.

### Notes
Built and verified on Linux with NDK r27.2.12479018, build-tools 35.0.0, JDK 21, cargo-apk 0.10.0
and `CRAFT_FONTS_REQUIRED=1`. Runtime behaviour was not re-tested on a device as part of this build.
The crate's 7 unit tests pass on the host with winit's Linux backends enabled:
`cargo test -p deckcraft-android --lib --features winit/x11,winit/wayland,winit/wayland-dlopen,winit/wayland-csd-adwaita`.

## v0.1.2 — 2026-10-13 (Ctrl shortcuts)

| | |
|---|---|
| APK | `deckcraft-0.5.0-arm64-v8a-20261013b.apk` (29.1 MB) — supersedes the v0.1.1 asset, same signing key |
| sha256 | `c1d211868ab74de4f93b009a026b86f477f61f37c14a745c5752ee0e81a1b009` |
| Built from | upstream `storytold/deckcraft` @ `be14248577b92059eb2b8c0c9460cceffbc1f01d` + this repository at the commit that released it |
| Package | `ai.storyteller.deckcraft` — versionName `0.5.0`, versionCode `16778496`, minSdk 26, targetSdk 35 |
| ABI | `arm64-v8a` only |

### Fixed
- **Ctrl+anything did nothing, while Shift+click and Shift+arrow worked.** winit's Android
  logical-key table names `Shift` and `Alt` but **not** `Control` — so a Ctrl press arrives with an
  unidentified *logical* key (egui-winit falls back to the physical one) while its physical key is
  correctly `ControlLeft`/`ControlRight`. `src/modifiers.rs` matched the logical key alone, so it
  never saw Ctrl go down: Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+S, Ctrl+B and every other modifier shortcut
  was dead, and only the modifiers winit happens to name worked. The tracker now reads the physical
  key as well as the logical one, on both left and right, and keeps everything else: the per-event
  modifier copies (so a press and a click in one frame stay ordered) and `ModifiersChanged` as the
  authority (so a modifier held while the app goes to the background does not stick).
  The same tracker is in all four ports of this set; it is verified end-to-end in WordCraft
  (`Ctrl+A` selects the text, `Ctrl+B` emboldens it). This app's own shortcuts are the tablet check.

## v0.1.1 — 2026-10-13 (scrolling, modifiers, fonts, picker wording)

| | |
|---|---|
| APK | `deckcraft-0.5.0-arm64-v8a-20261013.apk` (29.1 MB) — supersedes the v0.1.0 asset, same signing key |
| sha256 | `16c4d66cd7955fbebe977bc3d37cd814279086eb672155fb2d965023b071d091` |
| Built from | upstream `storytold/deckcraft` @ `be14248577b92059eb2b8c0c9460cceffbc1f01d` + this repository at the commit that released it |
| Package | `ai.storyteller.deckcraft` — versionName `0.5.0`, versionCode `16778496`, minSdk 26, targetSdk 35 |
| ABI | `arm64-v8a` only |

### Changed
- **Two-finger scrolling.** A two-finger drag now scrolls the deck (synthesised `MouseWheel` events
  from the touch centroid, with the lift event that starts the kinetic coast); one finger still selects
  and a pinch still zooms. Ctrl+wheel zooms.
- **A *Fonts* folder** at `Android/media/<package>/Fonts` (with `.fonts` and `.local/share/fonts`
  symlinked to it), so a font copied in over a USB cable is picked up.
- **Picker wording corrected.** An empty folder in shared storage no longer tells a user who has
  already granted *All files access* to grant it, and the USB tip now matches the folder
  (`Android/data` is unreachable over a cable, `Android/media` is not).

### Notes
The build was made from exactly the source in this repository (upstream pin + the patch + the port
crate) and signed with the same local test key as v0.1.0, so it installs over it.


## v0.1.0 — first published port (DeckCraft 0.5.0)

| | |
|---|---|
| APK | `deckcraft-0.5.0-arm64-v8a-v3.apk` (29.1 MB) |
| sha256 | `5a944e8c77784f45b7bf89bbf71c557719ec83ce052d1379499b13f128231f6d` |
| Built from | upstream `storytold/deckcraft` @ `be14248577b92059eb2b8c0c9460cceffbc1f01d` + `patches/0001-deckcraft-android-port.patch` + `apps/deckcraft-android/` |
| Package | `ai.storyteller.deckcraft` — versionName `0.5.0`, minSdk 26, targetSdk 35 |
| ABI | `arm64-v8a` only |
| Signature | throwaway local test key, not an official key |

### In this release
- Android shell crate: NativeActivity entry point, `Services` implementation, file logger, preferences
  written while the app runs (atomic), modifier-key synthesis, Activity not recreated on configuration
  change.
- **Save As and Export do not hold the frame** (`pick_save_async` + `save_dialogs`): a saved
  presentation learns its path, so the title bar follows, *Save* stops asking, closing stops prompting,
  and the file enters the recent list.
- **Ctrl / Shift / Alt work** — the platform reports no modifiers, so they are tracked from key events
  and re-injected.
- In-app picker for Open and Save As, with cached listings, "Show all files", hidden-file count and
  self-explaining locked roots.
- Launcher icon, storage permissions (images, video and audio), edge-to-edge theme variant.


### Known issues
See *Known gaps* in the [README](README.md) and [`docs/PORT-NOTES.md`](docs/PORT-NOTES.md).
