import Quickshell
import QtQuick
import qs.singletons
import qs.theme

PanelWindow {
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
        "brightness": { singleton: Power, property: "brightness", contentFile: "BrightnessOSD.qml" },
        "volume": { singleton: Volume, property: "volume", contentFile: "TestOSD.qml" }
    })
    
    property var activeOsds: ({})
    
    Component {
        id: osdWrapper
        Rectangle {
            property Component contentComponent
            property real osdValue: 0
        
            implicitWidth: loader.implicitWidth + 16
            implicitHeight: loader.implicitHeight + 16

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
                    parent.destroy()
                    console.log("OSD", Component, "destroyed")
                }
            }
            onOsdValueChanged: {
                hideTimer.restart()
            }
        }
    }
    
    function handleOsdUpdate(type, value) {
        console.log("OSD update:", type, value)
        
        if (activeOsds[type]) {
            console.log("Updating existing", type, "OSD")
            activeOsds[type].osdValue = value
        } else {
            console.log("Creating new", type, "OSD")
            activeOsds[type] = createOsd(type, value)
        }
    }

    function createConnectionForConfig(type, config) {
        const signalName = "on" 
            + config.property.charAt(0).toUpperCase() 
            + config.property.slice(1) 
            + "Changed"

        const connectionObj = Qt.createQmlObject(`
            import QtQuick
            
            Connections {
                target: null
                
                function ${signalName}() {
                    handleOsdUpdate("${type}", target.${config.property})
                }
            }
        `, root)
        
        connectionObj.target = config.singleton
    }

    function createOsd(type, value) {
        var content = Qt.createComponent(osdConfigs[type].contentFile)
        
        var obj = osdWrapper.createObject(container, {
            contentComponent: content,
            osdValue: value,
            x: root.screen.width / 2 - 80, // TODO: не забыть про перерасчет
            y: root.screen.height - 160   // вообще, вынести x и y отсюда
            
        })
        
        obj.Component.destruction.connect(function() {
            delete activeOsds[type]
        })
        return obj
    }
    
    Component.onCompleted: {
        for (var type in osdConfigs) {
            createConnectionForConfig(type, osdConfigs[type])
        }
    }
}