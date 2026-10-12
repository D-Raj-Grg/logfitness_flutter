#!/usr/bin/env bash
# Build the iOS IPA, verify the Supabase config was baked in, validate with App Store Connect,
# and (only with --upload) upload to TestFlight. Review submission stays manual / via asc.py.
#
# Env: ASC_KEY_ID, ASC_ISSUER_ID  (private key at ~/.appstoreconnect/private_keys/AuthKey_<id>.p8)
# Usage: scripts/release_ios_testflight.sh [--upload]
set -euo pipefail
cd "$(dirname "$0")/.."

: "${ASC_KEY_ID:?set ASC_KEY_ID}"; : "${ASC_ISSUER_ID:?set ASC_ISSUER_ID}"
[ -f env/local.json ] || { echo "env/local.json missing: build would ship without Supabase config" >&2; exit 1; }
IPA="build/ios/ipa/Gym Tross.ipa"

flutter build ipa --release --dart-define-from-file=env/local.json \
  --export-options-plist=ios/ExportOptions.plist

# Build 8 froze every user because this was skipped. Do not remove.
# Extract to a temp dir: `unzip -p` with a Payload/*/ glob matches several files
# and a binary plist piped to `plutil -p -` is rejected.
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
unzip -p "$IPA" 'Payload/Runner.app/Frameworks/App.framework/App' > "$tmp/App"
n=$(strings -a "$tmp/App" | grep -c 'supabase\.co' || true)
[ "$n" -gt 0 ] || { echo "ABORT: no supabase.co in the IPA; --dart-define-from-file did not take effect" >&2; exit 1; }

# Xcode may bump the number on export; this is the number ASC will see.
unzip -p "$IPA" 'Payload/Runner.app/Info.plist' > "$tmp/Info.plist"
plutil -p "$tmp/Info.plist" | grep -E 'CFBundle(Short)?Version'

xcrun altool --validate-app --type ios -f "$IPA" --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

if [ "${1:-}" = "--upload" ]; then
  xcrun altool --upload-app --type ios -f "$IPA" --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
  echo "Uploaded. Wait for the build to report VALID, then attach it to the version in App Store Connect."
else
  echo "Validated only. Re-run with --upload to send it to TestFlight."
fi
