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

        ShapePath {
            fillColor: Theme.glassContainer
            strokeColor: Theme.glassBorder
            strokeWidth: 1
            startY: -r
            PathQuad { relativeX:  r; relativeY: r; relativeControlX:  0; relativeControlY: r }
            PathQuad { relativeX:  r; relativeY: r; relativeControlX:  r; relativeControlY: 0 }
            PathLine { relativeX: 0; relativeY: inner.height + pad * 2 - 2 * r}
            PathQuad { relativeX: -r; relativeY: r; relativeControlX:  0; relativeControlY: r }
            PathQuad { relativeX: -r; relativeY: r; relativeControlX: -r; relativeControlY: 0 }
        }
    }

    ClockWidget {
        id: inner
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}