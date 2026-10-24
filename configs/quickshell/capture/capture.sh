#!/usr/bin/env bash

set -euo pipefail

# ── Константы ─────────────────────────────────────────────
SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}" # TODO: задавать конечную папку через ui захвата
GEOM_RAW="$1"
DEST="${2:-both}"

# Подготовка
mkdir -p "$SCREENSHOT_DIR"
timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
filepath="$SCREENSHOT_DIR/$timestamp.png"

# Никаких ожиданий: к моменту вызова оверлей уже прозрачен, а окно ещё
# замаплено — композитор не анимирует закрытие слоя, и в кадр оно не попадает.
# (Раньше здесь был опрос `hyprctl layers`, но слой исчезает из списка в момент
# unmap — то есть ровно тогда, когда анимация закрытия только начинается.)

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