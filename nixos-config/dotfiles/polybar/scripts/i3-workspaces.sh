#!/usr/bin/env bash
# Fixed-slot i3 workspace indicator for Polybar.
#
# Polybar's internal/i3 module only lists workspaces that i3 currently knows
# about, and i3 destroys empty workspaces when you leave them. This module
# always renders workspaces 1-5 and mirrors the focused/visible/urgent state
# that i3 reports.

set -u

# Keep in sync with [colors] in ~/.config/polybar/config.ini
BG="#0D0D0D"
FG="#F0F0F0"
FG_ALT="#9A9A9A"
PRIMARY="#4D4D4D"

SLOTS=(1 2 3 4 5)
mode="default"

render() {
  local line n state fg bg underline out=""
  local -A ws_state=()
  local -A occupied=()

  # Workspaces that currently contain at least one window. get_workspaces
  # doesn't expose this, so walk i3's layout tree instead.
  while IFS= read -r num; do
    [[ -n $num ]] && occupied[$num]=1
  done < <(i3-msg -t get_tree 2>/dev/null \
             | jq -r '.. | objects | select(.type == "workspace")
                      | select(([.. | objects | select(.window != null)] | length) > 0)
                      | .num')

  while IFS=$'\t' read -r num focused visible urgent; do
    [[ -z $num || $num == -1 ]] && continue
    if [[ $focused == true ]]; then
      ws_state[$num]=focused
    elif [[ $urgent == true ]]; then
      ws_state[$num]=urgent
    elif [[ $visible == true ]]; then
      ws_state[$num]=visible
    else
      ws_state[$num]=unfocused
    fi
  done < <(i3-msg -t get_workspaces 2>/dev/null \
             | jq -r '.[] | [(.num|tostring), .focused, .visible, .urgent] | @tsv')

  for n in "${SLOTS[@]}"; do
    state=${ws_state[$n]:-unfocused}
    case $state in
      focused) fg=$FG;     bg=$BG; underline=1 ;;  # solid underline
      visible) fg=$FG;     bg=$BG; underline=2 ;;  # dim underline
      urgent)  fg=$BG;     bg=$FG; underline=0 ;;  # inverted
      *)                                           # occupied slots light up too
        if [[ -n ${occupied[$n]:-} ]]; then
          fg=$FG; bg=$BG; underline=0
        else
          fg=$FG_ALT; bg=$BG; underline=0
        fi
        ;;
    esac

    out+="%{F$fg}%{B$bg}"
    case $underline in
      1) out+="%{u$FG}%{+u}" ;;
      2) out+="%{u$PRIMARY}%{+u}" ;;
    esac
    out+=" $n "
    (( underline )) && out+="%{-u}"
  done

  # i3 resize mode indicator (same chip styling as before).
  [[ $mode != default ]] && out+="%{B$PRIMARY}%{F$FG} $mode "

  printf '%s\n' "$out"
}

cleanup() {
  pkill -P $$ 2>/dev/null
  exit 0
}
trap cleanup TERM INT

# Reconnect if i3 restarts; subscribe keeps the bar instant on workspace
# changes without polling.
while :; do
  render
  while IFS= read -r line; do
    if jq -e 'has("current")' >/dev/null 2>&1 <<<"$line"; then
      render                      # workspace event
    else
      mode=$(jq -r '.change // "default"' <<<"$line" 2>/dev/null)
      render                      # binding mode event
    fi
  done < <(i3-msg -t subscribe -m '["workspace","mode"]' 2>/dev/null)
  sleep 1
done
