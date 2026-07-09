#!/usr/bin/env python3
"""
gen_colors.py — генерация палитры из обоев.
Зависимости: только stdlib Python + ImageMagick (`magick`).

Usage:
    python3 gen_colors.py wallpaper.jpg
    python3 gen_colors.py wallpaper.jpg -o colors.json
    python3 gen_colors.py wallpaper.jpg -v  # с диагностикой
"""

import argparse
import colorsys
import itertools
import json
import re
import subprocess
import sys
from pathlib import Path


# ── КОНФИГ ───────────────────────────────────────────────────
# Все параметры сгруппированы по назначению. Чтобы подстроить
# генерацию под свои обои — крутите цифры здесь, в код лезть
# не обязательно.

CONFIG = {

    # ── Фон (bg-лестница: crust → overlay2) ─────────────────
    "bg": {
        # На сколько сдвинуть светлоту относительно базового
        # цвета фона для каждого уровня лестницы.
        "lightness_steps": {
            "crust":    -0.04,
            "mantle":   -0.02,
            "base":      0.00,
            "surface0":  0.05,
            "surface1":  0.10,
            "surface2":  0.16,
            "overlay0":  0.24,
            "overlay1":  0.32,
            "overlay2":  0.40,
        },
        "lightness_min": 0.02,
        "lightness_max": 0.62,

        # Фото почти всегда занижены по чистоте цвета — усиливаем
        # исходную насыщенность перед клампом.
        "saturation_boost": 1.3,

        # Потолок применяется к базовой (ещё не затухшей) насыщенности,
        # до применения falloff по уровням.
        "saturation_ceiling": 0.34,

        # Затухание по уровням — дизайнерское решение: верхние (overlay)
        # слои спокойнее нижних (base/crust), чтобы не спорили по цвету
        # с текстом/акцентами.
        "saturation_falloff": {
            "crust":    1.00,
            "mantle":   1.00,
            "base":     1.00,
            "surface0": 0.95,
            "surface1": 0.90,
            "surface2": 0.82,
            "overlay0": 0.72,
            "overlay1": 0.64,
            "overlay2": 0.58,
        },

        # Абсолютный пол насыщенности — применяется ПОСЛЕ falloff,
        # как последняя подстраховка от почти-серого на самом верху
        # лестницы.
        "saturation_floor": 0.07,
    },

    # ── Текст ────────────────────────────────────────────────
    "text": {
        # fg считается "честным светлым" (годным напрямую под
        # текст), если его светлота выше min, а насыщенность
        # ниже max. Иначе fg — акцентный цвет, текст генерим
        # синтетически от фона.
        "fg_light_min_lightness": 0.65,
        "fg_light_max_saturation": 0.35,

        # Параметры, когда fg — честный светлый.
        "saturation_mult": 1.0,
        "min_lightness": 0.75,
        "subtext1_delta": -0.15,
        "subtext0_delta": -0.30,

        # Параметры, когда fg — акцентный (текст от bg).
        "synthetic_lightness": 0.88,
        "synthetic_saturation": 0.15,
    },

    # ── Акценты ──────────────────────────────────────────────
    "accent": {
        # Штраф за слишком светлый цвет в акцентах.
        "light_penalty_threshold": 0.70,
        "light_penalty_weight": 300,
        # Штраф за слишком блёклый (почти серый) цвет.
        "gray_penalty_threshold": 0.15,
        "gray_penalty_weight": 200,
        # Бонус за то, что цвет реально доминирует на фото
        # (по площади/весу пикселей), а не просто "попал" в топ-6.
        "dominance_weight": 40,
    },

    # ── UX-цвета (red/green/blue/...) ────────────────────────
    "ux": {
        "hues": {
            "red":     0,
            "peach":  25,
            "yellow": 45,
            "green": 115,
            "teal":  175,
            "blue":  220,
            "mauve": 270,
            "pink":  330,
        },
        # Насыщенность UX-цветов зависит от того, насколько
        # "живые" цвета вообще есть на фото (см. compute_mood_saturation).
        "saturation_min": 0.35,
        "saturation_max": 0.85,
        # Светлота фиксирована — так UX-цвета остаются
        # одинаково читаемыми на тёмном фоне независимо от фото.
        "lightness": 0.67,
    },
}


# ── ГЛОБАЛЬНЫЕ ФЛАГИ ─────────────────────────────────────────

VERBOSE = False


# ── УТИЛИТЫ ──────────────────────────────────────────────────

def clamp(x, lo, hi):
    return max(lo, min(hi, x))

def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hls(r, g, b):
    h, l, s = colorsys.rgb_to_hls(r/255, g/255, b/255)
    return h * 360, l, s

def hls_to_hex(h_deg, l, s):
    r, g, b = colorsys.hls_to_rgb(
        (h_deg % 360) / 360, clamp(l, 0, 1), clamp(s, 0, 1)
    )
    return "#{:02x}{:02x}{:02x}".format(
        int(clamp(round(r*255), 0, 255)),
        int(clamp(round(g*255), 0, 255)),
        int(clamp(round(b*255), 0, 255)),
    )

def hue_dist(h1, h2):
    d = abs(h1 - h2) % 360
    return min(d, 360 - d)

def vlog(*args, **kwargs):
    """Вывод диагностики — только если включён --verbose."""
    if VERBOSE:
        print(*args, **kwargs, file=sys.stderr)

def block(hex_color, label=""):
    """Цветной блок для терминала (диагностика)."""
    if not VERBOSE:
        return
    r, g, b = hex_to_rgb(hex_color)
    print(f"\033[48;2;{r};{g};{b}m          \033[0m {label:12s} {hex_color}", file=sys.stderr)


# ── MAGICK ───────────────────────────────────────────────────

def get_six_colors(image_path: Path):
    cmd = [
        "magick", str(image_path),
        "-resize", "100x100",
        "-colors", "6",
        "-format", "%c",
        "histogram:info:",
    ]
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, check=True).stdout
    except FileNotFoundError:
        sys.exit("Ошибка: `magick` не найден.")
    except subprocess.CalledProcessError as e:
        sys.exit(f"Ошибка magick:\n{e.stderr}")

    # TODO: формат вывода `histogram:info:` может отличаться между
    # версиями/сборками ImageMagick (6 vs 7, локализация чисел).
    # Сейчас парсер рассчитан на конкретный формат и молча пропускает
    # строки, которые не подошли под regex. Если на каких-то системах
    # начнёт возвращать пустой/неполный список цветов — разбираться тут.
    line_re = re.compile(r"^\s*(\d+):\s*\(.*?\)\s*(#[0-9A-Fa-f]{6})")
    colors = []
    for line in out.splitlines():
        m = line_re.match(line)
        if not m:
            continue
        colors.append({"count": int(m.group(1)), "hex": m.group(2)})

    if not colors:
        sys.exit(f"Не удалось извлечь цвета.\n{out}")

    for c in colors:
        r, g, b = hex_to_rgb(c["hex"])
        c["h"], c["l"], c["s"] = rgb_to_hls(r, g, b)

    return colors


# ── ВЫБОР РОЛЕЙ ──────────────────────────────────────────────

def pick_bg(colors):
    # TODO: обработка особых случаев не реализована. Эвристика
    # "самый тёмный цвет = фон" ломается на светлых обоях (там
    # результатом станет самый тёмный акцентный объект на фото,
    # а не реальный фон) и на монохромных/малоконтрастных фото.
    # Нужна отдельная ветка логики под "light mode".
    return min(colors, key=lambda c: c["l"])


def classify_fg(colors, bg):
    """
    fg = самый светлый из оставшихся.
    Если он реально светлый и ненасыщенный → "честный" fg для text.
    Иначе → акцент, text генерируем синтетически.
    """
    # TODO: см. TODO в pick_bg — если фон определён неверно (светлые
    # обои), то и классификация fg относительно него теряет смысл.
    rest = [c for c in colors if c is not bg]
    fg = max(rest, key=lambda c: c["l"])
    cfg = CONFIG["text"]
    is_light = (
        fg["l"] >= cfg["fg_light_min_lightness"] and
        fg["s"] <= cfg["fg_light_max_saturation"]
    )
    return fg, is_light


def pick_accents(candidates):
    cfg = CONFIG["accent"]

    if len(candidates) <= 3:
        # TODO: если candidates меньше 3 (например, однотонное фото),
        # часть accent1/2/3 в палитре просто не будет создана.
        # Шаблоны, ожидающие все три акцента, могут сломаться.
        chosen = list(candidates)
    else:
        total_weight = sum(c["count"] for c in candidates) or 1
        best_combo, best_score = None, -1

        for combo in itertools.combinations(candidates, 3):
            # разнообразие оттенков
            hue_score = sum(
                hue_dist(a["h"], b["h"])
                for a, b in itertools.combinations(combo, 2)
            )
            # штраф за слишком светлые/слишком блёклые цвета
            penalty = sum(
                max(0, c["l"] - cfg["light_penalty_threshold"]) * cfg["light_penalty_weight"] +
                max(0, cfg["gray_penalty_threshold"] - c["s"]) * cfg["gray_penalty_weight"]
                for c in combo
            )
            # бонус за то, что цвета реально заметны на фото
            dominance_bonus = (
                sum(c["count"] for c in combo) / total_weight
            ) * cfg["dominance_weight"]

            score = hue_score - penalty + dominance_bonus
            if score > best_score:
                best_score, best_combo = score, combo

        chosen = list(best_combo)

    chosen.sort(key=lambda c: c["count"], reverse=True)
    return chosen


# ── ПОСТРОЕНИЕ СЛОЁВ ─────────────────────────────────────────

def build_bg(bg):
    cfg = CONFIG["bg"]
    h = bg["h"]
    base_s = clamp(bg["s"] * cfg["saturation_boost"], 0, cfg["saturation_ceiling"])

    result = {}
    for name, dl in cfg["lightness_steps"].items():
        l = clamp(bg["l"] + dl, cfg["lightness_min"], cfg["lightness_max"])
        s = base_s * cfg["saturation_falloff"][name]
        s = max(s, cfg["saturation_floor"])
        result[name] = hls_to_hex(h, l, s)
    return result


def build_text(fg, fg_is_light, bg):
    cfg = CONFIG["text"]
    if fg_is_light:
        h, s = fg["h"], clamp(fg["s"] * cfg["saturation_mult"], 0, 1)
        base_l = max(fg["l"], cfg["min_lightness"])
    else:
        # fg оказался акцентом — делаем нейтральный светлый текст от bg
        h = bg["h"]
        s = cfg["synthetic_saturation"]
        base_l = cfg["synthetic_lightness"]

    return {
        "text":     hls_to_hex(h, base_l, s),
        "subtext1": hls_to_hex(h, clamp(base_l + cfg["subtext1_delta"], 0, 1), s),
        "subtext0": hls_to_hex(h, clamp(base_l + cfg["subtext0_delta"], 0, 1), s),
    }


def build_accents(accents):
    result = {}
    for i, a in enumerate(accents, 1):
        result[f"accent{i}"] = a["hex"].lower()
    return result


def compute_mood_saturation(colors):
    """
    Насыщенность "настроения" фото — смесь взвешенного по площади
    среднего и максимума. Так одиночный шумный/редкий пиксель
    с аномальной насыщенностью не задаёт мод для всей UX-палитры,
    но реально яркие фото всё равно дают более сочный результат.
    """
    if not colors:
        return 0.5
    total_weight = sum(c["count"] for c in colors) or 1
    weighted_avg = sum(c["s"] * c["count"] for c in colors) / total_weight
    max_s = max(c["s"] for c in colors)
    return 0.5 * weighted_avg + 0.5 * max_s


def build_ux(all_colors):
    cfg = CONFIG["ux"]
    mood_s = compute_mood_saturation(all_colors)

    final_s = cfg["saturation_min"] + clamp(mood_s, 0.0, 1.0) * (
        cfg["saturation_max"] - cfg["saturation_min"]
    )
    final_l = cfg["lightness"]

    result = {name: hls_to_hex(hue, final_l, final_s)
              for name, hue in cfg["hues"].items()}
    return result, final_s, final_l


# ── СБОРКА ───────────────────────────────────────────────────

def generate(image_path: Path, name: str):
    colors = get_six_colors(image_path)

    bg = pick_bg(colors)
    fg, fg_is_light = classify_fg(colors, bg)

    accent_pool = [c for c in colors if c is not bg and c is not fg]
    if not fg_is_light:
        accent_pool.append(fg)

    accents = pick_accents(accent_pool)
    ux, final_s, final_l = build_ux(colors)

    vlog("[gen_colors] исходные 6 цветов:")
    for c in sorted(colors, key=lambda c: c["count"], reverse=True):
        block(c["hex"], f"w={c['count']}")

    fg_role = "fg (светлый)" if fg_is_light else "fg → accent pool"
    vlog(f"\n[gen_colors] bg/fg:")
    block(bg["hex"], "bg")
    block(fg["hex"], fg_role)

    vlog(f"\n[gen_colors] accents (из {len(accent_pool)} кандидатов):")
    for i, a in enumerate(accents, 1):
        block(a["hex"], f"accent{i}")

    vlog(f"\n[gen_colors] UX mood: s={final_s:.2f} l={final_l:.2f}")

    palette = {"name": name}
    palette.update(build_bg(bg))
    palette.update(build_text(fg, fg_is_light, bg))
    palette.update(build_accents(accents))
    palette.update(ux)

    vlog("\n[gen_colors] финал:")
    for k, v in palette.items():
        if k == "name":
            continue
        block(v, k)

    return palette


def main():
    global VERBOSE

    parser = argparse.ArgumentParser(description="Генерация палитры из обоев")
    parser.add_argument("image", type=Path)
    parser.add_argument("-o", "--output", type=Path, default=None)
    parser.add_argument("--name", default=None)
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="показать диагностику (цвета в терминале, логи)")
    args = parser.parse_args()

    VERBOSE = args.verbose

    if not args.image.exists():
        sys.exit(f"Файл не найден: {args.image}")

    name = args.name or f"generated-{args.image.stem}"
    palette = generate(args.image, name)

    js = json.dumps(palette, indent=4, ensure_ascii=False)
    if args.output:
        args.output.write_text(js + "\n")
        vlog(f"\n[gen_colors] → {args.output}")
    else:
        print(js)


if __name__ == "__main__":
    main()