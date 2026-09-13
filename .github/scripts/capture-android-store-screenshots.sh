#!/usr/bin/env bash
set -euo pipefail

: "${PACKAGE_NAME:?PACKAGE_NAME is required}"
: "${APK_PATH:?APK_PATH is required}"
: "${OUTPUT_DIR:?OUTPUT_DIR is required}"
: "${SECOND_ACTION:?SECOND_ACTION is required}"

readonly apk_path="$GITHUB_WORKSPACE/$APK_PATH"
readonly output_dir="$GITHUB_WORKSPACE/$OUTPUT_DIR"

current_focus() {
  adb shell dumpsys window | grep -m1 'mCurrentFocus=' || true
}

launch_app() {
  local component
  adb shell am force-stop "$PACKAGE_NAME"
  component="$(adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER "$PACKAGE_NAME" | tr -d '\r' | tail -n 1)"
  if [[ "$component" != "$PACKAGE_NAME/"* ]]; then
    echo "Could not resolve launcher activity for $PACKAGE_NAME: $component" >&2
    return 1
  fi
  adb shell am start -W -n "$component"
}

visual_candidate_is_ready() {
  local path="$1"
  local previous="$2"
  local dimensions colors stddev mean near_white
  dimensions="$(identify -format '%wx%h' "$path")"
  [[ "$dimensions" == "1080x2400" ]] || { echo "unexpected dimensions: $dimensions" >&2; return 1; }
  colors="$(identify -format '%k' "$path")"
  read -r stddev mean <<<"$(convert "$path" -colorspace Gray -format '%[fx:standard_deviation] %[fx:mean]' info:)"
  near_white="$(convert "$path" -colorspace Gray -threshold 88% -format '%[fx:mean]' info:)"
  python3 - "$stddev" "$mean" "$near_white" "$colors" <<'PY'
import sys
stddev, mean, near_white = map(float, sys.argv[1:4])
colors = int(sys.argv[4])
if stddev < 0.07 or colors < 64:
    raise SystemExit(f"near-monochrome frame: stddev={stddev:.4f}, colors={colors}")
if mean < 0.10:
    raise SystemExit(f"splash-like frame: mean={mean:.4f}")
if near_white > 0.10:
    raise SystemExit(f"system/fullscreen overlay-like frame: near_white={near_white:.4f}")
PY
  if [[ -n "$previous" ]] && cmp -s "$path" "$previous"; then
    echo "Frame is unchanged from previous game state." >&2
    return 1
  fi
}

capture_ready_state() {
  local destination="$1"
  local previous="${2:-}"
  local candidate="$output_dir/.candidate.png"
  local attempt focus
  for attempt in $(seq 1 90); do
    focus="$(current_focus)"
    if [[ "$focus" == *"$PACKAGE_NAME"* ]]; then
      adb exec-out screencap -p > "$candidate"
      if visual_candidate_is_ready "$candidate" "$previous"; then
        mv "$candidate" "$destination"
        return 0
      fi
    fi
    sleep 2
  done
  echo "Timed out waiting for non-splash, non-monochrome game UI without system overlays." >&2
  current_focus >&2
  return 1
}

mkdir -p "$output_dir"
rm -f "$output_dir"/*.png
test -s "$apk_path"
adb install -r "$apk_path"
adb shell settings put system accelerometer_rotation 0
adb shell settings put system user_rotation 0
adb shell settings put global hide_error_dialogs 1
adb shell cmd locale set-app-locales "$PACKAGE_NAME" --user 0 de-DE || true

launch_app
capture_ready_state "$output_dir/01-current-ui.png"

case "$SECOND_ACTION" in
  tap)
    adb shell input tap "${TAP_X:-540}" "${TAP_Y:-1900}"
    ;;
  swipe)
    adb shell input swipe 540 1900 540 650 600
    ;;
  dark)
    adb shell cmd uimode night yes
    launch_app
    ;;
  *)
    echo "Unsupported SECOND_ACTION: $SECOND_ACTION" >&2
    exit 1
    ;;
esac

capture_ready_state "$output_dir/02-current-ui-detail.png" "$output_dir/01-current-ui.png"

python3 - "$output_dir" <<'PY'
import hashlib
import struct
import sys
from pathlib import Path

paths = sorted(Path(sys.argv[1]).glob('*.png'))
assert len(paths) == 2, paths
digests = set()
for path in paths:
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    width, height = struct.unpack('>II', data[16:24])
    assert (width, height) == (1080, 2400), (path, width, height)
    digests.add(hashlib.sha256(data).hexdigest())
assert len(digests) == 2, 'Screenshots must show two distinct real app states'
PY
