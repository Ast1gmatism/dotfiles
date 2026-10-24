#!/usr/bin/env bash
# capture.sh — снимок экрана для оболочки.
#
#   capture.sh [ГЕОМЕТРИЯ] [РЕЖИМ]
#     ГЕОМЕТРИЯ  "X,Y WxH" или "" — весь экран
#     РЕЖИМ      clipboard | file | both   (по умолчанию both)
#
# Вызывается, когда оверлей уже прозрачен, а его окно ещё замаплено: композитору
# нечего анимировать, поэтому в кадр попадает чистый экран. Ждать здесь нечего.

set -euo pipefail

DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
REGION="${1:-}"
MODE="${2:-both}"

notify() { notify-send -a Screenshot "$@" 2>/dev/null || true; }
fail()   { notify-send -u critical -a Screenshot "Скриншот не сделан" "$@" 2>/dev/null || true
           exit 1; }

case "$MODE" in
    clipboard|file|both) ;;
    *) echo "capture.sh: неизвестный режим «$MODE»" >&2
       fail "Неизвестный режим: $MODE" ;;
esac

grim_args=(grim)
[[ -n "$REGION" ]] && grim_args+=(-g "$REGION")

file=""
if [[ "$MODE" != "clipboard" ]]; then
    mkdir -p "$DIR"
    file="$DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"
fi

case "$MODE" in
    clipboard)
        "${grim_args[@]}" - | wl-copy || fail "не удалось скопировать в буфер"
        notify "Скриншот" "Скопировано в буфер"
        ;;
    file)
        "${grim_args[@]}" "$file" || fail "не удалось сохранить файл"
        notify -i "$file" "Скриншот" "Файл: $(basename "$file")"
        ;;
    both)
        "${grim_args[@]}" "$file" || fail "не удалось сохранить файл"
        if wl-copy < "$file"; then
            notify -i "$file" "Скриншот" "Файл + буфер"
        else
            notify -i "$file" "Скриншот (только файл)" "Буфер недоступен"
        fi
        ;;
esac
