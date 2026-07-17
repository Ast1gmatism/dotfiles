import QtQuick
import QtQuick.Layouts
import qs.theme

ColumnLayout {
    id: root
    spacing: -15

    property real gaugeSize: 65
    property real thickness: 6
    property real gapDegrees: 70

    property real value: 0

    // Пороги автоцвета по значению (0..1). Можно переопределить сами пороги
    // или сразу valueColor/secondaryColor снаружи — тогда биндинг по умолчанию
    // будет заменён явным значением.
    property real warningThreshold: 0.65
    property real dangerThreshold: 0.85
    property color valueColor: root.levelColor(root.value, root.warningThreshold, root.dangerThreshold)

    property bool hasSecondary: false
    property real secondaryValue: 0
    property real secondaryThickness: 2
    property real secondaryWarningThreshold: 0.5
    property real secondaryDangerThreshold: 0.8
    property color secondaryColor: root.levelColor(root.secondaryValue, root.secondaryWarningThreshold, root.secondaryDangerThreshold)
    property real secondaryOpacity: 0.6

    property string centerText: ""
    property string centerSubText: ""
    property string name: ""

    function levelColor(v, warn, danger) {
        if (v >= danger) return Theme.errorColor
        if (v >= warn) return Theme.warningColor
        return Theme.successColor
    }

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