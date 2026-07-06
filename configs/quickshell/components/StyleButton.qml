import QtQuick
import QtQuick.Controls
import qs.theme

Item {
    id: root
    
    width: Theme.sideBarWidth
    height: btn.icon.height
    
    property alias iconSource: btn.icon.source
    property alias iconColor: btn.icon.color
    property alias iconWidth: btn.icon.width
    property alias iconHeight: btn.icon.height
    property alias buttonVisible: btn.visible
    
    signal clicked()
    
    Button {
        id: btn
        anchors.fill: parent
        background: Item {}
        icon.color: Theme.foregroundColor
        icon.width: Theme.widgetHeight
        icon.height: Theme.widgetHeight
        onClicked: root.clicked()
    }
}