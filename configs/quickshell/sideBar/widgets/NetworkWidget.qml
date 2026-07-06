import QtQuick
import qs.singletons
// import qs.popups
import qs.components
import qs.theme
// TODO: Wi-Fi попап
Item {
    implicitWidth: btn.width
    implicitHeight: btn.height

    StyleButton {
        id: btn
        buttonVisible: Network.wifi !== null
        iconSource: {
            if (!Network.isEnabled) return Theme.iconsPath + "wifi/slash.svg"
            if (Network.network) {
                const s = Network.signalStrength
                if (s < 34) return Theme.iconsPath + "wifi/low.svg"
                if (s < 67) return Theme.iconsPath + "wifi/medium.svg"
                return Theme.iconsPath + "wifi/high.svg"
            }
            return Theme.iconsPath + "wifi/none.svg"
        }
        onClicked: console.log("WiFi") // TODO: network popup
    }
}