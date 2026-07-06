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
            startY: -r
            fillColor: Theme.glassContainer
            strokeColor: Theme.glassContainerBorder
            strokeWidth: 1
            PathQuad { relativeX:  r; relativeY: r; relativeControlX:  0; relativeControlY: r }
            PathQuad { relativeX:  r; relativeY: r; relativeControlX:  r; relativeControlY: 0 }
            PathLine { relativeX: 0; relativeY: outer.height + pad * 2 - r}
            PathLine { relativeX: -width; relativeY: 0}
        }
    }

    Column {
        id: outer
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4
        
        TrayWidget {}
        Item {
            width: Theme.sideBarWidth
            height: inner.height + pad * 2

            Shape {
                preferredRendererType: Shape.CurveRenderer
                anchors.fill: parent
                ShapePath {
                    startY: -r
                    fillGradient: LinearGradient {
                        x1: 0; y1: 0
                        x2: 0; y2: parent.height
                        GradientStop { position: 0.0; color: Qt.alpha(Colors.palette.surface1, 0.55) }
                        GradientStop { position: 1.0; color: Qt.alpha(Colors.palette.surface0, 0.40) }
                    }
                    strokeColor: Theme.glassGroupBorder
                    strokeWidth: 1

                    PathQuad { relativeX:  r; relativeY: r; relativeControlX:  0; relativeControlY: r }
                    PathQuad { relativeX:  r; relativeY: r; relativeControlX:  r; relativeControlY: 0 }
                    PathLine { relativeX: 0; relativeY: inner.height + pad * 2 - r}
                    PathLine { relativeX: -width; relativeY: 0}
                }
            }

            Column {
                id: inner
                anchors.bottom: parent.bottom
                anchors.bottomMargin: pad
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0

                KeyboardWidget {}
                NetworkWidget {}
                BluetoothWidget {}
                VolumeWidget {}
                PowerWidget {}
            }
        }
    }
}