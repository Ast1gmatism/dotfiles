import QtQuick

Item {
    id: root
    implicitWidth: 200
    implicitHeight: 70
    property real value: 0

    Text {
        anchors.centerIn: parent
        text: root.value
        color: "red"
    }
}