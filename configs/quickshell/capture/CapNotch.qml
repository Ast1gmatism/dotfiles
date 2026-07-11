import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: notch

    property string destination: "clipboard"
    property string media: "photo"
    property bool collapsed: false

    signal closeRequested()
    signal captureFullscreenRequested()

    readonly property int pad: Theme.containerPadding
    readonly property int r: (content.height + pad * 2) / 2
    readonly property real bodyWidth: content.width + pad * 2

    width: bodyWidth + r * 2
    height: r * 2

    y: collapsed ? -height - 20 : 0
    Behavior on y {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.glassContainer
            strokeColor: Theme.glassContainerBorder
            strokeWidth: 1

            startX: 0
            startY: 0

            PathQuad {
                relativeX: notch.r; relativeY: notch.r
                relativeControlX: notch.r; relativeControlY: 0
            }
            PathQuad {
                relativeX: notch.r; relativeY: notch.r
                relativeControlX: 0; relativeControlY: notch.r
            }

            PathLine {
                relativeX: notch.bodyWidth - 2 * notch.r
                relativeY: 0
            }

            PathQuad {
                relativeX: notch.r; relativeY: -notch.r
                relativeControlX: notch.r; relativeControlY: 0
            }
            PathQuad {
                relativeX: notch.r; relativeY: -notch.r
                relativeControlX: 0; relativeControlY: -notch.r
            }
        }
    }

    component PillSwitch: Rectangle {
        id: pill
        property var options: []
        property string current: options.length > 0 ? options[0].value : ""
        signal changed(string value)

        property bool isEnabled: true
        opacity: isEnabled ? 1.0 : 0.4

        readonly property int currentIndex: {
            for (let i = 0; i < options.length; i++)
                if (options[i].value === current) return i
            return 0
        }
        readonly property real segW: width / Math.max(options.length, 1)

        height: 32
        radius: 10
        border.width: 1
        border.color: Theme.glassContainerBorder

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassGroupEnd }
            GradientStop { position: 1.0; color: Theme.glassGroupStart }
        }

        Rectangle {
            id: activePill
            width: pill.segW
            height: pill.height
            radius: 10
            x: pill.segW * pill.currentIndex
            color: Theme.activeFillColor

            Behavior on x {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }

        Row {
            anchors.fill: parent
            Repeater {
                model: pill.options
                delegate: Item {
                    width: pill.segW
                    height: pill.height

                    required property var modelData
                    readonly property bool isActive: pill.current === modelData.value

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        color: parent.isActive
                            ? Theme.accentColor
                            : Theme.foregroundColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: pill.isEnabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pill.changed(modelData.value)
                    }
                }
            }
        }
    }

    component IconButton: Rectangle {
        id: btn
        property string icon: ""
        property bool isEnabled: true
        property bool show: true
        signal clicked()

        width: show ? 40 : 0
        height: 32
        radius: height / 2
        color: ma.containsMouse ? Theme.hoverFillColor : "transparent"
        opacity: (isEnabled ? 1.0 : 0.4) * (show ? 1.0 : 0.0)
        clip: true

        Behavior on width {
            NumberAnimation { duration: 250; easing.type: Easing.OutExpo}
        }
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: Theme.fontFamily
            font.pixelSize: 20
            color: Theme.foregroundColor
            scale: btn.show ? 1.0 : 0.8

            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.OutExpo }
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: btn.isEnabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            enabled: btn.isEnabled && btn.show
            onClicked: btn.clicked()
        }
    }

    Row {
        id: content
        spacing: 8
        anchors.centerIn: parent

        IconButton {
            icon: "\uf030"
            onClicked: notch.captureFullscreenRequested()
        }

        PillSwitch {
            width: 140
            options: [
                { value: "clipboard", label: "\uf0c5" },
                { value: "file", label: "\uf0c7" },
                { value: "both", label: "\uf0c5/\uf0c7" }
            ]
            current: notch.destination
            onChanged: (v) => notch.destination = v
        }

        IconButton {
            show: notch.destination === "file" || notch.destination === "both"
            icon: "\uf07b"
            isEnabled: false
            // TODO: открыть выбор директории через FileDialog / kdialog, когда решим backend
        }

        PillSwitch {
            width: 100
            options: [
                { value: "photo", label: "\uf03e" },
                { value: "video", label: "\uf03d" }
            ]
            current: notch.media
            isEnabled: false
            // TODO: режим видеозаписи
            onChanged: (v) => notch.media = v
        }

        IconButton {
            icon: "\uf00d"
            onClicked: notch.closeRequested()
        }
    }
}