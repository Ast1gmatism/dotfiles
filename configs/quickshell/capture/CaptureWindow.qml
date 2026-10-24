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

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.4
                    visible: !overlayRoot.hasSelection
                }

                Rectangle {
                    color: "black"
                    opacity: 0.4
                    x: 0; y: 0
                    width: parent.width
                    height: overlayRoot.selY
                    visible: overlayRoot.hasSelection
                }
                Rectangle {
                    color: "black"
                    opacity: 0.4
                    x: 0
                    y: overlayRoot.selY + overlayRoot.selH
                    width: parent.width
                    height: parent.height - y
                    visible: overlayRoot.hasSelection
                }
                Rectangle {
                    color: "black"
                    opacity: 0.4
                    x: 0
                    y: overlayRoot.selY
                    width: overlayRoot.selX
                    height: overlayRoot.selH
                    visible: overlayRoot.hasSelection
                }
                Rectangle {
                    color: "black"
                    opacity: 0.4
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