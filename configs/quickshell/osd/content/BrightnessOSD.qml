import QtQuick
import qs.theme

Item {
    id: root
    property real value: 0
    // TODO: полный реворк
    implicitWidth: 100
    implicitHeight: 30

    Row {
        anchors.centerIn: parent
        spacing: 12
        
        Text {
            text: "󰃞"
            font.family: Theme.fontFamily
            font.pixelSize: 24
            color: Theme.brightnessColor
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: Math.round(root.value * 100) + "%"
            font.family: Theme.fontFamily
            font.pixelSize: 18
            font.weight: Font.DemiBold
            color: Theme.foregroundColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}