pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // ── Роли: стекло (glassmorphism) ─────────────────────
    readonly property color glassPanel:           Qt.alpha(Colors.palette.base, 0.20)
    readonly property color glassContainer:       Qt.alpha(Colors.palette.base, 0.55)
    readonly property color glassContainerBorder: Qt.alpha(Colors.palette.text, 0.08)
    readonly property color glassGroupStart:      Qt.alpha(Colors.palette.surface1, 0.55)
    readonly property color glassGroupEnd:        Qt.alpha(Colors.palette.surface0, 0.40)
    readonly property color glassGroupBorder:     Qt.alpha(Colors.palette.text, 0.10)

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

    // ── Роли: заливки состояний UI ─────────────────────────
    readonly property color subtleFillColor:      Qt.alpha(Colors.palette.text, 0.06)
    readonly property color hoverFillColor:       Qt.alpha(Colors.palette.text, 0.10)
    readonly property color highlightBorderColor: Qt.alpha(Colors.palette.text, 0.15)
    readonly property color activeFillColor:      Qt.alpha(Colors.palette.accent1, 0.16)

    // ── Роли: виджет-специфичные ────────────────────────────
    readonly property color batteryGradientStart: Colors.palette.accent2
    readonly property color batteryGradientMid:   Colors.palette.accent3
    readonly property color brightnessColor:      Colors.palette.yellow
    readonly property color redshiftColor:        Colors.palette.peach
    readonly property color volumeColor:          Colors.palette.accent1

    // ── Размеры, шрифты ──────────────────────────────────────
    readonly property int sideBarWidth: 40
    readonly property int widgetHeight: 24
    readonly property int containerPadding: 6
    readonly property int popupBorderRadius: 16
    readonly property int popupBorderWidth: 1
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14
    readonly property string iconsPath: Qt.resolvedUrl("icons/")
}