import QtQuick
import qs.singletons
import qs.components

StyleText {
    text: Qt.formatDateTime(Clock.time, "hh\nmm")
    fontWeight: Font.DemiBold
    onClicked: console.log("Clock clicked") // TODO: открыть центральный попап (календарь/дата/погода + вкладка таймеров)
}