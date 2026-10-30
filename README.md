# DeckCraft for Android (arm64-v8a)

An unofficial Android port of **[DeckCraft](https://github.com/storytold/deckcraft)** — the real engine
and egui interface, packaged as a NativeActivity APK for sideloading on arm64 devices.

| | |
|---|---|
| Upstream project | [`storytold/deckcraft`](https://github.com/storytold/deckcraft) — Apache-2.0 OR MIT |
| Pinned commit | `29f0f77` (upstream version `0.12.0`) |
| Android package | `ai.storyteller.deckcraft` |
| Built APK | `deckcraft-0.12.0-arm64-v8a-20261028.apk` — 52.5 MB (50.1 MiB), arm64-v8a, signed with a local test key (2026-10-28) |
| APK sha256 | `31c2713b672e92bd92e1b37a9f2114c1020f94a559602250d83ad1b1f243e5c3` |
| Upstream files changed | 7 tracked files plus 1 new (`save_dialogs.rs`) — see [`patches/`](patches/) |
| New port crate | `apps/deckcraft-android/` — the shell crate plus resources |
| Fonts | [`craft-fonts`](https://github.com/storytold/craft-fonts) @ `37827adc` (embedded at build time) |

## What this repository is

This is **not a fork** of DeckCraft. It holds only the Android layer, so it stays small, readable,
and obviously separable from upstream:

```
apps/deckcraft-android/     the new shell crate — copy it into your checkout of upstream
patches/                    the diff against upstream — apply it after checking out the pin
vendor/winit/               the winit fork with the Android wheel/hover fix (see vendor/README.md)
docs/PORT-NOTES.md          what was changed and why, fix by fix, with how each one was checked
scripts/                    cross-compile environment, build and verify scripts
CHANGELOG.md                what is in the published APK
```

The Android layer is not a reimplementation. It is a shell crate that fills the same `Services`
struct the desktop and web shells fill, so the real engine and the real egui UI run unchanged.

## Build it

Prerequisites: Rust (rustup) with the `aarch64-linux-android` target, Android SDK + NDK r27, a
JDK 21, `cargo install cargo-apk --version 0.10.0`, and the
[`craft-fonts`](https://github.com/storytold/craft-fonts) checkout at the pin below (the UI is built
from it; without the fonts a release build is refused).

```bash
git clone https://github.com/storytold/deckcraft.git
cd deckcraft
git fetch --depth 1 origin 29f0f7772c47aa2bfb74fcbb0c4d3b1503300849
git checkout FETCH_HEAD                        # the exact commit this port targets
git apply -3 /path/to/0001-deckcraft-android-port.patch
cp -r /path/to/deckcraft-android/apps/deckcraft-android apps/
cp -r /path/to/deckcraft-android/vendor .      # the patched winit the manifest points at

git clone https://github.com/storytold/craft-fonts.git ../craft-fonts
git -C ../craft-fonts checkout 37827adc41fd165f9a9234ac40f94dbad353aa69

# any keystore of your own signs an installable APK; a throwaway test key is fine for sideloading
keytool -genkeypair -keystore ks.jks -alias deckcraft -keyalg RSA -keysize 3072 -validity 10000 \
        -dname "CN=Local Test, O=Local, C=US"
# keytool prompts for the two passwords; put them in the environment for cargo-apk
read -rsp "keystore password: " CARGO_APK_RELEASE_KEYSTORE_PASSWORD; echo
export CARGO_APK_RELEASE_KEYSTORE="$PWD/ks.jks"
```

Then, from that checkout (the script builds the directory it is run in, not its own location):

```bash
export ANDROID_HOME=/path/to/android-sdk JAVA_HOME=/path/to/jdk-21
/path/to/deckcraft-android/scripts/build-apk-linux.sh
```

`scripts/android-env-linux.sh` is the cross-compile environment (NDK clang at API 26, the C compiler
the native dependencies need, and the JDK); `scripts/build-apk-linux.sh` sets
`CRAFT_FONTS_REQUIRED=1`, wraps the build and runs the verifier; `scripts/verify-apk-linux.sh`
checks the artifact with `aapt2`, `apksigner`, `unzip`, `llvm-nm`, `file` and `sha256sum`. The
original `scripts/android-env.sh`, `build-apk.sh` and `verify-apk.sh` remain as the Windows/MSYS
environment earlier releases were built in.

## Install

```bash
adb install -r deckcraft-0.12.0-arm64-v8a-20261028.apk
```
or copy the APK to the device and open it (installing from unknown sources must be allowed).

On first run, grant **Settings ▸ Apps ▸ DeckCraft ▸ Special access ▸ All files access** if you want
the in-app picker to reach files outside the app's own folders. Without it, Android 10+ refuses a
`read_dir` of shared storage by path, and the picker can only offer the app's own directory.

## Verification status

Everything below was checked on the machine this build was made on, on 2026-10-28. A tick means the
check was *run*, not inferred; the wording says how far it goes. The APK was **not** launched on a
device or emulator as part of this build.

| Claim | How it was checked | Result |
|---|---|---|
| `patches/…patch` applies to a clean checkout of the pin | fresh `git worktree` at `29f0f7772c47aa2bfb74fcbb0c4d3b1503300849` + `git apply --check` | ✅ applies cleanly |
| The port crate compiles for Android | `cargo check -p deckcraft-android --target aarch64-linux-android`, with `CRAFT_FONTS_REQUIRED=1` | ✅ exit 0 |
| The port crate's own tests | `cargo test -p deckcraft-android --lib` with winit's host backends enabled (see `CHANGELOG.md`) | ✅ 16 pass |
| APK is signed and is the right artifact | `apksigner verify --verbose`, `aapt2 dump badging`, `unzip -l`, `llvm-nm`, sha256 | ✅ v2/v3 signatures true, `native-code: 'arm64-v8a'`, package `ai.storyteller.deckcraft` |
| Presentation fonts are embedded | the generated font table has 57 `CraftFont` entries; font data is present in the shipped `.so` | ✅ fonts from `craft-fonts` @ `37827adc` |
| The shipped tree matches the built tree | fresh v0.12.0 worktree, patch applied, port crate and `vendor/` copied in; every source file compared by SHA-256 | ✅ byte-identical |
| Behaviour on real hardware | not run: no device was connected during this build | ⚠️ unverified |

**Before trusting the APK:** the source side is verified as listed above; runtime behaviour rests
only on the hand-testing that produced the fixes in [`docs/PORT-NOTES.md`](docs/PORT-NOTES.md) for
earlier releases. There is no automated device test in this repository.

## Known gaps

- **Runtime verification is hand-testing only**; this build was not launched on hardware.
- **No audio output** (`cpal` has no Android backend here) — embedded audio in a presentation is silent.
- **The system clipboard is text only.** Copy/Paste crossed the app boundary for text;
  pictures and HTML on the clipboard are still out of reach (`ClipData` carries them, but this
  port does not negotiate those formats yet).
- **All files access is a manual grant**; without it the picker offers only the app's own directory.
- **Split-screen is defended, not proven** — `config_changes` is what keeps the Activity from being
  recreated; an aggressive device that recreates it anyway will still show the blank-surface symptom.
- **Android 16 ignores the status-bar opt-out** used by theme variant A; the port ships variant B.


## The rest of this set

- [photocraft-android](https://github.com/kanaaka/photocraft-android) — PhotoCraft 0.7.0
- [vectorcraft-android](https://github.com/kanaaka/vectorcraft-android) — VectorCraft 0.9.0
- [wordcraft-android](https://github.com/kanaaka/wordcraft-android) — WordCraft 0.12.0
- [pdfcraft-android](https://github.com/kanaaka/pdfcraft-android) — PdfCraft 0.6.0
- [gridcraft-android](https://github.com/kanaaka/gridcraft-android) — GridCraft 0.5.0
- [shared-android-port](https://github.com/kanaaka/shared-android-port) — build/verify scripts + the cross-compile environment

## Credits and licence

DeckCraft is © its authors at [`storytold/deckcraft`](https://github.com/storytold/deckcraft) and is
dual-licensed Apache-2.0 / MIT; both licence texts are kept here. The Android layer in this
repository is an unofficial modification by [@kanaaka](https://github.com/kanaaka), carrying the
same licence. Not affiliated with or endorsed by the upstream project. See
[`ATTRIBUTION.md`](ATTRIBUTION.md).


## Android 16 build (physicistlk fork)

This fork carries the Android 16 port (arm64-v8a, 16 KB page-aligned) plus the
tablet-compatibility milestones (system clipboard, open-with/share intents, flush on
suspend, back-gesture closes dialog, trackpad wheel + pen hover, stylus pressure for
PhotoCraft, PhotoCraft crash-recovery autosave).

A signed APK for the current state is attached to the
[v2026.10.30 release](https://github.com/physicistlk/deckcraft-android/releases/tag/v2026.10.30).

See the upstream `kanaaka` repository for the full port notes and verification details.
