pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // Цвета
    readonly property color backgroundColor: "#1f1f28"
    readonly property color surfaceColor:    "#2a2a37"
    readonly property color foregroundColor: "#c5c9c5"
    // readonly property color borderColor:     Qt.rgba(205, 214, 244, 0.15)

    readonly property color successColor:    "#a6e3a1"

    // Размеры
    readonly property int sideBarWidth: 40
    readonly property int widgetHeight: 24 
    readonly property int containerPadding: 6

    // Попапы
    readonly property int popupBorderRadius: 16
    readonly property int popupBorderWidth: 1

    // Шрифт
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14

    // Прочее
    readonly property string iconsPath: Qt.resolvedUrl("../icons/")
}