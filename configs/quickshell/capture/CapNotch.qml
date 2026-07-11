import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import qs.theme

Item {
    id: notch

    property string mode: "area"
    property string destination: "both"
    property string media: "photo"

    signal closeRequested()
    signal captureFullscreenRequested()

    readonly property int pad: Theme.containerPadding
    // r — половина полной высоты нотча (глубина S-образного скругления)
    readonly property int r: (content.height + pad * 2) / 2
    // H — ширина плоского нижнего края (там, где сидит контент)
    readonly property real bodyWidth: content.width + pad * 2

    width: bodyWidth + r * 2
    height: r * 2

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.glassContainer
            strokeColor: Theme.glassContainerBorder
            strokeWidth: 1

            startX: 0
            startY: 0

            // левый флаг: плоский верх -> плоский (укороченный) низ
            PathQuad {
                relativeX: notch.r; relativeY: notch.r
                relativeControlX: notch.r; relativeControlY: 0
            }
            PathQuad {
                relativeX: notch.r; relativeY: notch.r
                relativeControlX: 0; relativeControlY: notch.r
            }

            // плоский низ
            PathLine {
                relativeX: notch.bodyWidth - 2 * notch.r
                relativeY: 0
            }

            // правый флаг: зеркально
            PathQuad {
                relativeX: notch.r; relativeY: -notch.r
                relativeControlX: notch.r; relativeControlY: 0
            }
            PathQuad {
                relativeX: notch.r; relativeY: -notch.r
                relativeControlX: 0; relativeControlY: -notch.r
            }
            // верхняя грань (сплошная, во всю ширину) замыкается автоматически
        }
    }

    component PillSwitch: Item {
        id: pill
        property var options: []
        property string current: options.length > 0 ? options[0].value : ""
        signal changed(string value)

        readonly property int index: {
            for (let i = 0; i < options.length; i++)
                if (options[i].value === current) return i
            return 0
        }
        readonly property real segW: width / Math.max(options.length, 1)

        height: Theme.containerPadding * 3

        Rectangle {
            anchors.fill: parent
            radius: pill.height / 2
            color: Theme.glassGroupStart
            border.color: Theme.glassGroupBorder
            border.width: 1
        }

        Rectangle {
            y: 2
            height: pill.height - 4
            width: pill.segW - 4
            x: pill.index * pill.segW + 2
            radius: height / 2
            color: Theme.activeFillColor
            border.color: Theme.accentColor
            border.width: 1

            Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutQuart } }
        }

        Row {
            anchors.fill: parent
            Repeater {
                model: pill.options
                delegate: Item {
                    width: pill.segW
                    height: pill.height
                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: pill.current === modelData.value ? Theme.foregroundColor : Theme.mutedTextColor
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pill.changed(modelData.value)
                    }
                }
            }
        }
    }

    Row {
        id: content
        spacing: 12
        anchors.centerIn: parent

        Button {
            text: "✕"
            onClicked: notch.closeRequested()
        }

        PillSwitch {
            width: 140
            options: [
                { value: "area", label: "Area" },
                { value: "fullscreen", label: "Full" }
            ]
            current: notch.mode
            onChanged: (v) => notch.mode = v
        }

        PillSwitch {
            width: 180
            options: [
                { value: "both", label: "Both" },
                { value: "clipboard", label: "Clip" },
                { value: "file", label: "File" }
            ]
            current: notch.destination
            onChanged: (v) => notch.destination = v
        }

        Button {
            text: notch.media === "photo" ? "Photo" : "Video"
            enabled: false
        }

        Button {
            visible: notch.mode === "fullscreen"
            text: "Capture"
            onClicked: notch.captureFullscreenRequested()
        }
    }
}