import QtQuick
import QtQuick.Shapes
import qs.theme
import qs.sideBar.widgets

Item {
    readonly property int r: width / 2
    readonly property int pad: Theme.containerPadding

    width: Theme.sideBarWidth
    height: inner.height + pad * 2

    Shape {
        preferredRendererType: Shape.CurveRenderer
        anchors.fill: parent
        ShapePath {
            fillColor: Theme.backgroundColor
            strokeColor: "transparent"
            PathLine { relativeX: width; relativeY: 0}
            PathLine { relativeX: 0; relativeY: inner.height + pad * 2 - r}
            PathQuad { relativeX: -r; relativeY: r; relativeControlX:  0; relativeControlY: r }
            PathQuad { relativeX: -r; relativeY: r; relativeControlX: -r; relativeControlY: 0 }
        }
    }

     

    Column {
        id: inner
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0
        MenuWidget {}
        WorkspacesWidget {}
    }
}