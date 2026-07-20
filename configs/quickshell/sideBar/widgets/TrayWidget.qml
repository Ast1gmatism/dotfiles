import QtQuick
import Quickshell.Services.SystemTray
import Quickshell
import qs.theme
import qs.popups.content

Column {
    id: root

    width: Theme.sideBarWidth
    spacing: 4

    Repeater {
        model: SystemTray.items

        Item {
            id: trayItem

            required property var modelData
            Component.onDestruction: mainPopup.close()

            width: root.width
            height: 24

            Component {
                id: trayMenuComponent
                TrayMenu {
                    menu: trayItem.modelData.menu
                    onCloseRequested: mainPopup.close()
                }
            }

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
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        trayItem.modelData.activate()
                    } else if (mouse.button === Qt.RightButton) {
                        // FIXME: определиться с консистентностью — TrayWidget не использует
                        // StyleButton/WidgetButton, т.к. нужна обработка правого клика.
                        // Либо расширить WidgetButton под это, либо явно оставить TrayWidget особым случаем.
                        if (trayItem.modelData.hasMenu)
                            mainPopup.toggle(trayMenuComponent, trayItem, 10)
                    }
                }
            }
        }
    }
}