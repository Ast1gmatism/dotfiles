import QtQuick
import qs.singletons
import qs.components
import qs.theme

Item {
    implicitWidth: btn.width
    implicitHeight: btn.height

    StyleButton {
        id: btn
        buttonVisible: Network.hasAdapter
        iconSource: {
            if (!Network.isEnabled)             return Theme.iconsPath + "wifi/off.svg"
            if (!Network.isConnected)           return Theme.iconsPath + "wifi/none.svg"
            if (Network.signalStrength < 0.34)  return Theme.iconsPath + "wifi/low.svg"
            if (Network.signalStrength < 0.67)  return Theme.iconsPath + "wifi/medium.svg"
            return Theme.iconsPath + "wifi/high.svg"
        }
        onClicked: console.log("WiFi") // TODO: network popup
    }
}