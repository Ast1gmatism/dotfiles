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
        id: powerContent
        PowerPopup {}
    }

    StyleButton {
        id: btn
        iconSource: {
            const p = Power.batteryLevel
            if (!Power.isCharging && p < 10) return Theme.iconsPath + "battery/critical.svg"
            if (p === 0) return Theme.iconsPath + "battery/empty.svg"
            if (p <= 30) return Theme.iconsPath + "battery/low.svg"
            if (p <= 60) return Theme.iconsPath + "battery/medium.svg"
            if (p <= 90) return Theme.iconsPath + "battery/high.svg"
            return Theme.iconsPath + "battery/full.svg"
        }
        onClicked: mainPopup.toggle(powerContent, root, 10)
    }

    Rectangle {
        x: 23
        y: 3
        width: 6
        height: 6
        radius: 3
        color: Theme.successColor
        visible: Power.onAC
    }
}