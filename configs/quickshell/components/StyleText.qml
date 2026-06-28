import QtQuick
import qs.theme

Item {
    id: root
    
    width: Theme.sideBarWidth
    height: txt.implicitHeight 
    
    property alias text: txt.text
    property alias color: txt.color
    property alias fontSize: txt.font.pixelSize
    property alias fontWeight: txt.font.weight
    property alias horizontalAlignment: txt.horizontalAlignment
    
    signal clicked()
    
    Text {
        id: txt
        width: parent.width
        height: implicitHeight  
        font.family: Theme.fontFamily
        color: Theme.foregroundColor
        font.pixelSize: Theme.fontSize
        horizontalAlignment: Text.AlignHCenter
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}