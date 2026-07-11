#!/usr/bin/env bash

set -euo pipefail

# ── Константы ─────────────────────────────────────────────
SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}" # TODO: задавать конечную папку через ui захвата
GEOM_RAW="$1"
DEST="${2:-both}"
NAMESPACE="${3:-capture-test}"

# Подготовка
mkdir -p "$SCREENSHOT_DIR"
timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
filepath="$SCREENSHOT_DIR/$timestamp.png"

# Ждём, пока layer-surface с нужным namespace реально исчезнет
timeout=30
while [ "$(hyprctl layers -j | jq --arg ns "$NAMESPACE" '[.. | objects | select(.namespace? == $ns)] | length')" -gt 0 ] && [ $timeout -gt 0 ]; do
    sleep 0.05
    timeout=$((timeout - 1))
done

# Захват
grim_cmd=(grim)
[[ -n "$GEOM_RAW" ]] && grim_cmd+=(-g "$GEOM_RAW")

exit_code=0
case "$DEST" in
    clipboard)
        "${grim_cmd[@]}" - | wl-copy || exit_code=$?
        ;;
    file)
        "${grim_cmd[@]}" "$filepath" || exit_code=$?
        ;;
    both)
        "${grim_cmd[@]}" - | tee "$filepath" | wl-copy || exit_code=$?
        ;;
esac

# Отчёт
if [ $exit_code -eq 0 ]; then
    if [[ "$DEST" == "file" ]] || [[ "$DEST" == "both" ]]; then
        notify-send -a "Screenshot" -i "$filepath" "Screenshot Saved" "File: $(basename "$filepath")"
    else
        notify-send -a "Screenshot" "Screenshot Saved" "Copied to clipboard"
    fi
else
    notify-send -u critical -a "Screenshot" "Screenshot Failed" "grim exited with code $exit_code"
    exit $exit_code
fi