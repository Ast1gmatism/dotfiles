import QtQuick
import qs.theme
import qs.singletons

Item {
    id: root

    property real size: 145
    property real thickness: 10
    property real gapDegrees: 60
    property int segments: 48

    implicitWidth: size
    implicitHeight: size

    readonly property real arcRadius: width / 2 - thickness / 2
    readonly property real sweepDegrees: 360 - gapDegrees
    readonly property real startAngle: (90 + gapDegrees / 2) * Math.PI / 180
    readonly property real sweepRad: sweepDegrees * Math.PI / 180

    function lerpColor(c1, c2, t) {
        return Qt.rgba(
            c1.r + (c2.r - c1.r) * t,
            c1.g + (c2.g - c1.g) * t,
            c1.b + (c2.b - c1.b) * t,
            c1.a + (c2.a - c1.a) * t
        )
    }

    function ringColorAt(t) {
        return t < 0.5
            ? lerpColor(Theme.batteryGradientStart, Theme.batteryGradientMid, t / 0.5)
            : lerpColor(Theme.batteryGradientMid, Theme.batteryGradientStart, (t - 0.5) / 0.5)
    }

    Canvas {
        id: trackCanvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.lineWidth = root.thickness
            ctx.lineCap = "round"
            ctx.strokeStyle = Qt.rgba(205/255, 214/255, 244/255, 0.1)
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, root.arcRadius, root.startAngle, root.startAngle + root.sweepRad)
            ctx.stroke()
        }
    }

    Canvas {
        id: fillCanvas
        anchors.fill: parent

        Connections {
            target: Power
            function onBatteryLevelChanged() { fillCanvas.requestPaint() }
        }

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const fillRatio = Math.max(0, Math.min(1, Power.batteryLevel / 100))
            const totalSegs = root.segments
            const filledSegs = Math.ceil(totalSegs * fillRatio)

            if (filledSegs <= 0) return

            const segAngle = root.sweepRad / totalSegs
            const overlap = segAngle * 0.15

            for (let i = 0; i < filledSegs; i++) {
                const t0 = i / totalSegs
                const t1 = (i + 1) / totalSegs
                const a0 = root.startAngle + segAngle * i - (i > 0 ? overlap : 0)
                const a1 = root.startAngle + segAngle * (i + 1) + (i < filledSegs - 1 ? overlap : 0)

                ctx.strokeStyle = root.ringColorAt((t0 + t1) / 2)
                ctx.lineWidth = root.thickness
                ctx.lineCap = (i === 0 || i === filledSegs - 1) ? "round" : "butt"
                ctx.beginPath()
                ctx.arc(width / 2, height / 2, root.arcRadius, a0, a1)
                ctx.stroke()
            }
        }
    }

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
        color: Power.isCharging ? Theme.successColor : Theme.mutedTextColor
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        text: Power.timeStr
        font.family: Theme.fontFamily
        font.pixelSize: 14
        color: Theme.mutedTextColor
    }

    Component.onCompleted: {
        trackCanvas.requestPaint()
        fillCanvas.requestPaint()
    }
}