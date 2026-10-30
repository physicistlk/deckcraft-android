#!/usr/bin/env bash
# Build the release arm64-v8a APK on Linux.
#
#   ANDROID_HOME=... JAVA_HOME=... scripts/build-apk-linux.sh
#
# Signing: cargo-apk signs with the keystore named by CARGO_APK_RELEASE_KEYSTORE and
# CARGO_APK_RELEASE_KEYSTORE_PASSWORD. Both must already be set; this script never creates,
# prints or commits a key. Without them cargo-apk makes a debug APK, which this script rejects
# at the end so a "successful" unsigned build cannot be mistaken for an installable one.
set -o pipefail
# Build the checkout in the current directory; this script may live in the port repository.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/android-env-linux.sh" || exit 1

if [ -z "${CARGO_APK_RELEASE_KEYSTORE:-}" ] || [ -z "${CARGO_APK_RELEASE_KEYSTORE_PASSWORD:-}" ]; then
  echo "build-apk: set CARGO_APK_RELEASE_KEYSTORE and CARGO_APK_RELEASE_KEYSTORE_PASSWORD" >&2
  exit 2
fi

echo "=== building deckcraft-android (release, aarch64-linux-android) at $(date -Is) ==="
# A release APK must carry the bundled fonts: without the sibling craft-fonts checkout the
# build script would only warn and the UI would fall back to system fonts. Setting this makes
# that a build error instead.
: "${CRAFT_FONTS_REQUIRED:=1}"
export CRAFT_FONTS_REQUIRED
# Keep the shipped library stripped; cargo-apk also strips at packaging time, but setting the
# profile here makes the local build match the published one.
: "${CARGO_PROFILE_RELEASE_STRIP:=symbols}"
export CARGO_PROFILE_RELEASE_STRIP
cargo apk build --release -p deckcraft-android --target aarch64-linux-android
status=$?
if [ "$status" -eq 0 ]; then
  "$SCRIPT_DIR/verify-apk-linux.sh" target/release/apk/deckcraft.apk deckcraft || status=$?
fi
echo "=== cargo apk exit=$status at $(date -Is) ==="
exit $status
