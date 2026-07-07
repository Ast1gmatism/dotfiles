import QtQuick
import Quickshell
import qs.theme

Column {
    id: menuRoot

    property var menu

    width: 180 // FIXME: должно зависеть от самого широкого элемента меню
    spacing: 2
    topPadding: 6
    bottomPadding: 6

    QsMenuOpener {
        id: opener
        menu: menuRoot.menu
    }

    Repeater {
        model: opener.children
        delegate: Loader {
            id: entryLoader
            required property QsMenuEntry modelData
            width: menuRoot.width
            sourceComponent: modelData.isSeparator ? separatorComponent : itemComponent
        }
    }

    Component {
        id: separatorComponent
        Rectangle {
            width: menuRoot.width - 12
            anchors.horizontalCenter: parent.horizontalCenter
            height: 1
            color: Theme.glassContainerBorder
        }
    }

    Component {
        id: itemComponent
        Rectangle {
            id: entryDelegate

            readonly property QsMenuEntry entry: parent.modelData

            width: menuRoot.width
            height: 28
            radius: 6
            color: mouseArea.containsMouse && entry.enabled
                   ? Theme.hoverFillColor
                   : "transparent"

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                text: entryDelegate.entry.text
                color: entryDelegate.entry.enabled ? Theme.foregroundColor : Theme.disabledTextColor
                elide: Text.ElideRight
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: entryDelegate.entry.enabled
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    entryDelegate.entry.triggered()
                    mainPopup._close()
                    // FIXME: прямой референс по id, заменить на функцию
                }
            }
        }
    }
}