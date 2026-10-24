import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtCore
import Quickshell.Wayland
import QtQuick.Shapes

Scope {
    id: root
    property bool active: false

    property bool fading: false
    property string pendingRegion: ""
    property string pendingDest: "both"

    function shoot(region, dest) {
        if (root.fading || shotProcess.running) return   // снимок уже идёт
        root.pendingRegion = region
        root.pendingDest = dest
        root.fading = true
    }

    function closeAndCapture() {
        root.active = false
        root.fading = false

        var scriptPath = Qt.resolvedUrl("capture.sh").toString().replace("file://", "")
        shotProcess.command = [scriptPath, root.pendingRegion, root.pendingDest]
        shotProcess.running = true
    }

    Process {
        id: shotProcess
        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length) console.warn("Capture:", text.trim())
        }
        onExited: (code) => {
            if (code !== 0) console.warn("Capture: capture.sh вышел с кодом", code)
        }
    }

    IpcHandler {
        target: "screen"
        function capture() {
            if (root.fading) return
            root.active = !root.active
        }
    }

    LazyLoader {
        active: root.active
        component: PanelWindow {
            id: win

            property real contentOpacity: 1

            function captureRegion(x, y, w, h) {
                if (w < 1 || h < 1) {
                    console.warn("Invalid selection: width/height < 1")
                    return
                }
                var geomRaw = Math.round(x) + "," + Math.round(y) + " " +
                              Math.round(w) + "x" + Math.round(h)
                root.shoot(geomRaw, notch.destination)
            }

            function captureFullscreen() {
                root.shoot("", notch.destination)
            }

            readonly property string layerNamespace: "capture-overlay"

            color: "transparent"
            anchors { top: true; left: true; right: true; bottom: true }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: win.layerNamespace

            focusable: true

            Item {
                id: keyHandler
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: if (!root.fading) root.active = false
            }

            Item {
                id: overlayRoot
                anchors.fill: parent
                opacity: win.contentOpacity

                property real startX: 0
                property real startY: 0
                property real curX: 0
                property real curY: 0
                property bool selecting: false
                property bool hasSelection: false

                readonly property real selX: Math.min(startX, curX)
                readonly property real selY: Math.min(startY, curY)
                readonly property real selW: Math.abs(curX - startX)
                readonly property real selH: Math.abs(curY - startY)

                readonly property int minDragThreshold: 8

                // Вырез. Пока его нет, все четыре нули: вырожденный контур
                // в точке ничего не вырезает, и затемнение остаётся сплошным.
                readonly property real holeX: hasSelection ? selX : 0
                readonly property real holeY: hasSelection ? selY : 0
                readonly property real holeW: hasSelection ? selW : 0
                readonly property real holeH: hasSelection ? selH : 0

                // Контур выреза — ОДНО описание для заливки и для рамки.
                // Оба ShapePath ниже читают эти две строки, поэтому дырка и
                // белая линия вокруг неё не могут разойтись: поменяешь форму
                // здесь — поменяется сразу везде.
                readonly property string holePath: {
                    var x = holeX, y = holeY, w = holeW, h = holeH
                    return "M" + x + " " + y +
                           " L" + (x + w) + " " + y +
                           " L" + (x + w) + " " + (y + h) +
                           " L" + x + " " + (y + h) + " Z"
                }

                // Внешний контур + вырез в одной строке: правило чётности
                // превращает второй контур в дырку.
                readonly property string shadePath:
                    "M0 0 L" + width + " 0 L" + width + " " + height +
                    " L0 " + height + " Z " + holePath

                Shape {
                    id: shade
                    anchors.fill: parent

                    // 1. затемнение с дыркой
                    ShapePath {
                        fillColor: Qt.rgba(0, 0, 0, 0.4)
                        fillRule: ShapePath.OddEvenFill
                        strokeWidth: 0
                        PathSvg { path: overlayRoot.shadePath }
                    }

                    // 2. рамка по тому же контуру, что и дырка.
                    //    При отсутствии выделения контур вырожден в точку —
                    //    толщину обнуляем, иначе в углу экрана была бы точка.
                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: "white"
                        strokeWidth: overlayRoot.hasSelection ? 1 : 0
                        PathSvg { path: overlayRoot.holePath }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    cursorShape: Qt.CrossCursor

                    // Функция для жёсткого ограничения координат границами экрана
                    function clamp(val, min, max) {
                        return Math.max(min, Math.min(val, max))
                    }

                    onPressed: (mouse) => {
                        // Фиксируем старт тоже с clamp'ом
                        overlayRoot.startX = clamp(mouse.x, 0, overlayRoot.width)
                        overlayRoot.startY = clamp(mouse.y, 0, overlayRoot.height)
                        overlayRoot.curX = overlayRoot.startX
                        overlayRoot.curY = overlayRoot.startY
                        overlayRoot.hasSelection = false
                        overlayRoot.selecting = true
                    }

                    onPositionChanged: (mouse) => {
                        if (!overlayRoot.selecting) return
                        // Ограничиваем текущую позицию
                        overlayRoot.curX = clamp(mouse.x, 0, overlayRoot.width)
                        overlayRoot.curY = clamp(mouse.y, 0, overlayRoot.height)

                        if (overlayRoot.selW > overlayRoot.minDragThreshold ||
                            overlayRoot.selH > overlayRoot.minDragThreshold) {
                            overlayRoot.hasSelection = true
                        }
                    }

                    onReleased: {
                        overlayRoot.selecting = false
                        if (!overlayRoot.hasSelection) return

                        var x = Math.round(overlayRoot.selX)
                        var y = Math.round(overlayRoot.selY)
                        var w = Math.round(overlayRoot.selW)
                        var h = Math.round(overlayRoot.selH)

                        captureRegion(x, y, w, h)
                    }
                }
            }

            CapNotch {
                id: notch
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: win.contentOpacity

                collapsed: overlayRoot.selecting

                onCloseRequested: root.active = false
                onCaptureFullscreenRequested: win.captureFullscreen()
            }

            NumberAnimation {
                id: fadeOut
                target: win
                property: "contentOpacity"
                to: 0
                duration: 150
                easing.type: Easing.OutCubic
                onFinished: Qt.callLater(root.closeAndCapture)
            }

            Connections {
                target: root
                function onFadingChanged() {
                    if (root.fading) {
                        grab.active = false
                        fadeOut.start()
                    }
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [win]
            }

            onVisibleChanged: {
                if (visible) {
                    grab.active = true
                    keyHandler.forceActiveFocus()
                }
            }

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active && !root.fading) root.active = false
                }
            }
        }
    }
}
