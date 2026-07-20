import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
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
    mask: Region { item: background }
    exclusionMode: ExclusionMode.Ignore

    property var currentComponent: null
    property var anchorItem: null
    property real gap: 10

    readonly property int fadeDuration: 100

    Rectangle {
        id: background
        color: Theme.glassContainer
        radius: Theme.popupBorderRadius
        border.width: Theme.popupBorderWidth
        border.color: Theme.glassBorder
        clip: true

        implicitWidth: root.visible ? (stack.currentItem?.implicitWidth ?? 0) : 0
        implicitHeight: root.visible ? (stack.currentItem?.implicitHeight ?? 0) : 0

        readonly property real startY: root.anchorItem ? root.getItemRect(root.anchorItem).y : 0

        x: root.gap

        y: {
            if (!root.visible || !root.anchorItem || !stack.currentItem) return startY
            var rect = root.getItemRect(root.anchorItem)
            var h = stack.currentItem.implicitHeight
            var centerY = rect.y + rect.height / 2 - h / 2
            var screenH = root.screen.height
            return Math.max(root.gap, Math.min(centerY, screenH - h - root.gap))
        }

        Behavior on implicitWidth {
            enabled: root.visible
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on implicitHeight {
            enabled: root.visible
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on y {
            enabled: root.visible
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }

        StackView {
            id: stack
            anchors.fill: parent

            replaceEnter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0; to: 1
                    duration: root.fadeDuration
                    easing.type: Easing.OutCubic
                }
            }
            replaceExit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1; to: 0
                    duration: root.fadeDuration
                    easing.type: Easing.InCubic
                }
            }
        }
    }

    // ── Публичный API ──────────────────────────────────────────
    function toggle(component, item, gapValue) {
        if (!root.visible) {
            _open(component, item, gapValue)
        } else if (currentComponent === component) {
            close()
        } else {
            _switch(component, item, gapValue)
        }
    }

    function close() {
        root.visible = false
        root.currentComponent = null
        root.anchorItem = null
        stack.clear(StackView.Immediate)
    }

    function _open(component, item, gapValue) {
        root.anchorItem = item
        root.gap = gapValue ?? 8
        root.currentComponent = component

        root.visible = true
        Qt.callLater(() => background.forceActiveFocus())

        stack.push(component, StackView.Immediate)
    }

    function _switch(component, item, gapValue) {
        root.anchorItem = item
        root.gap = gapValue ?? 8
        root.currentComponent = component

        stack.replace(component)
    }

    function getItemRect(item) {
        var pos = item.mapToItem(null, 0, 0)
        return {
            y: pos.y,
            height: item.height
        }
    }
}