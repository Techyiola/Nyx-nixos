#!/usr/bin/env bash
# Polybar battery drain-rate helper — smoothed %/h plus estimated time remaining.
#
#   ↓60.3%/h (42m)   discharging — time until empty
#   ↑12.4%/h (0h51m) charging    — time until full
#
# Prints nothing when the battery is full or absent — the battery module
# (battery.sh) already covers those states. It appends this output right
# after the charge percentage, e.g. " 🔋 47%  ↓60.3%/h (42m)".
#
# power_now is noisy (it spikes on CPU bursts), so it is smoothed with an
# exponential moving average (~90 s time constant) kept in a state file:
# ~/.local/state/polybar/battery_drain
# If the battery does not export power_now, the rate falls back to tracking
# capacity changes across update intervals.

DOWN=$'↓'
UP=$'↑'

COL_NORMAL='#C8C8C8'   # matches colors.foreground
COL_CHARGE='#B9B9B9'   # matches colors.secondary

# --- locate the battery ----------------------------------------------------
bat=""
for d in /sys/class/power_supply/BAT*; do
    [ -r "$d/capacity" ] && { bat="$d"; break; }
done

if [ -z "$bat" ]; then
    exit 0   # battery.sh already shows "n/a" in this case
fi

num() { case "$1" in ''|*[!0-9]*) printf 0 ;; *) printf '%s' "$1" ;; esac; }

cap=$(num "$(cat "$bat/capacity" 2>/dev/null)")
status=$(cat "$bat/status" 2>/dev/null)
power=$(num "$(cat "$bat/power_now" 2>/dev/null)")     # µW   (may be missing)
e_now=$(num "$(cat "$bat/energy_now" 2>/dev/null)")    # µWh  (may be missing)
e_full=$(num "$(cat "$bat/energy_full" 2>/dev/null)")  # µWh  (may be missing)

# --- smoothed sample state: <epoch> <power µW> <capacity %> <rate %/h> ----
now=$(date +%s)
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/polybar"
state="$state_dir/battery_drain"
mkdir -p "$state_dir"

last_t=0 last_p=0 last_c=0 last_r=0
if [ -r "$state" ]; then
    read -r lt lp lc lr _ < "$state" || true
    last_t=$(num "${lt:-}") last_p=$(num "${lp:-}")
    last_c=$(num "${lc:-}") last_r=$(num "${lr:-}")
fi

dt=$((now - last_t))
[ "$dt" -ge 0 ] 2>/dev/null || dt=0

rate=0
hours=-1

if [ "$power" -gt 0 ] && [ "$e_full" -gt 0 ]; then
    # --- instantaneous draw, smoothed over ~90 s ---------------------------
    if [ "$last_p" -gt 0 ] && [ "$dt" -gt 0 ] && [ "$dt" -le 900 ]; then
        alpha=$(awk -v dt="$dt" 'BEGIN{printf "%.4f", 1 - exp(-dt / 90)}')
        p=$(awk -v a="$alpha" -v s="$last_p" -v i="$power" \
            'BEGIN{printf "%.0f", s + (i - s) * a}')
    else
        p=$power
    fi
    rate=$(awk -v p="$p" -v f="$e_full" 'BEGIN{printf "%.2f", p * 100 / f}')
    if [ "$status" = "Charging" ] && [ "$e_full" -gt "$e_now" ]; then
        hours=$(awk -v e="$((e_full - e_now))" -v p="$p" 'BEGIN{printf "%.3f", e / p}')
    else
        hours=$(awk -v e="$e_now" -v p="$p" 'BEGIN{printf "%.3f", e / p}')
    fi
    printf '%s %s %s %s\n' "$now" "$p" "$cap" "$rate" > "$state.tmp" && mv "$state.tmp" "$state"
elif [ "$last_c" -gt 0 ] && [ "$cap" -ne "$last_c" ] && [ "$dt" -gt 0 ]; then
    # --- fallback: rate from capacity deltas (window = time since change) --
    rate=$(awk -v lost="$((last_c - cap))" -v dt="$dt" 'BEGIN{printf "%.2f", lost * 3600 / dt}')
    hours=$(awk -v r="$rate" -v c="$cap" \
        'BEGIN{if (r > 0.05) printf "%.3f", (100 - c) / r; else print -1}')
    printf '%s %s %s %s\n' "$now" 0 "$cap" "$rate" > "$state.tmp" && mv "$state.tmp" "$state"
else
    # --- capacity unchanged (or no usable sensors): keep previous reading --
    rate=$last_r
fi

# --- format ---------------------------------------------------------------
if [ "$status" = "Full" ]; then
    exit 0   # nothing useful to add — the glyph already says it's full
fi

if [ "$status" = "Charging" ]; then
    arrow=$UP; col=$COL_CHARGE
else
    arrow=$DOWN; col=$COL_NORMAL
fi

rate_txt=$(awk -v r="$rate" 'BEGIN{if (r < 0) r = 0; printf "%.1f", r}')
time_txt=$(awk -v h="$hours" 'BEGIN{
    if (h < 0) { print "(--)"; exit }
    t = int(h * 60 + 0.5); if (t < 1) t = 1
    hh = int(t / 60); mm = t % 60
    if (hh > 99) { print "(99h+)"; exit }
    if (hh >= 1) printf "(%dh%02dm)", hh, mm
    else printf "(%dm)", mm
}')

printf '%s\n' "%{F${col}}${arrow}${rate_txt}%/h ${time_txt}%{F-}"
