import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtCore
import Quickshell.Wayland

Scope {
    id: root
    property bool active: false

    IpcHandler {
        target: "screen"
        function capture() {
            root.active = !root.active
        }
    }

    LazyLoader {
        active: root.active
        component: PanelWindow {
            id: win

            function buildCommand(geom) {
                var timestamp = new Date().toISOString()
                    .replace("T", "_")
                    .replace(/:/g, "-")
                    .slice(0, 19)

                var dir = "$HOME/Pictures/Screenshots"
                var filepath = dir + "/" + timestamp + ".png"
                
                // 1. Создаём папку
                var mkdir = "mkdir -p \"" + dir + "\" && "
                // 2. Ждём 250мс, пока Hyprland полностью скроет оверлей (фейд-аут)
                var delay = "sleep 0.25 && "

                if (notch.destination === "clipboard")
                    return delay + mkdir + "grim " + geom + " - | wl-copy"

                if (notch.destination === "file")
                    return delay + mkdir + "grim " + geom + " \"" + filepath + "\""

                return delay + mkdir + "grim " + geom + " - | tee \"" + filepath + "\" | wl-copy"
            }

            function captureRegion(x, y, w, h) {
                var geomRaw = x + "," + y + " " + w + "x" + h  // чистая геометрия
                var scriptPath = Qt.resolvedUrl("capture.sh").toString().replace("file://", "")
                
                Quickshell.execDetached([scriptPath, geomRaw, notch.destination])
                root.active = false
            }

            function captureFullscreen() {
                var scriptPath = Qt.resolvedUrl("capture.sh").toString().replace("file://", "")
                Quickshell.execDetached([scriptPath, "", notch.destination])
                root.active = false
            }

            color: "transparent"
            anchors { top: true; left: true; right: true; bottom: true }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "capture-test"

            focusable: true

            Item {
                id: keyHandler
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: root.active = false
            }

            Item {
                id: overlayRoot
                anchors.fill: parent

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

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.5)
                    visible: !overlayRoot.hasSelection
                }

                Rectangle {
                    color: Qt.rgba(0, 0, 0, 0.5)
                    x: 0; y: 0
                    width: parent.width
                    height: overlayRoot.selY
                    visible: overlayRoot.hasSelection
                }
                Rectangle {
                    color: Qt.rgba(0, 0, 0, 0.5)
                    x: 0
                    y: overlayRoot.selY + overlayRoot.selH
                    width: parent.width
                    height: parent.height - y
                    visible: overlayRoot.hasSelection
                }
                Rectangle {
                    color: Qt.rgba(0, 0, 0, 0.5)
                    x: 0
                    y: overlayRoot.selY
                    width: overlayRoot.selX
                    height: overlayRoot.selH
                    visible: overlayRoot.hasSelection
                }
                Rectangle {
                    color: Qt.rgba(0, 0, 0, 0.5)
                    x: overlayRoot.selX + overlayRoot.selW
                    y: overlayRoot.selY
                    width: parent.width - x
                    height: overlayRoot.selH
                    visible: overlayRoot.hasSelection
                }

                Rectangle {
                    x: overlayRoot.selX
                    y: overlayRoot.selY
                    width: overlayRoot.selW
                    height: overlayRoot.selH
                    color: "transparent"
                    border.width: 1
                    border.color: "white"
                    visible: overlayRoot.hasSelection
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
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                onCloseRequested: root.active = false
                onCaptureFullscreenRequested: win.captureFullscreen()
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
                    if (!grab.active) root.active = false
                }
            }
        }
    }
}