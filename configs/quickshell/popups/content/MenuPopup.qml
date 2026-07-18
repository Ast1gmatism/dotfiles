import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.theme
import qs.components

Item {
    id: root

    implicitWidth: mainRow.width + 2 * root.outerMargin
    implicitHeight: mainRow.height + 2 * root.outerMargin

    // ── Данные ───────────────────────────────────────────────────────────────

    property var systemStats: [
        { name: "CPU",  value: 0.70, centerText: "70%", centerSubText: "58°C",  hasSecondary: true,  secondaryValue: 0.58 },
        { name: "GPU",  value: 0.30, centerText: "30%", centerSubText: "65°C",  hasSecondary: true,  secondaryValue: 0.65 },
        { name: "RAM",  value: 0.60, centerText: "60%", centerSubText: "9.6G",  hasSecondary: false, secondaryValue: 0 },
        { name: "Disk", value: 0.30, centerText: "30%", centerSubText: "142G",  hasSecondary: false, secondaryValue: 0 }
    ]

    property var notifications: [
        { app: "Telegram", text: "Новое сообщение от Ани", time: "2м" },
        { app: "Pacman",   text: "Доступно 12 пакетов",    time: "1ч" },
        { app: "Загрузки", text: "dotfiles-backup.tar.gz", time: "3ч" }
    ]

    function activateNotification(notification) {
        console.log("TODO: mako default action for:", notification.app)
    }

    function closeNotification(notification) {
        console.log("TODO: mako dismiss (no action) for:", notification.app)
    }

    property var quickLaunchActions: [
        { id: "capture",   icon: "\uee2e", label: "Захват" },
        { id: "files",     icon: "\uf07c",  label: "Файлы" },
        { id: "settings",  icon: "\uf085", label: "Настройки" },
        { id: "clipboard", icon: "\ued7b", label: "Буфер" }
    ]

    readonly property var quickLaunchHandlers: ({
        capture:   () => console.log("Overview: Capture pressed"),
        files:     () => console.log("Overview: Files pressed"),
        settings:  () => console.log("Overview: Settings pressed"),
        clipboard: () => console.log("Overview: Clipboard pressed")
    })

    function executeQuickLaunch(actionId) {
        const handler = root.quickLaunchHandlers[actionId]
        if (handler) handler()
        else console.warn("Unknown quick launch action:", actionId)
    }

    property var powerActions: [
        { id: "lock",      label: "Блокировка",       icon: "\uf023", dangerous: false, weight: 0.8 },
        { id: "suspend",   label: "Сон",              icon: "\uf28c", dangerous: false, weight: 1.0 },
        { id: "hibernate", label: "Гибернация",       icon: "\uf110", dangerous: false, weight: 1.1 },
        { id: "logout",    label: "Выход из сессии",  icon: "\uf2f5", dangerous: false, weight: 1.3 },
        { id: "reboot",    label: "Перезагрузка",     icon: "\uf2ea", dangerous: true,  weight: 1.5 },
        { id: "poweroff",  label: "Выключение",       icon: "\uf011", dangerous: true,  weight: 1.7 }
    ]

    readonly property var primaryPowerAction: root.powerActions[0]
    readonly property var secondaryPowerActions: root.powerActions.slice(1)

    readonly property var powerHandlers: ({
        lock:      () => console.log("TODO: loginctl lock-session"),
        suspend:   () => console.log("TODO: systemctl suspend"),
        hibernate: () => console.log("TODO: systemctl hibernate"),
        logout:    () => console.log("TODO: loginctl terminate-session"),
        reboot:    () => console.log("TODO: systemctl reboot"),
        poweroff:  () => console.log("TODO: systemctl poweroff")
    })

    function executePowerAction(actionId) {
        const handler = root.powerHandlers[actionId]
        if (handler) handler()
        else console.warn("Unknown power action:", actionId)
    }

    property bool sessionMenuOpen: false

    property bool dndActive: false

    function toggleDnd() {
        root.dndActive = !root.dndActive
        console.log("DND toggled:", root.dndActive)
    }

    Component.onCompleted: {
        for (const a of root.quickLaunchActions)
            if (!root.quickLaunchHandlers[a.id])
                console.warn("No handler for quick launch id:", a.id)
        for (const a of root.powerActions)
            if (!root.powerHandlers[a.id])
                console.warn("No handler for power action id:", a.id)
    }

    // ── Константы ────────────────────────────────────────────────────────────
    readonly property real outerMargin: 12
    readonly property real itemSpacing: 8
    readonly property real sectionPadding: 12

    readonly property real tileVerticalPadding: 9
    readonly property real listItemPadding: 6

    // ─────────────────────────────────────────────────────────────────────────
    RowLayout {
        id: mainRow
        anchors.top: parent.top
        anchors.topMargin: root.outerMargin
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.itemSpacing

        // === Панель управления ===============================================
        ColumnLayout {
            spacing: root.itemSpacing

            // ── Шапка ────────────────────────────────────────────────────────
            GlassSection {
                Layout.fillWidth: true
                padding: root.sectionPadding

                RowLayout {
                    anchors.fill: parent
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: width / 2
                        color: Theme.accentColor
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "E"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: Theme.onAccentColor
                        }
                    }

                    Text {
                        text: "euph0ria"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.foregroundColor
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "up 2д 14ч"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: Theme.mutedTextColor
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }

            // ── Кольца-мониторы ──────────────────────────────────────────────
            GlassSection {
                Layout.fillWidth: true
                padding: root.sectionPadding
                GridLayout {
                    anchors.fill: parent
                    columns: 4
                    columnSpacing: 8

                    Repeater {
                        model: root.systemStats

                        delegate: StatGauge {
                            required property var modelData
                            value: modelData.value
                            hasSecondary: modelData.hasSecondary
                            secondaryValue: modelData.secondaryValue
                            centerText: modelData.centerText
                            centerSubText: modelData.centerSubText
                            name: modelData.name
                        }
                    }
                }
            }

            // ── Быстрый запуск ───────────────────────────────────────────────
            GlassSection {
                Layout.fillWidth: true
                padding: root.sectionPadding

                GridLayout {
                    anchors.fill: parent
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: root.quickLaunchActions

                        delegate: HoverSurface {
                            required property var modelData
                            Layout.fillWidth: true

                            implicitHeight: contentColumn.implicitHeight + root.tileVerticalPadding * 2

                            normalColor: "transparent"
                            hoverColor: Theme.subtleFillColor

                            onClicked: root.executeQuickLaunch(modelData.id)

                            ColumnLayout {
                                id: contentColumn
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 18
                                    font.family: Theme.fontFamily
                                    color: Theme.foregroundColor
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: modelData.label
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 9
                                    color: Theme.mutedTextColor
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            // ── Управление сессией ────────────────────────────────────────────
            GlassSection {
                Layout.fillWidth: true
                padding: root.sectionPadding

                ColumnLayout {
                    id: sessionColumn
                    anchors.fill: parent
                    spacing: 0

                    readonly property real groupSpacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        PowerTile {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalPadding: root.tileVerticalPadding
                            label: root.primaryPowerAction.label
                            icon: root.primaryPowerAction.icon
                            dangerous: root.primaryPowerAction.dangerous
                            weight: root.primaryPowerAction.weight
                            onConfirmed: root.executePowerAction(root.primaryPowerAction.id)
                        }

                        HoverSurface {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            implicitHeight: toggleRow.implicitHeight + root.tileVerticalPadding * 2

                            active: root.sessionMenuOpen
                            normalColor: "transparent"
                            hoverColor: Theme.hoverFillColor
                            activeColor: Qt.rgba(Theme.foregroundColor.r, Theme.foregroundColor.g, Theme.foregroundColor.b, 0.07)
                            activeBorderColor: Qt.rgba(Theme.foregroundColor.r, Theme.foregroundColor.g, Theme.foregroundColor.b, 0.12)

                            onClicked: root.sessionMenuOpen = !root.sessionMenuOpen

                            RowLayout {
                                id: toggleRow
                                anchors.centerIn: parent
                                spacing: 7

                                Text {
                                    text: "\uf105"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    color: Theme.mutedTextColor
                                    rotation: root.sessionMenuOpen ? 90 : 0
                                    Behavior on rotation {
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }
                                }
                                Text {
                                    text: "Питание"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    color: Theme.foregroundColor
                                }
                            }
                        }
                    }

                    Item {
                        id: accordionWrapper
                        Layout.fillWidth: true
                        Layout.topMargin: root.sessionMenuOpen ? sessionColumn.groupSpacing : 0
                        implicitHeight: root.sessionMenuOpen ? powerList.implicitHeight : 0
                        clip: true

                        Behavior on implicitHeight {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }
                        Behavior on Layout.topMargin {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }

                        ColumnLayout {
                            id: powerList
                            width: parent.width
                            spacing: sessionColumn.groupSpacing

                            Repeater {
                                model: root.secondaryPowerActions

                                delegate: PowerTile {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    verticalPadding: root.tileVerticalPadding
                                    label: modelData.label
                                    icon: modelData.icon
                                    dangerous: modelData.dangerous
                                    weight: modelData.weight
                                    onConfirmed: root.executePowerAction(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }

        // === Секция уведомлений ==============================================
        GlassSection {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            padding: root.sectionPadding

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                // ── 1. ПРОМИНЕНТНЫЙ БАННЕР DND ───────────────────────────────
                HoverSurface {
                    id: dndBanner
                    Layout.fillWidth: true

                    implicitHeight: dndRow.implicitHeight + root.tileVerticalPadding * 2

                    active: root.dndActive
                    normalColor: Theme.glassSelect
                    hoverColor: Theme.glassSelect
                    activeColor: Theme.accentColor
                    normalBorderColor: Theme.glassBorder
                    hoverBorderColor: Theme.accentColor
                    activeBorderColor: Theme.accentColor

                    onClicked: root.toggleDnd()

                    RowLayout {
                        id: dndRow
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: root.dndActive ? "󰂛" : "󰂪"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.iconL
                            color: root.dndActive
                                ? Theme.onAccentColor
                                : (dndBanner.hovered ? Theme.accentColor : Theme.foregroundColor)
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            text: "Не беспокоить"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textTitle
                            font.weight: root.dndActive ? Font.Bold : Font.DemiBold
                            color: root.dndActive
                                ? Theme.onAccentColor
                                : (dndBanner.hovered ? Theme.accentColor : Theme.foregroundColor)
                            Layout.fillWidth: true
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            text: root.dndActive ? "ВКЛ" : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.textBody
                            font.weight: Font.Bold
                            color: Theme.onAccentColor
                            visible: root.dndActive
                        }
                    }
                }

                // ── 2. ЗАГОЛОВОК СПИСКА + ОЧИСТИТЬ ───────────────────────────
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Уведомления"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: Theme.mutedTextColor
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Очистить"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: clearArea.containsMouse ? Theme.errorColor : Theme.mutedTextColor
                        Behavior on color { ColorAnimation { duration: 120 } }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: console.log("TODO: очистить уведомления")
                        }
                    }
                }

                // ── Список уведомлений ───────────────────────────────────
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: root.notifications

                    delegate: HoverSurface {
                        id: notifTile
                        required property var modelData
                        width: ListView.view.width

                        implicitHeight: notifColumn.implicitHeight + root.listItemPadding * 2

                        normalColor: "transparent"
                        hoverColor: Theme.subtleFillColor

                        onClicked: root.activateNotification(modelData)

                        ColumnLayout {
                            id: notifColumn
                            anchors.fill: parent
                            anchors.margins: root.listItemPadding
                            spacing: 1

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: modelData.app
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: Theme.foregroundColor
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Item {
                                    id: metaSlot
                                    readonly property real closeButtonSize: 14

                                    implicitWidth: Math.max(timeLabel.implicitWidth, closeButtonSize)
                                    implicitHeight: closeButtonSize
                                    Layout.alignment: Qt.AlignVCenter

                                    Text {
                                        id: timeLabel
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.time
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 9
                                        color: Theme.mutedTextColor
                                        opacity: notifTile.hovered ? 0 : 1
                                        Behavior on opacity { NumberAnimation { duration: 120 } }
                                    }

                                    HoverSurface {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: metaSlot.closeButtonSize
                                        height: metaSlot.closeButtonSize
                                        radius: 4
                                        normalColor: "transparent"
                                        hoverColor: Theme.errorColor
                                        opacity: notifTile.hovered ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: 120 } }

                                        onClicked: root.closeNotification(modelData)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\u2715"
                                            font.pixelSize: 8
                                            color: parent.hovered ? Theme.onAccentColor : Theme.mutedTextColor
                                        }
                                    }
                                }
                            }
                            
                            Text {
                                text: modelData.text
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.mutedTextColor
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}