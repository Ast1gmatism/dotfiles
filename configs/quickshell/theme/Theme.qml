pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // ── Роли: стекло (glassmorphism) ─────────────────────
    readonly property color glassPanel:           Qt.alpha(Colors.palette.base, 0.20)
    readonly property color glassContainer:       Qt.alpha(Colors.palette.base, 0.55)
    readonly property color glassGroup:           Qt.alpha(Colors.palette.surface0, 0.70)
    readonly property color glassSelect:          Qt.alpha(Colors.palette.base, 0.40)
    readonly property color glassBorder:          Qt.alpha(Colors.palette.text, 0.10)

    // ── Роли: текст ──────────────────────────────────────
    readonly property color foregroundColor:   Colors.palette.text
    readonly property color mutedTextColor:    Qt.alpha(Colors.palette.text, 0.55)
    readonly property color disabledTextColor: Qt.alpha(Colors.palette.text, 0.30)

    // ── Роли: состояния ───────────────────────────────────
    readonly property color successColor: Colors.palette.green
    readonly property color warningColor: Colors.palette.peach
    readonly property color errorColor:   Colors.palette.red

    // ── Роли: акценты ──────────────────────────────────────
    readonly property color accentColor: Colors.palette.accent1
    readonly property color onAccentColor: Colors.palette.crust
    // TODO: авто-контраст по формуле относительной яркости

    // ── Роли: заливки состояний UI ─────────────────────────
    readonly property color subtleFillColor:      Qt.alpha(Colors.palette.text, 0.06)
    readonly property color hoverFillColor:       Qt.alpha(Colors.palette.text, 0.10)

    // ── Роли: виджет-специфичные ────────────────────────────
    readonly property color batteryGradientStart: Colors.palette.accent2
    readonly property color batteryGradientMid:   Colors.palette.accent3
    readonly property color brightnessColor:      Colors.palette.yellow
    readonly property color redshiftColor:        Colors.palette.peach

    // ── Размеры, шрифты ──────────────────────────────────────
    // ── Отступы (spacing scale) ──────────────────────────────────────────────
    readonly property real spacingXS: 4   // плотные списки (уведомления)
    readonly property real spacingS: 8    // между элементами внутри секции, паддинг тайлов
    readonly property real spacingM: 12   // паддинг секций (GlassSection), внешние отступы попапа

    // ── Радиусы (radius scale) ────────────────────────────────────────────────
    readonly property real radiusS: 4     // мелкие элементы (кнопка закрытия)
    readonly property real radiusM: 10    // стандартный radius интерактивных поверхностей

    // ── Размеры иконок (icon scale) ──────────────────────────────────────────
    readonly property real iconXS: 8      // микро-иконки (крестик закрытия)
    readonly property real iconS: 14      // компактные иконки в составе строки
    readonly property real iconL: 18      // самостоятельные крупные иконки-тайлы
    readonly property real iconXL: 20     // главные кнопки компактных тулбаров (capture/close)

    // ── Размеры текста (text scale) ───────────────────────────────────────────
    readonly property real textCaption: 9
    readonly property real textBody: 10
    readonly property real textLabel: 11
    readonly property real textTitle: 12
    readonly property real textHeading: 13

    readonly property int sideBarWidth: 40
    readonly property int widgetHeight: 24
    readonly property int containerPadding: 6
    readonly property int popupBorderRadius: 16
    readonly property int popupBorderWidth: 1
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14
    readonly property string iconsPath: Qt.resolvedUrl("icons/")
}