import Quickshell
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

    Rectangle {
        id: background
        color: Qt.alpha(Theme.backgroundColor, 0.7)
        radius: Theme.popupBorderRadius
        // border.width: Theme.popupBorderWidth
        border.color: Theme.borderColor
        // anchors.bottom: parent.bottom 
        // layer.enabled: true
        // layer.effect: MultiEffect {
        //     shadowEnabled: true
        //     shadowColor: Qt.alpha("#000000", 0.5)
        //     shadowBlur: 0.5       // 0.0 - 1.0
        //     shadowHorizontalOffset: 0
        //     shadowVerticalOffset: 8
        //     shadowScale: 1.1
        // }


        Loader {
            id: loader
            anchors.fill: parent
            onLoaded: {
                var w = loader.item.implicitWidth
                var h = loader.item.implicitHeight
                reposition(w, h)
                background.implicitWidth = w
                background.implicitHeight = h
                root.visible = true
            }
        }

        Behavior on implicitHeight {
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on implicitWidth {
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }
        Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }

    }

    function show(component, posH, posV, offsetX, offsetY) {
        root.hAlign = posH
        root.vAlign = posV
        root.offsetX = offsetX
        root.offsetY = offsetY

        if (currentComponent === component) {
            close()
            return
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