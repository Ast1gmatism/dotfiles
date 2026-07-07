import Quickshell
import QtQuick
import qs.sideBar.containers
import qs.theme
import qs.popups

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: mainPanel
        required property var modelData
        screen: modelData
        color: Theme.glassPanel

        anchors {
            top: true
            left: true
            bottom: true
        }
        implicitWidth: Theme.sideBarWidth

        Top {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }

        Center {
            anchors {
                centerIn: parent
                left: parent.left
                right: parent.right
            }
        }

        Bottom {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }

        MainPopup { id: mainPopup }
    }
}