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

    // ── Состояние привязки к виджету ─────────────────────────
    property var anchorItem: null
    property string placement: "bottom"   // top | bottom | left | right
    property string alignment: "start"    // start | center | end
    property real gap: 8

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

        // ── Морф размера/позиции окна ──────────────
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

    // ── Публичный API ──────────────────────────────────────────
    function showAt(component, item, placement, alignment, gap) {
        root.anchorItem = item
        root.gap = gap ?? 8

        if (currentComponent === component) {
            close()
            return
        }

        if (!root.visible) {
            var rect = getItemRect(item)
            var startX = rect.x + rect.width / 2
            var startY = rect.y + rect.height / 2

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

    function reposition(w, h) {
        if (!root.anchorItem) return

        var rect = getItemRect(root.anchorItem)

        var x = root.gap
        var y = rect.y + rect.height / 2 - h / 2

        // Прижимаем к краям экрана, если вылезает
        var screenH = root.screen.height
        y = Math.max(root.gap, Math.min(y, screenH - h - root.gap))

        background.x = x
        background.y = y
    }

    function getItemRect(item) {
        var pos = item.mapToItem(null, 0, 0)
        return {
            y: pos.y,
            height: item.height
        }
    }

    function updateGeometry(item) {
        if (!item) return
        background.implicitWidth = item.implicitWidth
        background.implicitHeight = item.implicitHeight
        root.reposition(item.implicitWidth, item.implicitHeight)
        // FIXME: реализовать через реактивный binding вместо императивного вызова (см. TODO)
    }

    function close() {
        root.visible = false
        currentComponent = null
        anchorItem = null
        loaderA.sourceComponent = null
        loaderB.sourceComponent = null
    }
}