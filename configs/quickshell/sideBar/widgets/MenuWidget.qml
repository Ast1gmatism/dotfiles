import QtQuick
import qs.theme

Item {
    width: Theme.sideBarWidth
    height: Theme.sideBarWidth 
    Image {
        id: icon
        anchors.centerIn: parent
        source: Theme.iconsPath + "cachyos.svg"
        sourceSize.width: 26
        sourceSize.height: 26
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: console.log("Menu clicked") // TODO: main popup
    }
}