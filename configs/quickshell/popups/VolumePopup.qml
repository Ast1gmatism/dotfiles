import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.theme

Item {
    id: root

    implicitWidth: 76
    implicitHeight: 230

    // ── Данные ───────────────────────────────────────────────────────────────
    property real volumeLevel: 65
    property bool isMuted: false
    property string outputDevice: "Speakers"

    // ── Константы ────────────────────────────────────────────────────────────
    readonly property color volumeColor: "#89b4fa" // Тот же синий из профилей
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
                color: Qt.alpha(Theme.foregroundColor, 0.6)
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
                    color: Qt.alpha(Theme.foregroundColor, 0.1)

                    Rectangle {
                        width: parent.width
                        height: (1 - volumeSlider.visualPosition) * parent.height
                        y: parent.height - height
                        radius: 3
                        color: root.isMuted ? Qt.alpha(Theme.foregroundColor, 0.3) : root.volumeColor
                    }
                }

                handle: Rectangle {
                    x: (volumeSlider.availableWidth - width) / 2
                    y: volumeSlider.visualPosition * (volumeSlider.availableHeight - height)
                    width: 14
                    height: 14
                    radius: 7
                    color: volumeSlider.pressed ? root.volumeColor : Theme.foregroundColor
                    border.color: root.isMuted ? Theme.foregroundColor : root.volumeColor
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