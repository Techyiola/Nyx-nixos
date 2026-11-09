#!/usr/bin/env bash
while true; do
  choice=$(printf '%s\n' "Apps" "WiFi" "Volume" "Monitor" "Power" "Quit" |
    fzf --reverse --no-info --prompt="  " --header="── MENU ──" --height=100%)
  case "$choice" in
  Apps) cmd=$(compgen -c | sort -u | fzf --reverse --prompt="run> ") && setsid -f $cmd ;;
  WiFi) nmtui ;;
  Volume) pulsemixer ;; # or: wiremix / alsamixer
  Monitor) btop ;;
  Power)
    p=$(printf 'lock\nsuspend\nreboot\npoweroff' | fzf --reverse)
    case "$p" in
    lock) i3lock ;; suspend) systemctl suspend ;;
    reboot) systemctl reboot ;; poweroff) systemctl poweroff ;;
    esac
    ;;
  *) i3-msg '[instance="sidebar"] scratchpad show' >/dev/null ;;
  esac
done
