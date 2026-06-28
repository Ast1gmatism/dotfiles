import QtQuick
import qs.singletons
import qs.components

StyleText {
    text: Keyboard.layout
    onClicked: console.log("Keyboard clicked")
}