#!/usr/bin/env bash
# Build a signed Android App Bundle and (only with --upload) push it to the Play internal track.
#
# Needs android/key.properties (see docs/RELEASE.md). Upload additionally needs fastlane and
# env PLAY_JSON_KEY (path to a Play service-account JSON, kept outside the repo).
# Usage: scripts/release_android_internal.sh [--upload]
set -euo pipefail
cd "$(dirname "$0")/.."

[ -f android/key.properties ] || { echo "android/key.properties missing: bundle would be debug-signed" >&2; exit 1; }
[ -f env/local.json ] || { echo "env/local.json missing: build would ship without Supabase config" >&2; exit 1; }

flutter build appbundle --release --dart-define-from-file=env/local.json
AAB=build/app/outputs/bundle/release/app-release.aab

# Reject a debug-signed bundle (CN=Android Debug).
if keytool -printcert -jarfile "$AAB" 2>/dev/null | grep -q "Android Debug"; then
  echo "ABORT: bundle is signed with the debug key" >&2; exit 1
fi

if [ "${1:-}" = "--upload" ]; then
  : "${PLAY_JSON_KEY:?set PLAY_JSON_KEY}"
  command -v fastlane >/dev/null || { echo "fastlane not installed (gem install fastlane)" >&2; exit 1; }
  fastlane supply --aab "$AAB" --track internal --package_name com.gymtross.app \
    --json_key "$PLAY_JSON_KEY" --release_status draft
else
  echo "Built $AAB. Re-run with --upload, or upload by hand in Play Console > Internal testing."
fi
