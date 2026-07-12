import QtQuick
import qs.theme

Rectangle {
    id: root

    // Единственный слот для контента.
    // Ожидается ровно один top-level child (Layout или Item),
    // который сам решает как позиционировать себя внутри:
    // anchors.centerIn: parent  → секция ужимается по контенту
    // anchors.fill: parent      → секция растягивается снаружи (Layout.fillHeight),
    //                             контент занимает всё доступное место
    default property alias content: inner.data
    property real padding: 12

    radius: 12
    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.glassGroupStart }
        GradientStop { position: 1.0; color: Theme.glassGroupEnd }
    }

    implicitWidth: inner.implicitWidth + padding * 2
    implicitHeight: inner.implicitHeight + padding * 2

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.padding

        implicitWidth: children.length > 0 ? children[0].implicitWidth : 0
        implicitHeight: children.length > 0 ? children[0].implicitHeight : 0
    }
}