import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.theme
import qs.singletons

Item {
    id: root

    implicitWidth: mainRow.implicitWidth + 2 * root.outerMargin
    implicitHeight: mainRow.implicitHeight + 2 * root.outerMargin

    // ── Данные ───────────────────────────────────────────────────────────────
    readonly property string activeProfile: Power.activeProfile
    readonly property bool redshiftEnabled: Power.redshiftEnabled

    // ── Константы ────────────────────────────────────────────────────────────
    readonly property var profiles: [
        { id: "saver",    icon: "󰌪" },
        { id: "balanced", icon: "󰾅" },
        { id: "perf",     icon: "󰓅" }
    ]

    readonly property real gaugeSize: 145
    readonly property real buttonHeight: 36

    // ── Отступы ────────────────────────────────────────────────
    readonly property real outerMargin: 12     // от края попапа до контента (RowLayout)
    readonly property real itemSpacing: 12     // между левой и правой секцией
    readonly property real sectionPadding: 12  // от края секции (Rectangle) до её контента
    readonly property real columnSpacing: 12   // между виджетами внутри одной колонки
    readonly property real sectionRadius: 12

    // ── Параметры дуги батареи ─────────────────────────────────
    readonly property real ringThickness: 10
    readonly property real ringGapDegrees: 60
    readonly property int ringSegments: 48

    function lerpColor(c1, c2, t) {
        return Qt.rgba(
            c1.r + (c2.r - c1.r) * t,
            c1.g + (c2.g - c1.g) * t,
            c1.b + (c2.b - c1.b) * t,
            c1.a + (c2.a - c1.a) * t
        )
    }

    function ringColorAt(t) {
        return t < 0.5
            ? lerpColor(Theme.batteryGradientStart, Theme.batteryGradientMid, t / 0.5)
            : lerpColor(Theme.batteryGradientMid, Theme.batteryGradientStart, (t - 0.5) / 0.5)
    }

    // ─────────────────────────────────────────────────────────────────────────
    RowLayout {
        id: mainRow
        anchors.centerIn: parent
        spacing: root.itemSpacing

        // ═══════════════ Левая секция ═══════════════
        Rectangle {
            implicitWidth: leftGroup.implicitWidth + 2 * root.sectionPadding
            implicitHeight: leftGroup.implicitHeight + 2 * root.sectionPadding
            Layout.fillHeight: true

            radius: root.sectionRadius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.glassGroupStart }
                GradientStop { position: 1.0; color: Theme.glassGroupEnd }
            }

            ColumnLayout {
                id: leftGroup
                anchors.centerIn: parent
                spacing: root.columnSpacing

                // ── Круговой индикатор батареи ───────────────────────────────
                Item {
                    id: chargeRing
                    Layout.preferredWidth: root.gaugeSize
                    Layout.preferredHeight: root.gaugeSize
                    Layout.alignment: Qt.AlignHCenter

                    readonly property real arcRadius: width / 2 - root.ringThickness / 2
                    readonly property real sweepDegrees: 360 - root.ringGapDegrees
                    readonly property real startAngle: (90 + root.ringGapDegrees / 2) * Math.PI / 180
                    readonly property real sweepRad: sweepDegrees * Math.PI / 180

                    Canvas {
                        id: trackCanvas
                        anchors.fill: parent
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            ctx.lineWidth = root.ringThickness
                            ctx.lineCap = "round"
                            ctx.strokeStyle = Qt.rgba(205/255, 214/255, 244/255, 0.1)
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, chargeRing.arcRadius,
                                    chargeRing.startAngle, chargeRing.startAngle + chargeRing.sweepRad)
                            ctx.stroke()
                        }
                    }

                    Canvas {
                        id: fillCanvas
                        anchors.fill: parent

                        Connections {
                            target: Power
                            function onBatteryLevelChanged() { fillCanvas.requestPaint() }
                        }

                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()

                            const fillSweep = chargeRing.sweepRad * (Power.batteryLevel / 100)
                            if (fillSweep <= 0) return

                            const segAngle = fillSweep / root.ringSegments
                            const overlap = segAngle * 0.15

                            for (let i = 0; i < root.ringSegments; i++) {
                                const t0 = i / root.ringSegments
                                const t1 = (i + 1) / root.ringSegments
                                const a0 = chargeRing.startAngle + segAngle * i - (i > 0 ? overlap : 0)
                                const a1 = chargeRing.startAngle + segAngle * (i + 1) + (i < root.ringSegments - 1 ? overlap : 0)

                                ctx.strokeStyle = root.ringColorAt((t0 + t1) / 2)
                                ctx.lineWidth = root.ringThickness
                                ctx.lineCap = (i === 0 || i === root.ringSegments - 1) ? "round" : "butt"
                                ctx.beginPath()
                                ctx.arc(width / 2, height / 2, chargeRing.arcRadius, a0, a1)
                                ctx.stroke()
                            }
                        }
                    }

                    Text {
                        id: percentageText
                        anchors.centerIn: parent
                        text: Math.round(Power.batteryLevel) + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: 30
                        font.weight: Font.DemiBold
                        color: Theme.foregroundColor
                    }

                    Text {
                        anchors.top: percentageText.bottom
                        anchors.topMargin: -7
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Power.wattsStr
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Power.isCharging
                            ? Theme.successColor
                            : Theme.mutedTextColor
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                        text: Power.timeStr
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: Theme.mutedTextColor
                    }
                }

                // ── Кнопки профилей ──────────────────────────────────────────
                Rectangle {
                    id: profileSwitch
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.buttonHeight
                    radius: 10
                    border.width: 1
                    border.color: Theme.glassContainerBorder

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.glassGroupEnd }
                        GradientStop { position: 1.0; color: Theme.glassGroupStart }
                    }

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
                                        ? Theme.accentColor
                                        : Theme.foregroundColor
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Power.setProfile(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════ Правая секция ═══════════════
        Rectangle {
            implicitWidth: rightGroup.implicitWidth + 2 * root.sectionPadding
            implicitHeight: rightGroup.implicitHeight + 2 * root.sectionPadding
            Layout.fillHeight: true

            radius: root.sectionRadius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.glassGroupStart }
                GradientStop { position: 1.0; color: Theme.glassGroupEnd }
            }

            ColumnLayout {
                id: rightGroup
                anchors.centerIn: parent
                spacing: root.columnSpacing

                // ── Слайдер яркости ──────────────────────────────────────────
                Item {
                    id: brightnessControl

                    Layout.preferredWidth: 24
                    Layout.preferredHeight: root.gaugeSize
                    Layout.alignment: Qt.AlignHCenter

                    property bool isDragging: false

                    readonly property real ratio: Power.brightness
                    readonly property real availableTravel: Math.max(1, height - width)

                    Rectangle {
                        id: track
                        anchors.fill: parent
                        radius: width / 2
                        color: Theme.subtleFillColor
                        border.color: Theme.glassContainerBorder
                        border.width: 1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: parent.width + brightnessControl.ratio * brightnessControl.availableTravel
                            radius: width / 2
                            color: Theme.brightnessColor

                            Behavior on height {
                                enabled: !brightnessControl.isDragging
                                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    MouseArea {
                        id: brightnessArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onPressed: (mouse) => {
                            brightnessControl.isDragging = false
                            setBrightnessFromY(mouse.y)
                        }
                        onPositionChanged: (mouse) => {
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

                // ── Кнопка RedShift ──────────────────────────────────────────
                Rectangle {
                    id: redshiftBtn

                    Layout.preferredWidth: root.buttonHeight
                    Layout.preferredHeight: root.buttonHeight
                    Layout.alignment: Qt.AlignHCenter
                    radius: 8

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.glassGroupEnd }
                        GradientStop { position: 1.0; color: Theme.glassGroupStart }
                    }

                    border.color: root.redshiftEnabled ? Theme.redshiftColor : Theme.glassContainerBorder
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰖔"
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                        color: root.redshiftEnabled ? Theme.redshiftColor : Theme.foregroundColor
                    }

                    MouseArea {
                        id: rsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Power.redshiftEnabled = !Power.redshiftEnabled
                    }
                }
            }
        }
    }
}