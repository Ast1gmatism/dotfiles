import QtQuick
import qs.theme
import qs.components

Rectangle {
    id: root

    property var options: []
    property string current: options.length > 0 ? options[0].value : ""
    signal changed(string value)

    readonly property int currentIndex: {
        for (let i = 0; i < options.length; i++)
            if (options[i].value === current) return i
        return 0
    }
    readonly property real segW: width / Math.max(options.length, 1)

    implicitHeight: 32
    radius: Theme.radiusM
    border.width: 1
    border.color: Theme.glassBorder
    color: Theme.glassSelect

    Rectangle {
        id: activePill
        width: root.segW
        height: root.height - root.border.width * 2
        y: root.border.width
        radius: root.radius
        x: root.segW * root.currentIndex
        color: Theme.accentColor

        Behavior on x {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
    }

    Row {
        anchors.fill: parent

        Repeater {
            model: root.options

            delegate: HoverSurface {
                id: segment
                required property var modelData

                width: root.segW
                height: root.height

                readonly property bool isActive: root.current === modelData.value

                normalColor: "transparent"
                hoverColor: "transparent"
                activeColor: "transparent"

                onClicked: root.changed(modelData.value)

                Text {
                    anchors.centerIn: parent
                    text: segment.modelData.label
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.iconL
                    color: segment.isActive
                        ? Theme.onAccentColor
                        : (segment.hovered ? Theme.accentColor : Theme.foregroundColor)

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }
        }
    }
}