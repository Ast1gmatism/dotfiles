import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.components

HoverSurface {
    id: tile

    property string label: ""
    property string icon: ""
    property bool dangerous: false
    property real weight: 1.0

    signal confirmed

    interactive: false
    hovered: tileArea.containsMouse
    clip: true

    readonly property color activeColor: dangerous ? Theme.errorColor : Theme.accentColor

    hoverColor: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.08)
    hoverBorderColor: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.25)

    readonly property real baseDuration: 420
    property real holdT: 0

    function logProgress(t) {
        return Math.log(1 + 9 * t) / Math.LN10
    }

    NumberAnimation {
        id: fillAnim
        target: tile
        property: "holdT"
        from: 0
        to: 1
        duration: Math.round(tile.baseDuration * tile.weight)
        easing.type: Easing.Linear

        onFinished: {
            tile.confirmed()
            flashRect.opacity = 0.4
            flashAnim.start()
            resetTimer.start()
        }
    }

    Timer {
        id: resetTimer
        interval: 350
        onTriggered: tile.holdT = 0
    }

    // ── Заливка + волна, клипованная по скруглённой форме tile ──
    Canvas {
        id: fillCanvas
        anchors.fill: parent
        property real phase: 0

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var p = tile.logProgress(tile.holdT)
            if (p <= 0.001) return

            ctx.save()

            var r = tile.radius
            ctx.beginPath()
            ctx.moveTo(r, 0)
            ctx.lineTo(width - r, 0)
            ctx.arcTo(width, 0, width, r, r)
            ctx.lineTo(width, height - r)
            ctx.arcTo(width, height, width - r, height, r)
            ctx.lineTo(r, height)
            ctx.arcTo(0, height, 0, height - r, r)
            ctx.lineTo(0, r)
            ctx.arcTo(0, 0, r, 0, r)
            ctx.closePath()
            ctx.clip()

            var edgeX = p * width
            var amp = 2.5 * Math.sin(p * Math.PI)

            ctx.beginPath()
            ctx.moveTo(0, 0)
            for (var y = 0; y <= height; y += 4) {
                var wob = Math.sin((y / height) * Math.PI * 3 + phase) * amp
                ctx.lineTo(edgeX + wob, y)
            }
            ctx.lineTo(0, height)
            ctx.closePath()

            var c = tile.activeColor
            var rgba = "rgba(" + Math.round(c.r * 255) + "," +
                                  Math.round(c.g * 255) + "," +
                                  Math.round(c.b * 255) + ",0.26)"
            ctx.fillStyle = rgba
            ctx.fill()

            ctx.restore()
        }

        NumberAnimation on phase {
            running: fillAnim.running
            loops: Animation.Infinite
            from: 0; to: Math.PI * 2
            duration: 500
        }
        onPhaseChanged: requestPaint()
    }

    onHoldTChanged: fillCanvas.requestPaint()

    Rectangle {
        id: flashRect
        anchors.fill: parent
        color: "#ffffff"
        opacity: 0
        radius: tile.radius
    }

    NumberAnimation {
        id: flashAnim
        target: flashRect
        property: "opacity"
        to: 0
        duration: 450
        easing.type: Easing.OutExpo
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        Item {
            Layout.preferredWidth: 20
            Layout.fillHeight: true
            Text {
                anchors.centerIn: parent
                text: tile.icon
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: tile.dangerous
                    ? (tile.hovered ? tile.activeColor : Qt.rgba(tile.activeColor.r, tile.activeColor.g, tile.activeColor.b, 0.7))
                    : (tile.hovered ? tile.activeColor : Theme.mutedTextColor)
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }

        Text {
            text: tile.label
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: Theme.foregroundColor
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: tileArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            tile.holdT = 0
            fillAnim.start()
        }

        onReleased: {
            if (fillAnim.running) {
                fillAnim.stop()
                tile.holdT = 0
            }
        }

        onCanceled: {
            if (fillAnim.running) {
                fillAnim.stop()
                tile.holdT = 0
            }
        }
    }
}