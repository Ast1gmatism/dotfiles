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

    // ── Константы ────────────────────────────────────────────────────────────
    readonly property var profiles: [
        { id: "saver",    icon: "󰌪" },
        { id: "balanced", icon: "󰾅" },
        { id: "perf",     icon: "󰓅" }
    ]

    readonly property color batteryGradientStart: Theme.accentSoftColor
    readonly property color batteryGradientEnd: Theme.accentStrongColor
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
            Rectangle {
                id: profileSwitch
                Layout.fillWidth: true
                Layout.preferredHeight: root.buttonHeight
                radius: 10
                color: Theme.subtleFillColor
                border.color: Theme.borderColor
                border.width: 1

                readonly property int currentIndex: {
                    for (let i = 0; i < root.profiles.length; ++i) {
                        if (root.profiles[i].id === root.activeProfile)
                            return i
                    }
                    return 0
                }

                Rectangle {
                    id: activePill
                    width: parent.width / root.profiles.length
                    height: parent.height
                    radius: 10
                    x: width * profileSwitch.currentIndex
                    color: Theme.activeFillColor

                    Behavior on x {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                }

                Row {
                    anchors.fill: parent

                    Repeater {
                        model: root.profiles

                        delegate: Item {
                            width: profileSwitch.width / root.profiles.length
                            height: profileSwitch.height

                            required property var modelData
                            readonly property bool isActive: root.activeProfile === modelData.id

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.family: Theme.fontFamily
                                font.pixelSize: 16
                                color: parent.isActive
                                    ? Theme.accentStrongColor
                                    : Theme.foregroundColor
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeProfile = modelData.id
                            }
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
            Item {
                id: brightnessControl

                Layout.preferredWidth: 24
                Layout.preferredHeight: root.gaugeSize
                Layout.alignment: Qt.AlignHCenter

                property bool isDragging: false // ← отслеживаем только реальный drag

                readonly property real ratio: Power.brightness
                readonly property real availableTravel: Math.max(1, height - width)

                Rectangle {
                    id: track
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.alpha(Theme.foregroundColor, 0.05)
                    border.color: Theme.borderColor
                    border.width: 1

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: parent.width + brightnessControl.ratio * brightnessControl.availableTravel
                        radius: width / 2
                        color: root.brightnessColor

                        Behavior on height {
                            enabled: !brightnessControl.isDragging // ← анимируем всё, кроме драга
                            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                        }
                    }
                }

                MouseArea {
                    id: brightnessArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: {
                        brightnessControl.isDragging = false
                        setBrightnessFromY(mouse.y)
                    }
                    onPositionChanged: {
                        if (pressed) brightnessControl.isDragging = true
                        setBrightnessFromY(mouse.y)
                    }
                    onReleased: brightnessControl.isDragging = false

                    function setBrightnessFromY(y) {
                        const clampedY = Math.max(0, Math.min(brightnessControl.availableTravel, y))
                        const newRatio = 1 - (clampedY / brightnessControl.availableTravel)
                        Power.set(newRatio)
                    }
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