import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.theme

Item {
    id: root

    implicitWidth: 76       // FIXME:должно зависеть от дочки по аналогии с PowerWidget
    implicitHeight: 230     // FIXME: тоже

    // ── Данные ───────────────────────────────────────────────────────────────
    property real volumeLevel: 65
    property bool isMuted: false
    property string outputDevice: "Speakers"

    // ── Константы ────────────────────────────────────────────────────────────
    readonly property real buttonHeight: 36
    readonly property real columnSpacing: 12

    // ─────────────────────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // ═══════════════ Левая колонка (Слайдер громкости) ═══════════════
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Text {
                text: "Volume"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.mutedTextColor
                Layout.alignment: Qt.AlignHCenter
            }

            Slider {
                id: volumeSlider
                Layout.fillHeight: true
                Layout.preferredWidth: 24
                Layout.alignment: Qt.AlignHCenter

                orientation: Qt.Vertical
                from: 100
                to: 0
                value: root.volumeLevel
                padding: 0
                enabled: !root.isMuted

                onValueChanged: root.volumeLevel = value

                background: Rectangle {
                    x: volumeSlider.availableWidth / 2 - width / 2
                    width: 6
                    height: volumeSlider.availableHeight
                    radius: 3
                    color: Theme.hoverFillColor

                    Rectangle {
                        width: parent.width
                        height: (1 - volumeSlider.visualPosition) * parent.height
                        y: parent.height - height
                        radius: 3
                        color: root.isMuted ? Theme.disabledTextColor : Theme.volumeColor
                    }
                }

                handle: Rectangle {
                    x: (volumeSlider.availableWidth - width) / 2
                    y: volumeSlider.visualPosition * (volumeSlider.availableHeight - height)
                    width: 14
                    height: 14
                    radius: 7
                    color: volumeSlider.pressed ? Theme.volumeColor : Theme.foregroundColor
                    border.color: root.isMuted ? Theme.foregroundColor : Theme.volumeColor
                    border.width: 1
                }
            }

            Text {
                text: root.isMuted ? "0%" : Math.round(root.volumeLevel) + "%"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Theme.foregroundColor
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}