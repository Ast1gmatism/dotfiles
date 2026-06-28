pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland

Singleton {
    id: root
    property string layout

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name == "activelayout") {
                layoutFetch.running = true
            }
        }
    }
    
    Process {
        id: layoutFetch
        command: ["hyprctl", "devices", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let data = JSON.parse(this.text)
                let main = data.keyboards.find(kb => kb.main == true)
                let layouts = main.layout.split(",")
                let current = main.active_layout_index
                root.layout = layouts[current].trim()
            }
        }
    }
}