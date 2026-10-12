#!/usr/bin/env bash
# Bump the version in pubspec.yaml.
#
# Convention (see docs/RELEASE.md):
#   - pubspec stays three-part (1.2.0+10); the App Store listing reads it as two-part (1.2).
#   - A release with a user-visible feature is the next MINOR; fixes only are a PATCH.
#   - The build number must be above what is already on App Store Connect / Play. pubspec
#     drifts from reality (past builds used --build-number), so pass --shipped N with the
#     highest CFBundleVersion / versionCode actually uploaded. Xcode may still bump the
#     exported IPA above this; always read CFBundleVersion from the exported IPA.
#
# Usage: scripts/bump_version.sh <major|minor|patch|build> [--shipped N] [--dry-run]
#   build  : keep x.y.z, only raise the build number
set -euo pipefail
cd "$(dirname "$0")/.."

kind="${1:-}"; shift || true
shipped=0; dry=0
while [ $# -gt 0 ]; do
  case "$1" in
    --shipped) shipped="${2:?--shipped needs a number}"; shift 2 ;;
    --dry-run) dry=1; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
case "$kind" in major|minor|patch|build) ;; *)
  echo "usage: $0 <major|minor|patch|build> [--shipped N] [--dry-run]" >&2; exit 2 ;; esac

line=$(grep -E '^version: [0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$' pubspec.yaml) \
  || { echo "pubspec.yaml version line not in x.y.z+n form" >&2; exit 1; }
cur=${line#version: }
name=${cur%+*}; build=${cur#*+}
IFS=. read -r ma mi pa <<<"$name"

case "$kind" in
  major) ma=$((ma+1)); mi=0; pa=0 ;;
  minor) mi=$((mi+1)); pa=0 ;;
  patch) pa=$((pa+1)) ;;
esac
next=$((build+1))
[ "$shipped" -ge "$next" ] && next=$((shipped+1))
new="$ma.$mi.$pa+$next"

echo "pubspec: $cur -> $new  (store listing version: $ma.$mi)"
[ "$shipped" -eq 0 ] && echo "warning: --shipped not given; build number is only pubspec+1 and may collide with a drifted TestFlight/Play build." >&2
[ "$dry" -eq 1 ] && exit 0
sed -i.bak -E "s/^version: .*/version: $new/" pubspec.yaml && rm -f pubspec.yaml.bak
