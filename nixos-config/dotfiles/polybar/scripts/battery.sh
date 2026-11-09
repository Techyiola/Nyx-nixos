#!/usr/bin/env bash
# Polybar battery indicator — reads /sys/class/power_supply/BAT*
# Shows the charge level and, when plugged in, a charging glyph.
#
# Uses Nerd Font Material Design battery glyphs (MesloLGS Nerd Font).
# The percentage is right-aligned to 3 digits so the module keeps a constant width.

ICON_FULL=$'\U000F0079'      # nf-md-battery
ICON_10=$'\U000F007A'        # nf-md-battery_10
ICON_20=$'\U000F007B'        # nf-md-battery_20
ICON_30=$'\U000F007C'        # nf-md-battery_30
ICON_40=$'\U000F007D'        # nf-md-battery_40
ICON_50=$'\U000F007E'        # nf-md-battery_50
ICON_60=$'\U000F007F'        # nf-md-battery_60
ICON_70=$'\U000F0080'        # nf-md-battery_70
ICON_80=$'\U000F0081'        # nf-md-battery_80
ICON_90=$'\U000F0082'        # nf-md-battery_90
ICON_ALERT=$'\U000F0083'     # nf-md-battery_alert
ICON_CHARGING=$'\U000F0084'  # nf-md-battery_charging

# Find the first battery exposed by the kernel.
bat=""
for d in /sys/class/power_supply/BAT*; do
    [ -r "$d/capacity" ] && { bat="$d"; break; }
done

if [ -z "$bat" ]; then
    printf '%s\n' "%{F#4D4D4D}${ICON_ALERT}%{F-} n/a"
    exit 0
fi

cap=$(cat "$bat/capacity" 2>/dev/null)
status=$(cat "$bat/status" 2>/dev/null)
case "$cap" in ''|*[!0-9]*) cap=0 ;; esac

# Charge-level glyph.
if   [ "$cap" -ge 95 ]; then icon="$ICON_FULL"
elif [ "$cap" -ge 85 ]; then icon="$ICON_90"
elif [ "$cap" -ge 75 ]; then icon="$ICON_80"
elif [ "$cap" -ge 65 ]; then icon="$ICON_70"
elif [ "$cap" -ge 55 ]; then icon="$ICON_60"
elif [ "$cap" -ge 45 ]; then icon="$ICON_50"
elif [ "$cap" -ge 35 ]; then icon="$ICON_40"
elif [ "$cap" -ge 25 ]; then icon="$ICON_30"
elif [ "$cap" -ge 15 ]; then icon="$ICON_20"
else                         icon="$ICON_10"
fi

color='#C8C8C8'   # foreground: discharging at a healthy level
case "$status" in
    Charging|"Not charging"|Full)
        icon="$ICON_CHARGING"
        color='#B9B9B9'   # secondary: plugged in
        ;;
    *)
        # Discharging (or unknown): flag a low charge with the alert glyph.
        [ "$cap" -lt 20 ] && icon="$ICON_ALERT"
        ;;
esac

# Drain rate (smoothed %/h + time remaining), shown right of the percentage.
# Computed by battery_drain.sh, which reuses the same battery and colors.
drain=""
[ -x "$HOME/.config/polybar/scripts/battery_drain.sh" ] &&
    drain=$("$HOME/.config/polybar/scripts/battery_drain.sh" 2>/dev/null)

printf '%s\n' "%{F${color}}${icon}%{F-} $(printf '%3d' "$cap")%${drain:+  ${drain}}"
