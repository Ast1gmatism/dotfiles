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

    property string hAlign: "left"
    property string vAlign: "bottom"
    property real offsetX: 0
    property real offsetY: 0
    property bool animEnabled: true

    readonly property int fadeDuration: 100

    GlobalShortcut {
        name: "popupEscape"
        description: "Close popup"
        onPressed: {
            if (root.visible) root.close()
        }
    }

    Rectangle {
        id: background
        color: Theme.glassContainer
        radius: Theme.popupBorderRadius
        border.width: Theme.popupBorderWidth
        border.color: Theme.borderColor
        clip: true

        // ── Контент: два лоадера для crossfade ──────────────────────
        Loader {
            id: loaderA
            anchors.centerIn: parent
            opacity: 1

            onLoaded: {
                if (!item) return
                root.reposition(item.implicitWidth, item.implicitHeight)
                background.implicitWidth = item.implicitWidth
                background.implicitHeight = item.implicitHeight

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
                root.reposition(item.implicitWidth, item.implicitHeight)
                background.implicitWidth = item.implicitWidth
                background.implicitHeight = item.implicitHeight

                fadeInB.start()
                fadeOutA.start()
                root.loaderAActive = false
            }
        }

        // ── Анимации входа/выхода, каждая привязана к своему лоадеру ──
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

        // ── Морф размера/позиции окна (без изменений) ──────────────
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
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on y {
            enabled: root.animEnabled
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
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

        // новый контент всегда грузим в НЕактивный лоадер
        if (loaderAActive) {
            loaderB.opacity = 0
            loaderB.sourceComponent = component
        } else {
            loaderA.opacity = 0
            loaderA.sourceComponent = component
        }
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
        loaderA.sourceComponent = null
        loaderB.sourceComponent = null
    }
}