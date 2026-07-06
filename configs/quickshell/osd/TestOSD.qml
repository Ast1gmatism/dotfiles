import QtQuick
// FIXME: плейсхолдер, заменить реальным
Item {
    id: root
    implicitWidth: 100
    implicitHeight: 30
    property real value: 0

    Text {
        anchors.centerIn: parent
        text: root.value
        color: "red"
    }
}