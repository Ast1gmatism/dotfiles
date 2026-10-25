#!/usr/bin/env bash
# capture.sh — снимок экрана для оболочки.
#
#   capture.sh [ГЕОМЕТРИЯ] [РЕЖИМ] [ПАПКА]
#     ГЕОМЕТРИЯ  "X,Y WxH" или "" — весь экран
#     РЕЖИМ      clipboard | file | both   (по умолчанию clipboard)
#     ПАПКА      куда сохранять; пусто — умолчание (см. default_dir)
#
# Коды выхода:
#   0 — снимок сделан
#   3 — снимок сделан, но выбранная папка недоступна: сохранили в умолчание
#   1 — ошибка
#
# Вызывается, когда оверлей уже прозрачен, а его окно ещё замаплено: композитору
# нечего анимировать, поэтому в кадр попадает чистый экран. Ждать здесь нечего.

set -euo pipefail

REGION="${1:-}"
MODE="${2:-clipboard}"
WANTED_DIR="${3:-}"

notify() { notify-send -a Screenshot "$@" 2>/dev/null || true; }
fail()   { notify-send -u critical -a Screenshot "Скриншот не сделан" "$@" 2>/dev/null || true
           exit 1; }

case "$MODE" in
    clipboard|file|both) ;;
    *) echo "capture.sh: неизвестный режим «$MODE»" >&2
       fail "Неизвестный режим: $MODE" ;;
esac

# ── Куда сохранять ────────────────────────────────────────────────────────
# Умолчание берём не из имён папок, а из XDG: xdg-user-dir PICTURES возвращает
# путь на языке пользователя ("Изображения", "Pictures", "Bilder"). Если XDG
# не настроен — Pictures, потом просто домашняя папка.
default_dir() {
    local pics=""
    if command -v xdg-user-dir >/dev/null 2>&1; then
        pics="$(xdg-user-dir PICTURES 2>/dev/null || true)"
    fi
    [[ -n "$pics" && "$pics" != "$HOME" ]] || pics="$HOME/Pictures"
    printf '%s/Screenshots' "$pics"
}

grim_args=(grim)
[[ -n "$REGION" ]] && grim_args+=(-g "$REGION")

# Папка нужна только если пишем файл. В режиме clipboard её не трогаем —
# иначе недоступная папка зря сбрасывала бы выбор пользователя.
FALLBACK=0
file=""
if [[ "$MODE" != "clipboard" ]]; then
    if [[ -n "$WANTED_DIR" && -d "$WANTED_DIR" && -w "$WANTED_DIR" ]]; then
        DIR="$WANTED_DIR"
    else
        [[ -n "$WANTED_DIR" ]] && FALLBACK=1
        DIR="$(default_dir)"
    fi
    mkdir -p "$DIR" || fail "не удалось создать $DIR"
    file="$DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"
fi

case "$MODE" in
    clipboard)
        "${grim_args[@]}" - | wl-copy || fail "не удалось скопировать в буфер"
        notify "Скриншот" "Скопировано в буфер"
        ;;
    file)
        "${grim_args[@]}" "$file" || fail "не удалось сохранить файл"
        ;;
    both)
        "${grim_args[@]}" "$file" || fail "не удалось сохранить файл"
        ;;
esac

# Одно уведомление на снимок. Если файл записан — имя файла в нём есть всегда,
# остальное (буфер, откат папки) идёт припиской через « · ».
if [[ "$MODE" != "clipboard" ]]; then
    note="Сохранено: $(basename "$file")"

    if [[ "$MODE" == "both" ]]; then
        if wl-copy < "$file"; then
            note+=" · в буфере"
        else
            note+=" · буфер недоступен"
        fi
    fi

    if [[ $FALLBACK -eq 1 ]]; then
        note+=" · папка недоступна, в $DIR"
    fi

    notify -i "$file" "Скриншот" "$note"
fi

# Код 3 — сигнал оболочке забыть выбранный путь, чтобы уведомление не
# повторялось при каждом снимке. Само уведомление уже отправлено выше.
if [[ $FALLBACK -eq 1 ]]; then
    exit 3
fi
