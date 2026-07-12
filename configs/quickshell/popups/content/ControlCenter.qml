import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.theme
import qs.components
import qs.singletons

Item {
    id: root

    implicitWidth: mainRow.width + 2 * root.outerMargin
    implicitHeight: mainRow.height + 2 * root.outerMargin

    // ── Данные ───────────────────────────────────────────────────────────────
    property string currentView: "default"

    // ── Константы ────────────────────────────────────────────────────────────
    readonly property real ringGapDegrees: 70

    // ── Отступы ──────────────────────────────────────────────────────────────
    readonly property real outerMargin: 12
    readonly property real itemSpacing: 8
    readonly property real sectionPadding: 12 
    readonly property real sectionRadius: 12

    // === Панель управления ===================================================
    Component {
        id: defaultViewComponent
        ColumnLayout {
            id: leftColumn
            spacing: root.itemSpacing

            // ── Шапка ────────────────────────────────────────────────────────
            GlassSection {
                Layout.fillWidth: true
                padding: root.sectionPadding
                RowLayout {
                    anchors.fill: parent
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: width / 2
                        color: Theme.accentColor // TODO: заменить на градиент из мокапа при желании

                        Text {
                            anchors.centerIn: parent
                            text: "E" // TODO: первая буква имени пользователя
                            font.family: Theme.fontFamily
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: Theme.backgroundColor // TODO: проверить контраст с accentColor
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Привет, euph0ria" // TODO: получать имя пользователя из системы
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: Theme.foregroundColor
                        }
                        Text {
                            text: "arch linux · hyprland" // TODO: подтягивать из системы при желании или заменить на кастомную надпись
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.mutedTextColor
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.alignment: Qt.AlignRight

                        Text {
                            text: "аптайм"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.mutedTextColor
                            Layout.alignment: Qt.AlignRight
                        }
                        Text {
                            text: "2д 14ч" // TODO: подключить реальный singleton с аптаймом
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: Theme.foregroundColor
                            Layout.alignment: Qt.AlignRight
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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        radius: 10
                        color: launcherArea.containsMouse
                            ? Theme.subtleFillColor
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: 120 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "󰅍"
                                font.pixelSize: 18
                                font.family: Theme.fontFamily
                                color: Theme.foregroundColor
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Clipboard"
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.mutedTextColor
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: launcherArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                viewStack.push(clipboardViewComponent)
                            }
                        }
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

                    StatGauge {
                        gapDegrees: root.ringGapDegrees
                        value: 0.70; valueColor: Theme.blueColor
                        hasSecondary: true; secondaryValue: 0.58; secondaryColor: Theme.warningColor
                        centerText: "70%"; centerSubText: "58°C"; name: "CPU"
                    }
                    StatGauge {
                        gapDegrees: root.ringGapDegrees
                        value: 0.30; valueColor: Theme.mauveColor
                        hasSecondary: true; secondaryValue: 0.65; secondaryColor: Theme.warningColor
                        centerText: "30%"; centerSubText: "65°C"; name: "GPU"
                    }
                    StatGauge {
                        gapDegrees: root.ringGapDegrees
                        value: 0.60; valueColor: Theme.successColor
                        centerText: "60%"; centerSubText: "9.6G"; name: "RAM"
                    }
                    StatGauge {
                        gapDegrees: root.ringGapDegrees
                        value: 0.30; valueColor: Theme.tealColor
                        centerText: "30%"; centerSubText: "142G"; name: "Disk"
                    }
                }
            }

            // ── Управление питанием ──────────────────────────────────────────
            GlassSection {
                Layout.fillWidth: true
                padding: root.sectionPadding
                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 10
                        color: lockArea.containsMouse ? Theme.subtleFillColor : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "󰍁"
                                font.family: Theme.fontFamily
                                font.pixelSize: 15
                                color: Theme.foregroundColor
                            }
                            Text {
                                text: "Lock"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: Theme.foregroundColor
                            }
                        }

                        MouseArea {
                            id: lockArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: console.log("TODO: hyprctl / loginctl lock-session")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 10
                        color: powerArea.containsMouse ? Theme.subtleFillColor : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "⏻"
                                font.family: Theme.fontFamily
                                font.pixelSize: 15
                                color: Theme.foregroundColor
                            }
                            Text {
                                text: "Power"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: Theme.foregroundColor
                            }
                        }

                        MouseArea {
                            id: powerArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                viewStack.push(powerViewComponent)
                            }
                        }
                    }
                }
            }
        }
    }
    
    Component {
        id: clipboardViewComponent
        GlassSection {
            Button {
                onClicked: viewStack.pop()
            }
        }
    }

    Component {
        id: powerViewComponent
        GlassSection {
            Button {
                onClicked: viewStack.pop()
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    RowLayout {
        id: mainRow
        anchors.centerIn: parent
        spacing: root.itemSpacing

        // === Левая секция ====================================================
        StackView {
            id: viewStack
            implicitWidth: currentItem ? currentItem.implicitWidth : 0
            implicitHeight: currentItem ? currentItem.implicitHeight : 0
            initialItem: defaultViewComponent
        }
        
        // === Секция уведомлений ==============================================
        GlassSection {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            padding: root.sectionPadding

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // ── DND row ──────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24

                    RowLayout {
                        spacing: 8
                        Text {
                            text: "󰂛"
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                            color: Theme.foregroundColor
                        }
                        Text {
                            text: "Не беспокоить"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: Theme.foregroundColor
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // TODO: заменить на нормальный toggle-компонент (см. profileSwitch pill в PowerPopup)
                    Rectangle {
                        id: dndToggle
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 19
                        radius: height / 2
                        property bool on: false
                        color: on ? Theme.accentColor : Theme.subtleFillColor
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            width: 15; height: 15
                            radius: width / 2
                            color: Theme.foregroundColor
                            anchors.verticalCenter: parent.verticalCenter
                            x: dndToggle.on ? parent.width - width - 2 : 2
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dndToggle.on = !dndToggle.on
                                console.log("TODO: связать с реальным DND-состоянием")
                            }
                        }
                    }
                }

                // ── Heading row ──────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 16

                    Text {
                        text: "Уведомления"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: Theme.mutedTextColor
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Очистить"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: clearArea.containsMouse ? Theme.foregroundColor : Theme.mutedTextColor

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: console.log("TODO: очистить уведомления")
                        }
                    }
                }

                // ── Список уведомлений ───────────────────────────────────────
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: root.notifications

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 40
                        radius: 8
                        color: notifArea.containsMouse ? Theme.subtleFillColor : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 1

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.app
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: Theme.foregroundColor
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: modelData.time
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 9
                                    color: Theme.mutedTextColor
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

                        MouseArea {
                            id: notifArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            // TODO: dismiss по клику / свайпу
                        }
                    }       // TODO: показывать заглушку "Нет уведомлений", если model пуст
                }
            }
        }
    }
}