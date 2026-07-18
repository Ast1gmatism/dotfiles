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
        { value: "saver",    label: "󰾆" },
        { value: "balanced", label: "󰾅" },
        { value: "perf",     label: "󰓅" }
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
                PillSwitch {
                    Layout.fillWidth: true
                    implicitHeight: root.buttonHeight
                    options: root.profiles
                    current: root.activeProfile
                    onChanged: (v) => Power.setProfile(v)
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