#!/usr/bin/env bash
# Polybar volume indicator — pamixer (PipeWire / PulseAudio)
# click-left toggles mute, scroll changes volume (see polybar config)
#
# Uses Nerd Font Material Design volume glyphs (MesloLGS Nerd Font).
# The volume is right-aligned to 3 digits so the module keeps a constant width.

ICON_LOW=$'\U000F057F'   # nf-md-volume_low
ICON_MED=$'\U000F0580'   # nf-md-volume_medium
ICON_HIGH=$'\U000F057E'  # nf-md-volume_high
ICON_MUTE=$'\U000F0581'  # nf-md-volume_mute

vol=$(pamixer --get-volume 2>/dev/null)
case "$vol" in
    ''|*[!0-9]*) vol=0 ;;
esac

if [ "$(pamixer --get-mute 2>/dev/null)" = "true" ]; then
    printf '%s\n' "%{F#4D4D4D}${ICON_MUTE}%{F-} $(printf '%3d' "$vol")%"
else
    if   [ "$vol" -lt 34 ]; then icon="$ICON_LOW"
    elif [ "$vol" -lt 67 ]; then icon="$ICON_MED"
    else                         icon="$ICON_HIGH"
    fi
    printf '%s\n' "%{F#C8C8C8}${icon}%{F-} $(printf '%3d' "$vol")%"
fi
