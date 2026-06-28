import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.theme
import qs.singletons

Item {
    id: root

    implicitWidth: 260
    implicitHeight: 230

    // ── Данные ───────────────────────────────────────────────────────────────
    property real batteryLevel: Power.batteryLevel
    property bool isCharging: false
    property string timeRemaining: "~1:39"
    property real wattage: 15.2
    property string activeProfile: "balanced"
    property bool redshiftEnabled: true
    property real brightnessLevel: 5

    // ── Константы ────────────────────────────────────────────────────────────
    readonly property var profiles: [
        { id: "saver",    label: "Saver",    accent: Theme.successColor },
        { id: "balanced", label: "Balanced", accent: "#89b4fa" },
        { id: "perf",     label: "Perf",     accent: "#f38ba8" }
    ]

    readonly property color batteryGradientStart: "#c6a0f6"
    readonly property color batteryGradientEnd:   "#f5c2e7"
    readonly property color brightnessColor:      "#f9e2af"
    readonly property color redshiftColor:        "#fab387"

    readonly property real gaugeSize: 145
    readonly property real buttonHeight: 36
    readonly property real columnSpacing: 12

    // ─────────────────────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // ═══════════════ Левая колонка ═══════════════
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignTop
            spacing: root.columnSpacing

            // ── Круговой индикатор батареи ───────────────────────────────────
            Item {
                Layout.preferredWidth: root.gaugeSize
                Layout.preferredHeight: root.gaugeSize
                Layout.alignment: Qt.AlignHCenter

                readonly property real arcRadius: width / 2 - 7
                readonly property real arcThickness: 12
                readonly property real arcStartAngle: (210 - 90) * Math.PI / 180
                readonly property real arcSweep: 300 * Math.PI / 180

                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        ctx.lineWidth = parent.arcThickness
                        ctx.lineCap = "round"
                        ctx.strokeStyle = Qt.alpha(Theme.foregroundColor, 0.1)
                        ctx.beginPath()
                        ctx.arc(width / 2, height / 2, parent.arcRadius,
                                parent.arcStartAngle,
                                parent.arcStartAngle + parent.arcSweep)
                        ctx.stroke()
                    }
                }

                Canvas {
                    id: fillArc
                    anchors.fill: parent

                    Connections {
                        target: root
                        function onBatteryLevelChanged() { fillArc.requestPaint() }
                    }

                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()

                        const gradient = ctx.createLinearGradient(0, 0, width, height)
                        gradient.addColorStop(0, root.batteryGradientStart)
                        gradient.addColorStop(1, root.batteryGradientEnd)

                        ctx.lineWidth = parent.arcThickness
                        ctx.lineCap = "round"
                        ctx.strokeStyle = gradient
                        ctx.beginPath()
                        ctx.arc(width / 2, height / 2, parent.arcRadius,
                                parent.arcStartAngle,
                                parent.arcStartAngle + parent.arcSweep * (root.batteryLevel / 100))
                        ctx.stroke()
                    }
                }

                Text {
                    id: percentageText
                    anchors.centerIn: parent
                    text: Math.round(root.batteryLevel) + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 38
                    font.weight: Font.Bold
                    color: Theme.foregroundColor
                }

                Text {
                    anchors.top: percentageText.bottom
                    anchors.topMargin: -7
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (root.isCharging ? "+" : "-") + root.wattage.toFixed(1) + "W"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.isCharging
                           ? Theme.successColor
                           : Qt.alpha(Theme.foregroundColor, 0.6)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 3
                    text: root.timeRemaining
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: Qt.alpha(Theme.foregroundColor, 0.5)
                }
            }

            // ── Кнопки профилей ──────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: root.profiles

                    delegate: Rectangle {
                        id: profileBtn

                        required property var modelData

                        readonly property bool isActive: root.activeProfile === modelData.id

                        Layout.fillWidth: true
                        Layout.preferredHeight: root.buttonHeight
                        radius: 8

                        color: {
                            if (isActive)
                                return Qt.alpha(modelData.accent, 0.25)
                            if (profileArea.containsMouse)
                                return Qt.alpha(Theme.foregroundColor, 0.10)
                            return Qt.alpha(Theme.foregroundColor, 0.05)
                        }

                        border.color: isActive ? modelData.accent : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: profileBtn.modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: profileBtn.isActive ? Font.DemiBold : Font.Normal
                            color: profileBtn.isActive
                                   ? profileBtn.modelData.accent
                                   : Theme.foregroundColor
                        }

                        MouseArea {
                            id: profileArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeProfile = profileBtn.modelData.id
                        }
                    }
                }
            }
        }

        // ═══════════════ Разделитель ═══════════════
        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            color: Theme.borderColor
        }

        // ═══════════════ Правая колонка ═══════════════
        ColumnLayout {
            Layout.preferredWidth: root.buttonHeight
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignTop
            spacing: root.columnSpacing

            // ── Слайдер яркости ──────────────────────────────────────────────
            Slider {
                id: brightnessSlider

                Layout.preferredWidth: 24
                Layout.preferredHeight: root.gaugeSize
                Layout.alignment: Qt.AlignHCenter

                orientation: Qt.Vertical
                from: 100
                to: 1
                value: root.brightnessLevel
                padding: 0

                onValueChanged: root.brightnessLevel = value

                background: Rectangle {
                    x: brightnessSlider.availableWidth / 2 - width / 2
                    width: 6
                    height: brightnessSlider.availableHeight
                    radius: 3
                    color: Qt.alpha(Theme.foregroundColor, 0.1)

                    Rectangle {
                        width: parent.width
                        height: (1 - brightnessSlider.visualPosition) * parent.height
                        y: parent.height - height
                        radius: 3
                        color: root.brightnessColor
                    }
                }

                handle: Rectangle {
                    x: (brightnessSlider.availableWidth - width) / 2
                    y: brightnessSlider.visualPosition * (brightnessSlider.availableHeight - height)
                    width: 14
                    height: 14
                    radius: 7
                    color: brightnessSlider.pressed ? root.brightnessColor : Theme.foregroundColor
                    border.color: root.brightnessColor
                    border.width: 1
                }
            }

            // ── Кнопка RedShift ──────────────────────────────────────────────
            Rectangle {
                id: redshiftBtn

                Layout.preferredWidth: root.buttonHeight
                Layout.preferredHeight: root.buttonHeight
                Layout.alignment: Qt.AlignHCenter
                radius: 8

                color: {
                    if (root.redshiftEnabled)
                        return Qt.alpha(root.redshiftColor, 0.25)
                    if (rsMouseArea.containsMouse)
                        return Qt.alpha(Theme.foregroundColor, 0.10)
                    return Qt.alpha(Theme.foregroundColor, 0.05)
                }

                border.color: root.redshiftEnabled ? root.redshiftColor : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰖔"
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    color: root.redshiftEnabled ? root.redshiftColor : Theme.foregroundColor
                }

                MouseArea {
                    id: rsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.redshiftEnabled = !root.redshiftEnabled
                }
            }
        }
    }
}