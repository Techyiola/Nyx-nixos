#!/usr/bin/env bash
# Pick a wallpaper from this folder (by number or path), install it as
# ~/.config/i3/wallpaper.png and apply it with feh.
set -euo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.config/i3/wallpaper.png"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <number|image>" >&2
    echo "Available:" >&2
    (cd "$dir" && ls [0-9][0-9]-* 2>/dev/null | nl -w2 -s') ' >&2)
    exit 1
fi

choice="$1"
if [[ "$choice" =~ ^[0-9]+$ ]]; then
    choice="$(cd "$dir" && ls [0-9][0-9]-* | sed -n "${choice}p")"
    [[ -n "$choice" ]] || { echo "No wallpaper with that number." >&2; exit 1; }
    choice="$dir/$choice"
fi

[[ -f "$choice" ]] || { echo "File not found: $choice" >&2; exit 1; }

# Normalise to a neutral grayscale PNG so any source works as wallpaper.png.
magick "$choice" -colorspace Gray "$target"

if command -v feh >/dev/null 2>&1; then
    DISPLAY="${DISPLAY:-:0}" feh --bg-fill "$target"
fi

echo "Wallpaper set: $choice"
