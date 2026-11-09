#!/usr/bin/env bash
# Polybar network indicator — NetworkManager (nmcli)
# Shows the active connection: wifi (with SSID + signal) or ethernet.

ICON_WIFI=$'\uf1eb'  # FontAwesome: wifi
ICON_ETH=$'\U000F0200'  # Nerd Font: ethernet
ICON_OFF=$'\uf00d'   # FontAwesome: times

line=$(nmcli -t -f TYPE,DEVICE,STATE device 2>/dev/null \
    | awk -F: '$3=="connected" && $1!="loopback" {print; exit}')

if [ -z "$line" ]; then
    printf '%s\n' "%{F#4D4D4D}${ICON_OFF}%{F-} down"
    exit 0
fi

type=$(printf '%s' "$line" | cut -d: -f1)
dev=$(printf '%s' "$line" | cut -d: -f2)

case "$type" in
    wifi)
        ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
        sig=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1=="*"{print $2; exit}')
        [ -z "$ssid" ] && ssid="$dev"
        printf '%s\n' "%{F#C8C8C8}${ICON_WIFI}%{F-} ${ssid} ${sig}%"
        ;;
    *)
        printf '%s\n' "%{F#C8C8C8}${ICON_ETH}%{F-} ${dev}"
        ;;
esac
