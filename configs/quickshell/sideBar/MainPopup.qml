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
    mask: Region { item: background }
    exclusionMode: ExclusionMode.Ignore

    property var currentComponent: null
    property bool loaderAActive: true

    property var anchorItem: null
    property real gap: 8

    readonly property int fadeDuration: 100

    GlobalShortcut {
        name: "popupEscape"
        description: "Close popup"
        onPressed: {
            if (root.visible) root._close()
        }
    }

    Rectangle {
        id: background
        color: Theme.glassContainer
        radius: Theme.popupBorderRadius
        border.width: Theme.popupBorderWidth
        border.color: Theme.glassContainerBorder
        clip: true

        readonly property var activeItem: loaderAActive ? loaderA.item : loaderB.item

        implicitWidth: root.visible ? (activeItem?.implicitWidth ?? 0) : 0
        implicitHeight: root.visible ? (activeItem?.implicitHeight ?? 0) : 0

        readonly property real startY: root.anchorItem ? root.getItemRect(root.anchorItem).y : 0

        x: root.gap

        y: {
            if (!root.visible || !root.anchorItem || !activeItem) return startY
            var rect = root.getItemRect(root.anchorItem)
            var h = activeItem.implicitHeight
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

        Loader {
            id: loaderA
            anchors.centerIn: parent
            opacity: 1

            onLoaded: {
                if (!item) return
                fadeInA.start()
                fadeOutB.start()
                root.loaderAActive = true
            }
        }

        Loader {
            id: loaderB
            anchors.centerIn: parent
            opacity: 0

            onLoaded: {
                if (!item) return
                fadeInB.start()
                fadeOutA.start()
                root.loaderAActive = false
            }
        }

        NumberAnimation {
            id: fadeInA
            target: loaderA; property: "opacity"
            from: 0; to: 1
            duration: root.fadeDuration
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: fadeOutA
            target: loaderA; property: "opacity"
            from: 1; to: 0
            duration: root.fadeDuration
            easing.type: Easing.InCubic
            onStopped: loaderA.sourceComponent = null
        }
        NumberAnimation {
            id: fadeInB
            target: loaderB; property: "opacity"
            from: 0; to: 1
            duration: root.fadeDuration
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: fadeOutB
            target: loaderB; property: "opacity"
            from: 1; to: 0
            duration: root.fadeDuration
            easing.type: Easing.InCubic
            onStopped: loaderB.sourceComponent = null
        }
    }

    // ── Публичный API ──────────────────────────────────────────
    function toggle(component, item, gapValue) {
        if (!root.visible) {
            _open(component, item, gapValue)
        } else if (currentComponent === component) {
            _close()
        } else {
            _switch(component, item, gapValue)
        }
    }

    function _open(component, item, gapValue) {
        root.anchorItem = item
        root.gap = gapValue ?? 8
        root.currentComponent = component

        root.visible = true
        Qt.callLater(() => background.forceActiveFocus())

        var target = loaderAActive ? loaderB : loaderA
        target.opacity = 0
        target.sourceComponent = component
    }

    function _switch(component, item, gapValue) {
        root.anchorItem = item
        root.gap = gapValue ?? 8
        root.currentComponent = component

        var target = loaderAActive ? loaderB : loaderA
        target.opacity = 0
        target.sourceComponent = component
    }

    function _close() {
        root.visible = false
        root.currentComponent = null
        root.anchorItem = null
        loaderA.sourceComponent = null
        loaderB.sourceComponent = null
    }

    function getItemRect(item) {
        var pos = item.mapToItem(null, 0, 0)
        return {
            y: pos.y,
            height: item.height
        }
    }
}