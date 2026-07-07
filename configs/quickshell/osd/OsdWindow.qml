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

    // Конфигурация всех типов OSD в одном месте
    readonly property var osdConfigs: ({
        "brightness": { singleton: Power, property: "brightness", contentFile: "content/BrightnessOSD.qml" },
        "volume": { singleton: Volume, property: "volume", contentFile: "content/TestOSD.qml" }
        // FIXME: заменить на нормальный VolumeOSD
    })
    
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

            color: Theme.sectionColor
            radius: 12
            
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
                onStopped: {
                    osdWrapper.destroy()
                    console.log("OSD", Component, "destroyed")
                }
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
        console.log("OSD update:", type, value)
        
        var idx = findOsdIndex(type)
        if (idx !== -1) {
            console.log("Updating existing", type, "OSD")
            activeOsds[idx].obj.osdValue = value
        } else {
            console.log("Creating new", type, "OSD")
            var obj = createOsd(type, value)
            activeOsds.push({ type: type, obj: obj })
            recalculatePositions()
        }
    }

    function createOsd(type, value) {
        var content = Qt.createComponent(osdConfigs[type].contentFile)
        
        var obj = osdTemp.createObject(container, {
            contentComponent: content,
            osdValue: value,
            osdType: type,
            y: root.screen.height
        })
        
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

    Instantiator {
        model: Object.keys(osdConfigs)
        
        delegate: Connections {
            property string type: modelData
            property var config: osdConfigs[type]
            
            target: config.singleton
            ignoreUnknownSignals: true
            
            Component.onCompleted: {
                var signalName = config.property + "Changed"
                target[signalName].connect(function() {
                    handleOsdUpdate(type, target[config.property])
                })
            }
        }
    }
}