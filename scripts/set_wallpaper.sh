#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
HYPRPAPER_CONF="$DOTFILES_ROOT/configs/hypr/hyprpaper.conf"
COLORS_JSON="$DOTFILES_ROOT/configs/quickshell/theme/colors.json"

if [[ ! -f "$WALLPAPER" ]]; then
    echo "❌ Файл не найден: $WALLPAPER" >&2
    exit 1
fi

WALLPAPER="$(realpath "$WALLPAPER")"

# 1. Обновляем строку path внутри секции wallpaper { ... }
sed -i "s|^\(\s*path\s*=\s*\).*|\1$WALLPAPER|" "$HYPRPAPER_CONF"

# 2. Применяем через hyprctl (если hyprland запущен и hyprpaper активен)
if command -v hyprctl &>/dev/null && hyprctl monitors &>/dev/null 2>&1; then
    MONITOR=$(grep -oP '(?<=monitor\s=\s).*' "$HYPRPAPER_CONF" | head -1 | xargs)
    FIT_MODE=$(grep -oP '(?<=fit_mode\s=\s).*' "$HYPRPAPER_CONF" | head -1 | xargs)
    
    # Формат: 'monitor,path,fit_mode' — fit_mode опциональный
    if hyprctl hyprpaper wallpaper "${MONITOR},${WALLPAPER},${FIT_MODE}" 2>/dev/null; then
        echo "✓ Обои применены на лету"
    else
        echo "⚠ Не удалось применить обои на лету (перезапусти hyprpaper)"
    fi
fi

# 3. Генерим палитру
"$SCRIPT_DIR/gen_colors.py" "$WALLPAPER" -o "$COLORS_JSON"

echo "✓ Обои: $(basename "$WALLPAPER")"
echo "✓ Палитра обновлена"