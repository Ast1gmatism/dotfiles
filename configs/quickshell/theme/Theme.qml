pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // ── Роли: фон и поверхности ──────────────────────────
    readonly property color backgroundColor: Colors.palette.base
    readonly property color surfaceColor:    Colors.palette.surface0
    readonly property color borderColor:     Qt.alpha(Colors.palette.lavender, 0.15)

    // ── Роли: текст ──────────────────────────────────────
    readonly property color foregroundColor: Colors.palette.text
    readonly property color mutedTextColor:  Qt.alpha(Colors.palette.text, 0.55)

    // ── Роли: состояния ──────────────────────────────────
    readonly property color successColor: Colors.palette.green
    readonly property color warningColor: Colors.palette.peach
    readonly property color errorColor:   Colors.palette.red

    // ── Роли: акценты ────────────────────────────────────
    readonly property color accentStrongColor: Colors.palette.lavender
    readonly property color accentSoftColor:   Colors.palette.overlay2

    // ── Роли: заливки состояний UI ───────────────────────
    readonly property color subtleFillColor: Qt.alpha(Colors.palette.text, 0.06)
    readonly property color hoverFillColor:  Qt.alpha(Colors.palette.text, 0.10)
    readonly property color activeFillColor: Qt.alpha(Colors.palette.lavender, 0.16)

    // ── Роли: виджет-специфичные ─────────────────────────
    readonly property color batteryGradientStart: Colors.palette.mauve
    readonly property color batteryGradientMid:   Colors.palette.pink
    readonly property color brightnessColor:      Colors.palette.yellow
    readonly property color redshiftColor:        Colors.palette.peach
    readonly property color volumeColor:          Colors.palette.blue

    // ── Размеры, шрифты ──────────────────────────────────
    readonly property int sideBarWidth: 40
    readonly property int widgetHeight: 24
    readonly property int containerPadding: 6
    readonly property int popupBorderRadius: 16
    readonly property int popupBorderWidth: 1
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14
    readonly property string iconsPath: Qt.resolvedUrl("../icons/")
}