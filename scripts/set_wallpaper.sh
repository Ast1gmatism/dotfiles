#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
HYPRPAPER_CONF="$DOTFILES_ROOT/configs/hypr/hyprpaper.conf"
COLORS_JSON="$DOTFILES_ROOT/configs/quickshell/theme/colors.json"

# Проверки
if [[ ! -f "$WALLPAPER" ]]; then
    echo "❌ Файл не найден: $WALLPAPER" >&2
    exit 1
fi

# 1. Обновляем hyprpaper.conf (меняем строку wallpaper)
sed -i "s|^wallpaper = ,.*|wallpaper = ,$WALLPAPER|" "$HYPRPAPER_CONF"

# 2. Применяем через hyprctl (если hyprland запущен)
if command -v hyprctl &>/dev/null && hyprctl monitors &>/dev/null 2>&1; then
    hyprctl hyprpaper wallpaper ",$WALLPAPER"
fi

# 3. Генерим палитру
"$SCRIPT_DIR/gen_colors.py" "$WALLPAPER" -o "$COLORS_JSON"

echo "✓ Обои: $(basename "$WALLPAPER")"
echo "✓ Палитра обновлена"