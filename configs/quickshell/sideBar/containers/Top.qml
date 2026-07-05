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
        anchors.fill: parent
        ShapePath {
            fillColor: Theme.glassContainer
            strokeColor: Theme.glassContainerBorder
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
        spacing: 0

        Item {
            width: Theme.sideBarWidth
            height: inner.height + pad * 2

            Shape {
                preferredRendererType: Shape.CurveRenderer
                anchors.fill: parent
                ShapePath {
                    fillGradient: LinearGradient {
                        x1: 0; y1: 0
                        x2: 0; y2: parent.height
                        GradientStop { position: 0.0; color: Theme.glassGroupStart }
                        GradientStop { position: 1.0; color: Theme.glassGroupEnd }
                    }
                    strokeColor: Theme.glassGroupBorder
                    strokeWidth: 1

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
        AudioWidget {}
    }
}