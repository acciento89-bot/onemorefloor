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
  python3 - "$1" "$2" <<'PY'
import hashlib
import math
import struct
import sys
import zlib
from pathlib import Path

path = Path(sys.argv[1])
previous = Path(sys.argv[2]) if sys.argv[2] else None
data = path.read_bytes()
if data[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit("not a PNG")
width, height, depth, color_type = struct.unpack(">IIBB", data[16:26])
if (width, height, depth, color_type) != (1080, 2400, 8, 6):
    raise SystemExit(f"unexpected PNG format: {width}x{height}, depth={depth}, color={color_type}")

pos = 8
compressed = bytearray()
while pos < len(data):
    length = struct.unpack(">I", data[pos:pos+4])[0]
    kind = data[pos+4:pos+8]
    if kind == b"IDAT":
        compressed.extend(data[pos+8:pos+8+length])
    pos += 12 + length

raw = zlib.decompress(bytes(compressed))
stride = width * 4
rows = []
offset = 0
prior = bytearray(stride)
for _ in range(height):
    mode = raw[offset]
    offset += 1
    scan = bytearray(raw[offset:offset+stride])
    offset += stride
    recon = bytearray(stride)
    for i, value in enumerate(scan):
        left = recon[i-4] if i >= 4 else 0
        up = prior[i]
        upper_left = prior[i-4] if i >= 4 else 0
        if mode == 0:
            recon[i] = value
        elif mode == 1:
            recon[i] = (value + left) & 255
        elif mode == 2:
            recon[i] = (value + up) & 255
        elif mode == 3:
            recon[i] = (value + ((left + up) // 2)) & 255
        elif mode == 4:
            p = left + up - upper_left
            pa, pb, pc = abs(p-left), abs(p-up), abs(p-upper_left)
            predictor = left if pa <= pb and pa <= pc else up if pb <= pc else upper_left
            recon[i] = (value + predictor) & 255
        else:
            raise SystemExit(f"unsupported PNG filter {mode}")
    rows.append(recon)
    prior = recon

luma = []
colors = set()
near_white = 0
non_dark = 0
edges = 0
samples = 0
prior_luma = None
for y in range(0, height, 8):
    row = rows[y]
    for x in range(0, width, 8):
        i = x * 4
        r, g, b = row[i], row[i+1], row[i+2]
        value = (299*r + 587*g + 114*b) / 1000
        luma.append(value)
        colors.add((r >> 4, g >> 4, b >> 4))
        near_white += int(r > 225 and g > 225 and b > 225 and max(r,g,b)-min(r,g,b) < 18)
        non_dark += int(value > 35)
        if prior_luma is not None and abs(value-prior_luma) > 28:
            edges += 1
        prior_luma = value
        samples += 1

mean = sum(luma) / samples
stddev = math.sqrt(sum((v-mean)**2 for v in luma) / samples)
white_fraction = near_white / samples
non_dark_fraction = non_dark / samples
edge_fraction = edges / samples
if stddev < 18 or len(colors) < 32:
    raise SystemExit(f"near-monochrome frame: stddev={stddev:.2f}, colors={len(colors)}")
if non_dark_fraction < 0.10 or edge_fraction < 0.006:
    raise SystemExit(f"splash-like frame: non_dark={non_dark_fraction:.3f}, edges={edge_fraction:.3f}")
if white_fraction > 0.10:
    raise SystemExit(f"system/fullscreen overlay-like frame: near_white={white_fraction:.3f}")
if previous and previous.exists() and hashlib.sha256(data).digest() == hashlib.sha256(previous.read_bytes()).digest():
    raise SystemExit("frame is unchanged from previous game state")
PY
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
  adb shell dumpsys activity exit-info "$PACKAGE_NAME" \
    | grep -E 'reason=|status=|description=|timestamp=' \
    | head -20 >&2 || true
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
