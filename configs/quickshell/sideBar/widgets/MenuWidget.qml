import QtQuick
import qs.theme
import qs.popups.content

Item {
    id: root
    width: Theme.sideBarWidth
    height: Theme.sideBarWidth 

    Component {
        id: controlContent
        ControlCenter {}
    }

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
        onClicked: mainPopup.toggle(controlContent, root, 10)
    }
}