#!/usr/bin/env bash
#
# display.sh — portable display setup for the Nyx i3 dotfiles.
#
# Picks the primary connected output and applies MODE @ RATE, falling back to
# a plain `xrandr --auto` when the mode/rate isn't available (so it won't break
# on other people's monitors). Edit MODE / RATE / SCALE to match your panel.
#
# Run `xrandr` to see your output names (e.g. eDP-1, HDMI-1, DP-1) and modes.
#
set -u

MODE="1920x1080"   # e.g. 2560x1440
RATE="144"         # e.g. 60, 120, 144
SCALE="1x1"        # keep 1x1 for 100%; see theme-env.sh for UI scaling

output="$(xrandr | awk '/ connected primary/{print $1; exit}')"
[ -z "$output" ] && output="$(xrandr | awk '/ connected/{print $1; exit}')"
[ -z "$output" ] && exit 0

apply() { xrandr --output "$output" "$@" 2>/dev/null; }

# preferred mode@rate -> mode only -> plain auto
apply --mode "$MODE" --rate "$RATE" --scale "$SCALE" \
    || apply --mode "$MODE" --scale "$SCALE" \
    || apply --auto \
    || true
