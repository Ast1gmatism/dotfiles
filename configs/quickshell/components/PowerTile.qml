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

    // HoverSurface.interactive: false исключает создание встроенного
    // MouseArea (см. HoverSurface.qml — Loader.active: interactive) —
    // весь жест удержания целиком обрабатывает наш собственный tileArea ниже.
    interactive: false
    hovered: tileArea.containsMouse
    clip: true

    readonly property color activeColor: dangerous ? Theme.errorColor : Theme.accentColor

    hoverColor: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.08)
    hoverBorderColor: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.25)

    property real verticalPadding: 9
    implicitHeight: tileLabel.implicitHeight + verticalPadding * 2

    readonly property real baseDuration: 420
    property real holdT: 0

    property int fillEasingType: Easing.OutCubic

    // ── Визуальный тюнинг эффекта заливки ────────────────────────────────────
    // Вынесено в property, чтобы можно было подбирать значения снаружи,
    // не залезая внутрь Canvas.onPaint.
    property real particleBaseOffset: 8        // отступ первой частицы от края волны
    property real particleSpacing: 14          // расстояние между соседними частицами
    property real particlePulseAmplitude: 0.6  // амплитуда пульсации радиуса частиц
    property real crestLineWidth: 1.5          // толщина линии гребня волны

    NumberAnimation {
        id: fillAnim
        target: tile
        property: "holdT"
        from: 0; to: 1
        duration: Math.round(tile.baseDuration * tile.weight)
        easing.type: tile.fillEasingType

        onFinished: {
            // Сначала — визуальный отклик, потом сам вызов действия.
            // confirmed() обязан оставаться неблокирующим
            // (Quickshell.execDetached, а не синхронный вызов) — иначе
            // flash и сброс заливки визуально подвиснут на время его работы.
            flashRect.opacity = 0.4
            flashAnim.start()

            // Плавный "дренаж" заливки был заменён на мгновенный сброс:
            // по результатам визуальной проверки резкий snap на фоне
            // короткой яркой вспышки воспринимается лучше, чем медленное угасание.
            tile.holdT = 0

            tile.confirmed()
        }
    }

    // ── Волновая заливка + гребень + частицы, всё в одном Canvas ────────────
    Canvas {
        id: fillCanvas
        anchors.fill: parent
        property real phase: 0

        // Единая точка конвертации QML-color в CSS-строку с альфой.
        // Qt.rgba(...) здесь не подходит: присвоенный Canvas 2D API
        // (ctx.fillStyle/strokeStyle) QML-объект color неявно приводится
        // через toString(), который отдаёт "#RRGGBB" без альфа-канала —
        // прозрачность потерялась бы. Строка собирается вручную намеренно.
        function rgba(c, alpha) {
            return "rgba(" + Math.round(c.r * 255) + "," +
                              Math.round(c.g * 255) + "," +
                              Math.round(c.b * 255) + "," + alpha + ")"
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var p = tile.holdT
            if (p <= 0.001) return

            ctx.save()

            // 1. Клип по скруглённой форме тайла
            var r = tile.radius
            ctx.beginPath()
            ctx.moveTo(r, 0); ctx.lineTo(width - r, 0)
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
            var c = tile.activeColor

            // 2. Основная полупрозрачная заливка
            ctx.beginPath()
            ctx.moveTo(0, 0)
            for (var y = 0; y <= height; y += 4) {
                var wob = Math.sin((y / height) * Math.PI * 3 + phase) * amp
                ctx.lineTo(edgeX + wob, y)
            }
            ctx.lineTo(0, height)
            ctx.closePath()
            ctx.fillStyle = rgba(c, 0.26)
            ctx.fill()

            // 3. Плавающие частицы позади волны
            ctx.fillStyle = rgba(c, 0.5)
            for (var i = 1; i <= 4; i++) {
                var distX = tile.particleBaseOffset + i * tile.particleSpacing
                if (edgeX > distX) {
                    var bx = edgeX - distX + 4 * Math.sin(phase * 1.5 + i)
                    var by = (height / 2) + (height / 3) * Math.sin(phase + i * 2.0)
                    var br = 1.0 + tile.particlePulseAmplitude * Math.cos(phase + i)

                    ctx.beginPath()
                    ctx.arc(bx, by, br, 0, 2 * Math.PI)
                    ctx.fill()
                }
            }

            // 4. Тонкая линия гребня волны — отдельный путь, не связанный
            // с контуром заливки, поэтому линия не обводит углы/дно фигуры.
            ctx.beginPath()
            var startWob = Math.sin((0 / height) * Math.PI * 3 + phase) * amp
            ctx.moveTo(edgeX + startWob, 0)
            for (var wy = 4; wy <= height; wy += 4) {
                var waveWob = Math.sin((wy / height) * Math.PI * 3 + phase) * amp
                ctx.lineTo(edgeX + waveWob, wy)
            }
            ctx.lineWidth = tile.crestLineWidth
            ctx.strokeStyle = rgba(c, 0.8)
            ctx.stroke()

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
    onActiveColorChanged: fillCanvas.requestPaint()

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
                    ? (tile.hovered
                       ? tile.activeColor
                       : Qt.rgba(tile.activeColor.r, tile.activeColor.g, tile.activeColor.b, 0.7))
                    : (tile.hovered ? tile.activeColor : Theme.mutedTextColor)
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }

        Text {
            id: tileLabel
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