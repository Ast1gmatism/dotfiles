// theme/Colors.qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property Palette palette: Palette {}

    FileView {
        path: Quickshell.shellDir + "/theme/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text())
    }

    function load(data: string): void {
        try {
            const scheme = JSON.parse(data)
            for (const [key, value] of Object.entries(scheme)) {
                if (palette.hasOwnProperty(key) && key !== "name")
                    palette[key] = value
            }
            console.log("Colors: loaded from JSON")
        } catch (e) {
            console.error("Colors: parse failed:", e)
        }
    }

    component Palette: QtObject {
        property color crust:    "#1a1a1a"
        property color mantle:   "#242424"
        property color base:     "#2e2e2e"
        property color surface0: "#383838"
        property color surface1: "#454545"
        property color surface2: "#565656"

        property color overlay0: "#6e6e6e"
        property color overlay1: "#8a8a8a"
        property color overlay2: "#a8a8a8"

        property color text:     "#e0e0e0"
        property color subtext1: "#b8b8b8"
        property color subtext0: "#909090"

        property color red:      "#d97878"
        property color peach:    "#d9a878"
        property color yellow:   "#d9d178"
        property color green:    "#8fd978"
        property color teal:     "#78d9c8"
        property color blue:     "#7898d9"
        property color mauve:    "#a878d9"
        property color pink:     "#d978c0"
        property color lavender: "#9a9ad9"
    }
}