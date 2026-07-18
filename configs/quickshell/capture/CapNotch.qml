import QtQuick
import QtQuick.Shapes
import qs.theme
import qs.components

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

    y: collapsed ? -height - Theme.spacingM : 0
    Behavior on y {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    // ── Фигура чёлки ──────────────────────────────────────────────────────────
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.glassGroup
            strokeColor: Theme.glassBorder
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

    // ── Кнопка-иконка ──────────────────────────────────────────────────────
    component IconButton: HoverSurface {
        id: btn
        property string icon: ""
        property bool show: true

        width: show ? Theme.iconXL * 2 : 0
        implicitHeight: 32
        radius: Theme.radiusM

        normalColor: "transparent"
        hoverColor: Theme.hoverFillColor

        opacity: show ? 1.0 : 0.0
        clip: true

        Behavior on width {
            NumberAnimation { duration: 250; easing.type: Easing.OutExpo }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconXL
            color: Theme.foregroundColor
            scale: btn.show ? 1.0 : 0.8

            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.OutExpo }
            }
        }
    }

    // ── Контент ──────────────────────────────────────────────────────────────
    Row {
        id: content
        spacing: Theme.spacingS
        anchors.centerIn: parent

        IconButton {
            icon: "\uf030"
            onClicked: notch.captureFullscreenRequested()
        }

        PillSwitch {
            width: 140
            options: [
                { value: "clipboard", label: "\uf0c5" },
                { value: "file",      label: "\uf0c7" },
                { value: "both",      label: "\uf0c5/\uf0c7" }
            ]
            current: notch.destination
            onChanged: (v) => notch.destination = v
        }

        IconButton {
            show: notch.destination === "file" || notch.destination === "both"
            icon: "\uf07b"
            // TODO: открыть выбор директории через FileDialog / kdialog, когда решим backend
        }

        PillSwitch {
            width: 100
            options: [
                { value: "photo", label: "\uf03e" },
                { value: "video", label: "\uf03d" }
            ]
            current: notch.media
            onChanged: (v) => notch.media = v
            // TODO: режим видеозаписи
        }

        IconButton {
            icon: "\uf00d"
            onClicked: notch.closeRequested()
        }
    }
}