import Quickshell
import Quickshell.Hyprland
import QtQuick.Effects
import QtQuick
import Quickshell.Wayland
import qs.theme

PanelWindow {
    id: root
    color: "transparent"
    visible: false
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    margins.left: Theme.sideBarWidth
    mask: Region { item:background}
    exclusionMode: ExclusionMode.Ignore
    
    property var currentComponent: null

    property string hAlign: "left"
    property string vAlign: "bottom"
    property real offsetX: 0
    property real offsetY: 0
    property bool animEnabled: true

    GlobalShortcut {
        name: "popupEscape"
        description: "Close popup"

        onPressed: {
            if (root.visible) {
                root.close()
            }
        }
    }

    Rectangle {
        id: background
        color: Qt.alpha(Theme.backgroundColor, 0.7)
        radius: Theme.popupBorderRadius
        border.width: Theme.popupBorderWidth
        border.color: Theme.borderColor

        Loader {
            id: loader
            anchors.fill: parent
            onLoaded: {
                var w = loader.item.implicitWidth
                var h = loader.item.implicitHeight
                reposition(w, h)
                background.implicitWidth = w
                background.implicitHeight = h
            }
        }

        Behavior on implicitHeight {
            enabled: root.animEnabled
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on implicitWidth {
            enabled: root.animEnabled
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on x {
            enabled: root.animEnabled
            NumberAnimation { duration: 300; easing.type: Easing.OutQuint }
        }
        Behavior on y {
            enabled: root.animEnabled
            NumberAnimation { duration: 300; easing.type: Easing.OutQuint }
        }
    }

    function show(component, posH, posV, offX, offY, triggerItem) {
        root.hAlign = posH
        root.vAlign = posV
        root.offsetX = offX
        root.offsetY = offY

        if (currentComponent === component) {
            close()
            return
        }

        if (!root.visible) {
            var startX = 0
            var startY = 0

            if (triggerItem) {
                var pos = triggerItem.mapToItem(null, triggerItem.width / 2, triggerItem.height / 2)
                startX = pos.x
                startY = pos.y
            }

            root.animEnabled = false
            background.x = startX
            background.y = startY
            background.implicitWidth = 0
            background.implicitHeight = 0
            root.visible = true
            root.animEnabled = true
            Qt.callLater(() => background.forceActiveFocus())
        }

        currentComponent = component
        loader.sourceComponent = component
    }

    function reposition(w, h) {
        if (hAlign === "left") {
            background.x = offsetX
        } else if (hAlign === "center") {
            background.x = (root.screen.width - root.margins.left - w) / 2 + offsetX
        } else if (hAlign === "right") {
            background.x = root.screen.width - root.margins.left - w - offsetX
        }

        if (vAlign === "top") {
            background.y = offsetY
        } else if (vAlign === "center") {
            background.y = (root.screen.height - h) / 2 + offsetY
        } else if (vAlign === "bottom") {
            background.y = root.screen.height - h - offsetY
        }
    }
    
    function close() {
        root.visible = false
        currentComponent = null
        loader.sourceComponent = null
    }
}