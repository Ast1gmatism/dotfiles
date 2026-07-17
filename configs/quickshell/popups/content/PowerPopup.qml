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
                    radius: 10
                    border.width: 1
                    border.color: Theme.glassBorder

                    color: Theme.glassSelect

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
                Rectangle {
                    id: redshiftBtn
                    Layout.preferredWidth: root.buttonHeight
                    Layout.preferredHeight: root.buttonHeight
                    Layout.alignment: Qt.AlignHCenter
                    radius: 8

                    color: Theme.glassSelect

                    border.color: root.redshiftEnabled ? Theme.redshiftColor : Theme.glassBorder
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