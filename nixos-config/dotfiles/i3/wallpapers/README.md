# Monochrome wallpapers

Curated strictly-grayscale wallpapers for the i3 rice. All files are 16:9 and
converted to neutral gray (saturation = 0).

| File | Vibe |
|---|---|
| `01-architecture.png` | Looking up at a building — geometric, high-res (installed) |
| `02-night-lights.jpg` | Near-black night with a single cluster of lights |
| `03-black-texture.jpg` | Dark macro texture, subtle grain |
| `04-hill.jpg` | High-contrast hill and sky |
| `05-monitor.jpg` | Black monitor with a white screen |
| `06-foggy-forest.jpg` | Hazy forest, lighter tones |

Preview everything in `preview.png`.

## Switch wallpaper

```sh
~/.config/i3/wallpapers/set-wallpaper.sh 3     # by number
~/.config/i3/wallpapers/set-wallpaper.sh ~/Pictures/foo.png
```

The script copies/converts the choice to `~/.config/i3/wallpaper.png` and
applies it with feh, so it persists across i3 restarts (the i3 config already
launches feh on `wallpaper.png`). `wallpaper.original.png` is the image that
was there before this set.

Source: https://github.com/dharmx/walls (monochrome collection).
