import QtQuick
import qs.singletons
import qs.popups
import qs.components
import qs.theme

Item {
    id: root
    implicitWidth: btn.width
    implicitHeight: btn.height

    StyleButton {
        id: btn
        buttonVisible: true
        iconSource: {
            return Theme.iconsPath + "cachyos.svg"
        }
        onClicked: console.log("Under construction!")
    }
}