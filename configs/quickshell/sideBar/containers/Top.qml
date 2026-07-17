import QtQuick
import QtQuick.Shapes
import qs.theme
import qs.sideBar.widgets

Item {
    readonly property int r: width / 2
    readonly property int pad: Theme.containerPadding

    width: Theme.sideBarWidth
    height: outer.height + pad

    Shape {
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: Theme.glassContainer
            strokeColor: Theme.glassBorder
            strokeWidth: 1
            PathLine { relativeX: width; relativeY: 0}
            PathLine { relativeX: 0; relativeY: outer.height + pad - r}
            PathQuad { relativeX: -r; relativeY: r; relativeControlX:  0; relativeControlY: r }
            PathQuad { relativeX: -r; relativeY: r; relativeControlX: -r; relativeControlY: 0 }
        }
    }

    Column {
        id: outer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Item {
            width: Theme.sideBarWidth
            height: inner.height + pad

            Shape {
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: Theme.glassGroup
                    strokeColor: Theme.glassBorder
                    strokeWidth: 1

                    PathLine { relativeX: width; relativeY: 0}
                    PathLine { relativeX:  0; relativeY: inner.height + pad - r}
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
        // AudioWidget {}
    }
}