import QtQuick
import Quickshell.Services.SystemTray
import qs.theme

Column {
    id: root

    width: Theme.sideBarWidth
    spacing: 4

    Repeater {
        model: SystemTray.items

        Item {
            id: trayItem

            required property var modelData

            width: root.width
            height: 24

            // Rectangle {
            //     anchors.fill: parent
            //     color: "red"
            // }

            Image {
                anchors.centerIn: parent

                width: 20
                height: 20

                source: trayItem.modelData.icon

                sourceSize.width: 20
                sourceSize.height: 20
            }

            MouseArea {
                anchors.fill: parent

                onClicked: trayItem.modelData.activate()
            }
        }
    }
}