import QtQuick
import qs.theme

Rectangle {
    id: root

    property bool interactive: true
    property bool active: false

    property color normalColor: "transparent"
    property color hoverColor: Theme.hoverFillColor
    property color activeColor: normalColor

    property color normalBorderColor: "transparent"
    property color hoverBorderColor: "transparent"
    property color activeBorderColor: "transparent"

    property int animDuration: 120

    signal clicked()
    property bool hovered: hoverHandler.hovered

    HoverHandler {
        id: hoverHandler
        enabled: root.interactive
    }

    radius: 10
    color: active ? activeColor : (hovered ? hoverColor : normalColor)
    border.width: 1
    border.color: active ? activeBorderColor : (hovered ? hoverBorderColor : normalBorderColor)

    Behavior on color { ColorAnimation { duration: root.animDuration } }
    Behavior on border.color { ColorAnimation { duration: root.animDuration } }

    Loader {
        id: mouseLoader
        anchors.fill: parent
        active: root.interactive
        sourceComponent: Component {
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clicked()
            }
        }
    }
}