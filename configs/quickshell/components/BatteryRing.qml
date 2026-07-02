import QtQuick
import qs.theme

Item {
    id: root

    property real value: 0
    property color gradientStart: "#c6a0f6"
    property color gradientMid:   "#f5c2e7"
    property color gradientEnd:   "#c6a0f6"
    property color trackColor: Qt.rgba(205/255, 214/255, 244/255, 0.1)

    property real thickness: 10
    property real gapDegrees: 60
    property int segments: 48

    readonly property real arcRadius: width / 2 - thickness / 2
    readonly property real sweepDegrees: 360 - gapDegrees
    readonly property real startAngle: (90 + gapDegrees / 2) * Math.PI / 180
    readonly property real sweepRad: sweepDegrees * Math.PI / 180

    function lerp(c1, c2, t) {
        return Qt.rgba(
            c1.r + (c2.r - c1.r) * t,
            c1.g + (c2.g - c1.g) * t,
            c1.b + (c2.b - c1.b) * t,
            c1.a + (c2.a - c1.a) * t
        )
    }

    function colorAt(t) {
        // t — позиция вдоль ЗАПОЛНЕННОЙ части дуги, 0..1
        return t < 0.5
            ? lerp(root.gradientStart, root.gradientMid, t / 0.5)
            : lerp(root.gradientMid, root.gradientEnd, (t - 0.5) / 0.5)
    }

    Canvas {
        id: trackCanvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.lineWidth = root.thickness
            ctx.lineCap = "round"
            ctx.strokeStyle = root.trackColor
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, root.arcRadius,
                    root.startAngle, root.startAngle + root.sweepRad)
            ctx.stroke()
        }
    }

    Canvas {
        id: fillCanvas
        anchors.fill: parent

        Connections {
            target: root
            function onValueChanged() { fillCanvas.requestPaint() }
        }

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const fillSweep = root.sweepRad * (root.value / 100)
            if (fillSweep <= 0) return

            const segAngle = fillSweep / root.segments
            const overlap = segAngle * 0.15

            for (let i = 0; i < root.segments; i++) {
                const t0 = i / root.segments
                const t1 = (i + 1) / root.segments
                const a0 = root.startAngle + segAngle * i - (i > 0 ? overlap : 0)
                const a1 = root.startAngle + segAngle * (i + 1) + (i < root.segments - 1 ? overlap : 0)

                ctx.strokeStyle = root.colorAt((t0 + t1) / 2)
                ctx.lineWidth = root.thickness
                ctx.lineCap = (i === 0 || i === root.segments - 1) ? "round" : "butt"
                ctx.beginPath()
                ctx.arc(width / 2, height / 2, root.arcRadius, a0, a1)
                ctx.stroke()
            }
        }
    }
}