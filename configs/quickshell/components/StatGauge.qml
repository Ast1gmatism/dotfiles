// qs/components/StatGaugeTile.qml
import QtQuick
import QtQuick.Layouts
import qs.theme

ColumnLayout {
    id: root
    spacing: -15

    property real gaugeSize: 80
    property real thickness: 6
    property real gapDegrees: 60

    property real value: 0
    property color valueColor: Theme.accentColor

    property bool hasSecondary: false
    property real secondaryValue: 0
    property real secondaryThickness: 2
    property color secondaryColor: Theme.warningColor
    property real secondaryOpacity: 0.6

    property string centerText: ""
    property string centerSubText: ""
    property string name: ""

    Item {
        Layout.preferredWidth: root.gaugeSize
        Layout.preferredHeight: root.gaugeSize
        Layout.alignment: Qt.AlignHCenter

        ArcGauge {
            anchors.fill: parent
            thickness: root.thickness
            gapDegrees: root.gapDegrees
            value: root.value
            fillColor: root.valueColor
        }

        ArcGauge {
            anchors.fill: parent
            visible: root.hasSecondary
            thickness: root.secondaryThickness
            gapDegrees: root.gapDegrees
            radius: width / 2 - root.thickness - 4 - root.secondaryThickness / 2
            value: root.secondaryValue
            fillColor: Qt.rgba(root.secondaryColor.r, root.secondaryColor.g, root.secondaryColor.b, root.secondaryOpacity)
            trackColor: Qt.rgba(1, 1, 1, 0.05)
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.centerText
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Theme.foregroundColor
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: root.centerSubText.length > 0
                text: root.centerSubText
                font.family: Theme.fontFamily
                font.pixelSize: 9
                color: Theme.mutedTextColor
            }
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.name
        font.family: Theme.fontFamily
        font.pixelSize: 10
        color: Theme.mutedTextColor
    }
}