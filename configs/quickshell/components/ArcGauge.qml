import QtQuick

// Полукольцо/кольцо-индикатор: трек + сегментированная заливка.
// Ничего не знает о теме и о том, что именно измеряет — только геометрия и цвет.
Item {
    id: root

    // ── Геометрия ────────────────────────────────────────────────────────
    property real thickness: 8
    property real gapDegrees: 0                          // 0 = замкнутое кольцо
    property real radius: width / 2 - thickness / 2       // можно переопределить для вложенных колец
    property int  segments: 1                              // >1 — для сглаженного градиента

    // ── Значение и цвет ──────────────────────────────────────────────────
    property real value: 0                                 // 0..1
    property color trackColor: Qt.rgba(1, 1, 1, 0.08)
    property color fillColor: "white"                      // используется, если colorAt не задан
    property var colorAt: null                             // function(t) -> color, t ∈ [0,1] вдоль дуги заливки

    readonly property real startAngle: (90 + gapDegrees / 2) * Math.PI / 180
    readonly property real sweepDegrees: 360 - gapDegrees
    readonly property real sweepRad: sweepDegrees * Math.PI / 180

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
            ctx.arc(width / 2, height / 2, root.radius, root.startAngle, root.startAngle + root.sweepRad)
            ctx.stroke()
        }
    }

    Canvas {
        id: fillCanvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const fillSweep = root.sweepRad * Math.max(0, Math.min(1, root.value))
            if (fillSweep <= 0) return

            if (root.segments <= 1 || !root.colorAt) {
                ctx.strokeStyle = root.colorAt ? root.colorAt(1) : root.fillColor
                ctx.lineWidth = root.thickness
                ctx.lineCap = "round"
                ctx.beginPath()
                ctx.arc(width / 2, height / 2, root.radius, root.startAngle, root.startAngle + fillSweep)
                ctx.stroke()
                return
            }

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
                ctx.arc(width / 2, height / 2, root.radius, a0, a1)
                ctx.stroke()
            }
        }
    }

    function repaint() {
        trackCanvas.requestPaint()
        fillCanvas.requestPaint()
    }

    onWidthChanged: repaint()
    onHeightChanged: repaint()
    onThicknessChanged: repaint()
    onGapDegreesChanged: repaint()
    onRadiusChanged: repaint()
    onTrackColorChanged: trackCanvas.requestPaint()
    onValueChanged: fillCanvas.requestPaint()
    onFillColorChanged: fillCanvas.requestPaint()
    onColorAtChanged: fillCanvas.requestPaint()
    onSegmentsChanged: fillCanvas.requestPaint()
    Component.onCompleted: repaint()
}