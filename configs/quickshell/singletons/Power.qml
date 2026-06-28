pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    // Battery
    property real batteryLevel: UPower.displayDevice.percentage * 100
    property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging
    property bool isFull: UPower.displayDevice.state === UPowerDeviceState.FullyCharged
    property bool onAC: isCharging || isFull
    // Потребление / Зарядка в Ваттах
    property real watts: UPower.displayDevice.energyRate 

    // Время до разрядки (в секундах)
    property real timeToEmpty: UPower.displayDevice.timeToEmpty 

    // Время до полной зарядки (в секундах)
    property real timeToFull: UPower.displayDevice.timeToFull
    
    // Brightness
    property int brightness: 0

    // Process {
    //     id: initProc
    //     command: ["brightnessctl", "g", "&&", "brightnessctl", "m"]
    //     running: true
    //     stdout: SplitParser {
    //         onRead: data => {
    //             const parts = data.split(" ");
    //             const current = parseInt(parts[0]);
    //             const max = parseInt(parts[1]);
    //             root.brightness = current / max;
    //             console.log(parts)
    //         }
    //     }
    // }
}