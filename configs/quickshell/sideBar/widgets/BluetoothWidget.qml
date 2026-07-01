import QtQuick
import qs.singletons
import qs.popups
import qs.components
import qs.theme

Item {
    id: root
    implicitWidth: btn.width
    implicitHeight: btn.height
    
    Component {
        id: bluetoothContent
        BluetoothPopup {}
    }

    StyleButton {
        id: btn
        buttonVisible: Bluetooth.adapter
        iconSource: {
            if (!Bluetooth.isEnabled) return Theme.iconsPath + "bluetooth/off.svg"
            if (Bluetooth.isConnected) return Theme.iconsPath + "bluetooth/connected.svg"
            return Theme.iconsPath + "bluetooth/on.svg"
        }
        onClicked: mainPopup.show(bluetoothContent, "left", "bottom", 10, 10, root)
    }
}