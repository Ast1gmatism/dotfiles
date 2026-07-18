import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.theme
import qs.singletons
import qs.components

Item {
    id: root

    implicitWidth: mainRow.implicitWidth + 2 * root.outerMargin
    implicitHeight: mainRow.implicitHeight + 2 * root.outerMargin

    // ── Данные ───────────────────────────────────────────────────────────────
    readonly property string activeProfile: Power.activeProfile
    readonly property bool redshiftEnabled: Power.redshiftEnabled

    // ── Константы ────────────────────────────────────────────────────────────
    readonly property var profiles: [
        { id: "saver",    icon: "󰾆" },
        { id: "balanced", icon: "󰾅" },
        { id: "perf",     icon: "󰓅" }
    ]

    readonly property real gaugeSize: 145
    readonly property real buttonHeight: 36

    // ── Отступы ──────────────────────────────────────────────────────────────
    readonly property real outerMargin: 12
    readonly property real itemSpacing: 12
    readonly property real sectionPadding: 12
    readonly property real columnSpacing: 12

    // ── Параметры дуги батареи ───────────────────────────────────────────────
    readonly property real ringThickness: 10
    readonly property real ringGapDegrees: 60
    readonly property int ringSegments: 50

    // ─────────────────────────────────────────────────────────────────────────
    RowLayout {
        id: mainRow
        anchors.centerIn: parent
        spacing: root.itemSpacing

        // ═══════════════ Левая секция ═══════════════
        GlassSection {
            Layout.fillHeight: true
            padding: root.sectionPadding

            ColumnLayout {
                id: leftGroup
                anchors.centerIn: parent
                spacing: root.columnSpacing

                // ── Индикатор батареи ────────────────────────────────────────
                BatteryArc {
                    Layout.preferredWidth: root.gaugeSize
                    Layout.preferredHeight: root.gaugeSize
                    Layout.alignment: Qt.AlignHCenter

                    size: root.gaugeSize
                    thickness: root.ringThickness
                    gapDegrees: root.ringGapDegrees
                    segments: root.ringSegments
                }

                // ── Кнопки профилей ──────────────────────────────────────────
                Rectangle {
                    id: profileSwitch
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.buttonHeight
                    radius: Theme.radiusM
                    border.width: 1
                    border.color: Theme.glassBorder

                    color: Theme.glassSelect

                    readonly property int currentIndex: {
                        const idx = root.profiles.findIndex(p => p.id === root.activeProfile)
                        return idx >= 0 ? idx : 0
                    }

                    Rectangle {
                        width: parent.width / root.profiles.length
                        height: parent.height - parent.border.width * 2
                        y: parent.border.width
                        radius: profileSwitch.radius
                        x: width * profileSwitch.currentIndex
                        color: Theme.accentColor

                        Behavior on x {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }
                    }

                    Row {
                        anchors.fill: parent

                        Repeater {
                            model: root.profiles

                            delegate: HoverSurface {
                                id: profileSegment
                                required property var modelData
                                width: profileSwitch.width / root.profiles.length
                                height: profileSwitch.height

                                readonly property bool isActive: root.activeProfile === modelData.id

                                normalColor: "transparent"
                                hoverColor: "transparent"
                                activeColor: "transparent"

                                onClicked: Power.setProfile(modelData.id)

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.iconL
                                    color: profileSegment.isActive
                                        ? Theme.onAccentColor
                                        : (profileSegment.hovered ? Theme.accentColor : Theme.foregroundColor)
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════ Правая секция ═══════════════
        GlassSection {
            Layout.fillHeight: true
            padding: root.sectionPadding

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
                        border.color: Theme.glassBorder
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
                HoverSurface {
                    id: redshiftBtn
                    Layout.preferredWidth: root.buttonHeight
                    Layout.preferredHeight: root.buttonHeight
                    Layout.alignment: Qt.AlignHCenter

                    active: root.redshiftEnabled
                    normalColor: Theme.glassSelect
                    hoverColor: Theme.glassSelect
                    activeColor: Theme.redshiftColor
                    normalBorderColor: Theme.glassBorder
                    hoverBorderColor: Theme.redshiftColor
                    activeBorderColor: Theme.redshiftColor

                    onClicked: Power.redshiftEnabled = !Power.redshiftEnabled

                    Text {
                        anchors.centerIn: parent
                        text: "󰖔"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.iconS
                        color: root.redshiftEnabled
                            ? Theme.onAccentColor
                            : (redshiftBtn.hovered ? Theme.redshiftColor : Theme.foregroundColor)
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }
    }
}