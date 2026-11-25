#!/bin/sh
# Render the KwikLegacy showcase states with the WoW Forever build of wow-ui-sim
# (https://github.com/Osso/wow-ui-sim, release v0.1.41 "forever-linux-x86_64").
#
# usage: WOW_DIR=/path/to/"World of Warcraft" SIM_DIR=/path/to/wow-ui-sim-forever \
#        media/src/showcase/render.sh [work-dir]
#
# WOW_DIR is the install root containing Data/ and .build.info; it is mounted read-only
# so the simulator can load Blizzard's Forever UI and textures from the local client.
# The simulator runs under bubblewrap with no network and a scratch HOME.
# Renders and crops land in <work-dir>/out; media/ is updated by crops.py.
set -eu
: "${WOW_DIR:?set WOW_DIR to the World of Warcraft install root}"
: "${SIM_DIR:?set SIM_DIR to the extracted wow-ui-sim Forever release}"
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../.." && pwd)
WORK=${1:-$(mktemp -d "${TMPDIR:-/tmp}/kwiklegacy-showcase.XXXXXX")}
mkdir -p "$WORK/home" "$WORK/session" "$WORK/out" "$WORK/addons/KwikLegacy" "$WORK/fixture"
cp "$REPO/KwikLegacy.toc" "$REPO/Model.lua" "$REPO/Core.lua" "$WORK/addons/KwikLegacy/"
for state in main tooltip more f2 f3 f4; do
  cat "$HERE/fixture.lua" "$HERE/state_$state.lua" > "$WORK/fixture/$state.lua"
  bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --unshare-net --unshare-pid --die-with-parent \
    --ro-bind "$WOW_DIR/Data" /tmp/wow/Data --ro-bind "$WOW_DIR/.build.info" /tmp/wow/.build.info \
    --ro-bind "$WOW_DIR/.product.db" /tmp/wow/.product.db --ro-bind "$SIM_DIR" /tmp/sim \
    --bind "$WORK/home" /tmp/simhome --bind "$WORK/session" /tmp/session --bind "$WORK/out" /tmp/out \
    --ro-bind "$WORK/addons" /tmp/sim-addons --ro-bind "$WORK/fixture" /tmp/fixture \
    --setenv HOME /tmp/simhome --setenv XDG_CACHE_HOME /tmp/simhome/.cache --setenv XDG_CONFIG_HOME /tmp/simhome/.config \
    --setenv XDG_RUNTIME_DIR /tmp --setenv WOW_INSTALL_PATH /tmp/wow \
    --setenv WOW_SIM_SOFTWARE_RENDER 1 --setenv WOW_SIM_NO_SOUND 1 --unsetenv DISPLAY --unsetenv WAYLAND_DISPLAY \
    --chdir /tmp/sim /tmp/sim/wow-sim --allow-ui-version-mismatch --no-saved-vars \
    --addons-path /tmp/sim-addons --session-wtf-path /tmp/session \
    --exec-lua "@/tmp/fixture/$state.lua" screenshot --png --width 3200 --height 1800 --ui-scale 2 \
    --output "/tmp/out/hd_$state.png" > "$WORK/out/hd_$state.log" 2>&1
  # Exit status alone is not enough: the fixture asserts and the simulator logs exec-lua errors.
  if grep -q '\[exec-lua\] error' "$WORK/out/hd_$state.log"; then
    echo "$state: exec-lua error, see $WORK/out/hd_$state.log" >&2; exit 1
  fi
  echo "rendered $state"
done
python3 "$HERE/crops.py" "$WORK/out" "$REPO/media"
