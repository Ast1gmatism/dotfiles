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
            color: Theme.sectionColor

            ColumnLayout {
                id: leftGroup
                anchors.centerIn: parent
                spacing: root.columnSpacing

                BatteryRing {
                    id: chargeRing
                    Layout.preferredWidth: root.gaugeSize
                    Layout.preferredHeight: root.gaugeSize
                    Layout.alignment: Qt.AlignHCenter

                    value: Power.batteryLevel
                    gradientStart: Theme.batteryGradientStart
                    gradientMid:   Theme.batteryGradientMid
                    gradientEnd:   Theme.batteryGradientStart

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
                            : Qt.alpha(Theme.foregroundColor, 0.6)
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                        text: Power.timeStr
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: Qt.alpha(Theme.foregroundColor, 0.5)
                    }
                }

                // ── Кнопки профилей ──────────────────────────────────────────
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
            color: Theme.sectionColor

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
                        color: Qt.alpha(Theme.foregroundColor, 0.05)
                        border.color: Theme.borderColor
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

                // ── Кнопка RedShift ──────────────────────────────────────────
                Rectangle {
                    id: redshiftBtn

                    Layout.preferredWidth: root.buttonHeight
                    Layout.preferredHeight: root.buttonHeight
                    Layout.alignment: Qt.AlignHCenter
                    radius: 8

                    color: {
                        if (root.redshiftEnabled)
                            return Qt.alpha(Theme.redshiftColor, 0.25)
                        if (rsMouseArea.containsMouse)
                            return Qt.alpha(Theme.foregroundColor, 0.10)
                        return Qt.alpha(Theme.foregroundColor, 0.05)
                    }

                    border.color: root.redshiftEnabled ? Theme.redshiftColor : "transparent"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

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