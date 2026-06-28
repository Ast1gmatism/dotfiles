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

    Rectangle {
        id: background
        color: Qt.rgba(0.2, 0.2, 0.2, 0.3)
        // color: Qt.rgba(30, 30, 46, 0.1)
        radius: Theme.popupBorderRadius
        // border.width: Theme.popupBorderWidth
        // border.color: Theme.borderColor
        anchors.bottom: parent.bottom 
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
                background.implicitWidth = loader.item.implicitWidth
                background.implicitHeight = loader.item.implicitHeight
                visible = true
            }
        }

        Behavior on implicitHeight {
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on implicitWidth {
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 400; easing.type: Easing.OutQuint }
        }

    }

    function show(component, marginH, marginV, isTop) {

        if (currentComponent === component) {
            visible = false
            currentComponent = null
            loader.sourceComponent = null
            return
        }

        currentComponent = component
        loader.sourceComponent = component
        background.x = marginH
        background.anchors.bottomMargin = marginV
        // background.anchors.bottom = undefined
        // background.anchors.top = undefined

        // if (isTop) {
        //     background.anchors.top = root.top
        //     background.anchors.topMargin = marginV
        // } else {
        //     background.anchors.bottom = root.bottom
        //     background.anchors.bottomMargin = marginV
        // }
    }
}


// 1) Хочу переделать вызов mainPopup: контент, положение по вертикали(верх, центр, низ), положение по горизонтали(лево, центр, право)
// 2) Как реализовать закрытие попапа по клику вне?
// 3) Что дает переделка mainPopup в синглтон?