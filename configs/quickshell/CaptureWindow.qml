import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme

PanelWindow {
    id: root
    
    visible: true
    color: "transparent"
    
    // Полноэкранное окно для затемнения
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    exclusionMode: ExclusionMode.Ignore
    
    // === СОСТОЯНИЯ ===
    property bool isVideo: false
    property bool isArea: true
    property bool saveToFile: true
    property string videoFormat: "mp4"
    
    // === КОМПОНЕНТ: Кнопка с иконкой ===
    component IconButton: Item {
        property string icon: ""
        property bool active: false
        property color activeColor: Theme.successColor
        property color defaultColor: Qt.alpha(Theme.foregroundColor, 0.05)
        signal clicked()
        
        width: 40
        height: 40
        
        Rectangle {
            anchors.fill: parent
            color: active ? Qt.alpha(activeColor, 0.25) : defaultColor
            radius: 8
            border.color: active ? activeColor : "transparent"
            border.width: 1
            
            Behavior on color { ColorAnimation { duration: 100 } }
        }
        
        Text {
            anchors.centerIn: parent
            text: icon
            font.pixelSize: 20
            color: Theme.foregroundColor
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: parent.clicked()
            cursorShape: Qt.PointingHandCursor
        }
    }
    
    // === ЗАТЕМНЕНИЕ ===
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }
    }
    
    // === ЧЕЛКА (ПАНЕЛЬ) ===
    Rectangle {
        id: chelka
        anchors.top: parent.top
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        height: 72
        width: rowLayout.width + 32
        color: Theme.backgroundColor
        radius: 16
        border.color: Qt.alpha(Theme.foregroundColor, 0.1)
        border.width: 1
        
        // Предотвращаем закрытие при клике на челку
        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
        }
        
        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 12
            
            // === ГРУППА 1: Режим (Фото/Видео) ===
            RowLayout {
                spacing: 4
                
                IconButton {
                    icon: "📷"
                    active: !isVideo
                    activeColor: Theme.successColor
                    onClicked: isVideo = false
                }
                
                IconButton {
                    icon: "🎥"
                    active: isVideo
                    activeColor: "#f38ba8"
                    onClicked: isVideo = true
                }
            }
            
            // Разделитель
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 32
                color: Qt.alpha(Theme.foregroundColor, 0.15)
            }
            
            // === ГРУППА 2: Область ===
            RowLayout {
                spacing: 4
                
                IconButton {
                    icon: "▭" // Область
                    active: isArea
                    activeColor: "#89b4fa"
                    onClicked: isArea = true
                }
                
                IconButton {
                    icon: "⛶" // Полный экран (или "☐")
                    active: !isArea
                    activeColor: "#89b4fa"
                    onClicked: isArea = false
                }
            }
            
            // Разделитель
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 32
                color: Qt.alpha(Theme.foregroundColor, 0.15)
                visible: !isVideo
            }
            
            // === ГРУППА 3: Назначение (только для фото) ===
            RowLayout {
                spacing: 4
                visible: !isVideo
                
                IconButton {
                    icon: "📋" // Буфер
                    active: !saveToFile
                    activeColor: "#f9e2af"
                    onClicked: saveToFile = false
                }
                
                IconButton {
                    icon: "📁" // Файл
                    active: saveToFile
                    activeColor: "#f9e2af"
                    onClicked: saveToFile = true
                }
            }
            
            // === ГРУППА 3: Формат (только для видео) ===
            RowLayout {
                spacing: 4
                visible: isVideo
                
                IconButton {
                    icon: "🎬" // MP4
                    active: videoFormat === "mp4"
                    activeColor: "#a6e3a1"
                    onClicked: videoFormat = "mp4"
                }
                
                IconButton {
                    icon: "🎞️" // GIF
                    active: videoFormat === "gif"
                    activeColor: "#a6e3a1"
                    onClicked: videoFormat = "gif"
                }
            }
            
            // Разделитель (если нужен)
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 32
                color: Qt.alpha(Theme.foregroundColor, 0.15)
                visible: (isVideo || saveToFile)
            }
            
            // === ГРУППА 4: Папка (если сохранение в файл) ===
            IconButton {
                icon: "📂"
                visible: isVideo || saveToFile
                activeColor: "#cba6f7"
                onClicked: console.log("Select folder...")
            }
            
            // Разделитель
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 32
                color: Qt.alpha(Theme.foregroundColor, 0.15)
            }
            
            // === ГРУППА 5: Старт ===
            IconButton {
                icon: isVideo ? "🔴" : "⚡"
                activeColor: isVideo ? "#f38ba8" : Theme.successColor
                defaultColor: Qt.alpha(isVideo ? "#f38ba8" : Theme.successColor, 0.2)
                
                onClicked: {
                    root.visible = false
                    console.log("Capture:", isVideo ? "video" : "screenshot", 
                               "| area:", isArea, 
                               "| to:", isVideo ? videoFormat : (saveToFile ? "file" : "clipboard"))
                }
            }
        }
    }
}