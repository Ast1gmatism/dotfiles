import Quickshell
import QtQuick
import qs.singletons
import qs.theme

PanelWindow {
    // TODO: поддержка мультимонитора
    // =================================== //
    id: root
    color: "transparent"
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    mask: Region {}
    visible: true
    // =================================== //

    Item {
        id: container
        anchors.fill: parent
    }

    property var activeOsds: []
    
    Component {
        id: osdTemp
        Rectangle {
            id: osdWrapper
            property Component contentComponent
            property string osdType: ""
            property real osdValue: 0
            property real targetX: 0
            property bool positioned: false
            
            implicitWidth: loader.implicitWidth + 16
            implicitHeight: loader.implicitHeight + 16
            x: targetX

            color: Theme.glassGroup
            radius: 10
            border.color: Theme.glassBorder
            border.width: 1
            
            Loader {
                id: loader
                anchors.centerIn: parent
                sourceComponent: contentComponent
                onLoaded: {
                    item.value = Qt.binding(function() { return osdValue })
                }
            }

            Timer {
                id: hideTimer
                interval: 2000
                repeat: false
                onTriggered: {
                    var idx = findOsdIndex(osdType)
                    if (idx !== -1) activeOsds.splice(idx, 1)
                    recalculatePositions()
                    osdHide.start()
                }
            }

            onOsdValueChanged: {
                hideTimer.restart()
            }

            Component.onCompleted: osdShow.start()

            NumberAnimation {
                id: osdShow
                target: osdWrapper
                property: "y"
                to: root.screen.height - 60
                duration: 200
                easing.type: Easing.OutQuint
                onStopped: positioned = true
            }
            
            NumberAnimation {
                id: osdHide
                target: osdWrapper
                property: "y"
                to: root.screen.height
                duration: 200
                easing.type: Easing.OutQuint
                onStopped: osdWrapper.destroy()
            }

            Behavior on x {
                enabled: positioned
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }
        }
    }
    
    function handleOsdUpdate(type, value) {
        var idx = findOsdIndex(type)
        if (idx !== -1) {
            activeOsds[idx].obj.osdValue = value
        } else {
            var obj = createOsd(type, value)
            if (!obj) return

            activeOsds.push({ type: type, obj: obj })
            recalculatePositions()
        }
    }

    function createOsd(type, value) {
        var content

        switch (type) {
        case "brightness":
            content = Qt.createComponent("content/BrightnessOSD.qml")
            break

        case "volume":
            content = Qt.createComponent("content/TestOSD.qml")
            break

        default:
            console.warn("Unknown OSD type:", type)
            return null
        }

        if (content.status === Component.Error) {
            console.warn("Failed to load OSD component:", content.errorString())
            return null
        }

        var obj = osdTemp.createObject(container, {
            contentComponent: content,
            osdValue: value,
            osdType: type,
            y: root.screen.height
        })

        if (!obj)
            console.warn("Failed to create OSD:", type)

        return obj
    }

    function recalculatePositions() {
        var totalWidth = 0
        
        for (var i = 0; i < activeOsds.length; i++) {
            totalWidth += activeOsds[i].obj.width
            if (i < activeOsds.length - 1) totalWidth += 16
        }
        
        var startX = (root.screen.width - totalWidth) / 2
        var offset = 0
        
        for (var j = 0; j < activeOsds.length; j++) {
            activeOsds[j].obj.targetX = startX + offset
            offset += activeOsds[j].obj.width + 16
        }
    }

    function findOsdIndex(type) {
        for (var i = 0; i < activeOsds.length; i++) {
            if (activeOsds[i].type === type) return i
        }
        return -1
    }

    Connections {
        target: Power

        function onBrightnessChanged() {
            root.handleOsdUpdate("brightness", Power.brightness)
        }
    }

    Connections {
        target: Volume

        function onVolumeChanged() {
            root.handleOsdUpdate("volume", Volume.volume)
        }
    }
}
