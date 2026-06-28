import QtQuick
import Quickshell.Hyprland
import qs.theme

Column {
    id: root
    spacing: 4
    anchors.horizontalCenter: parent.horizontalCenter
    
    property int hoveredId: -1  
    
    Repeater {
        model: 4

        Rectangle {
            required property int index
            
            readonly property int workspaceId: index + 1
            readonly property bool isActive: Hyprland.focusedWorkspace.id === workspaceId
            readonly property bool isHovered: root.hoveredId === workspaceId
            readonly property bool isEmpty: !Hyprland.workspaces.values.some(w => w.id === workspaceId)

            width: 16
            height: isActive ? 35 : 16
            radius: 8

            color: isEmpty ? "transparent" : Theme.foregroundColor
            border.color: Theme.foregroundColor
            
            opacity: {
                if (root.hoveredId !== -1) {
                    return isHovered ? 1.0 : 0.6
                }
                return isActive ? 1.0 : 0.6
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.hoveredId = parent.workspaceId
                onExited: root.hoveredId = -1
                onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = '${parent.workspaceId}'})`)
            }

            Behavior on height  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on color   { ColorAnimation  { duration: 200; easing.type: Easing.OutCubic } }
        }
    }
}