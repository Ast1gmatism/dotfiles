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
    // TODO: заменить 9-позиционную систему на гибкое позиционирование
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
        border.color: Theme.glassContainerBorder
        clip: true

        // ── Контент: два лоадера для crossfade ──────────────────────
        // TODO: посмотреть, можно ли что-то сделать с StackView
        Loader {
            id: loaderA
            anchors.centerIn: parent
            opacity: 1

            onLoaded: {
                if (!item) return
                root.updateGeometry(item)
                fadeInA.start()
                fadeOutB.start()
                root.loaderAActive = true
            }

            Connections {
                target: loaderA.item
                function onImplicitWidthChanged() { root.updateGeometry(loaderA.item) }
                function onImplicitHeightChanged() { root.updateGeometry(loaderA.item) }
            }
        }

        Loader {
            id: loaderB
            anchors.centerIn: parent
            opacity: 0

            onLoaded: {
                if (!item) return
                root.updateGeometry(item)
                fadeInB.start()
                fadeOutA.start()
                root.loaderAActive = false
            }

            Connections {
                target: loaderB.item
                function onImplicitWidthChanged() { root.updateGeometry(loaderB.item) }
                function onImplicitHeightChanged() { root.updateGeometry(loaderB.item) }
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

        if (loaderAActive) {
            loaderB.opacity = 0
            loaderB.sourceComponent = component
        } else {
            loaderA.opacity = 0
            loaderA.sourceComponent = component
        }
    }
    function updateGeometry(item) {
        if (!item) return
        background.implicitWidth = item.implicitWidth
        background.implicitHeight = item.implicitHeight
        root.reposition(item.implicitWidth, item.implicitHeight)
        // FIXME: reposition() императивно задает x/y вместо биндинга
        // Должно стать вычисляемым свойством
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