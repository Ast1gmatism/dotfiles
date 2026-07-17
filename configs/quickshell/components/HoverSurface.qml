import QtQuick
import qs.theme

// Универсальный "hover-фон" для интерактивных плиток панели.
// Не содержит бизнес-логики клика:
//  - interactive: true  → включает встроенный MouseArea с сигналом clicked()
//  - interactive: false → hovered/active передаются снаружи, а клик
//    реализуется кастомным MouseArea в родителе (например, hold-to-confirm в PowerTile)
Rectangle {
    id: root

    property bool interactive: true
    property bool hovered: interactive ? mouseArea.containsMouse : false
    property bool active: false

    property color normalColor: "transparent"
    property color hoverColor: Theme.hoverFillColor
    property color activeColor: normalColor

    property color normalBorderColor: "transparent"
    property color hoverBorderColor: "transparent"
    property color activeBorderColor: "transparent"

    property int animDuration: 120

    signal clicked()

    radius: 10
    color: active ? activeColor : (hovered ? hoverColor : normalColor)
    border.width: 1
    border.color: active ? activeBorderColor : (hovered ? hoverBorderColor : normalBorderColor)

    Behavior on color { ColorAnimation { duration: root.animDuration } }
    Behavior on border.color { ColorAnimation { duration: root.animDuration } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.interactive
        visible: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}