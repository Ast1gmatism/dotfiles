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
    property real watts: UPower.displayDevice.energyRate 
    property real timeToEmpty: UPower.displayDevice.timeToEmpty 
    property real timeToFull: UPower.displayDevice.timeToFull
    
    // ── Brightness ────────────────────────────────────────────────
    property string brightnessDevicePath: ""
    property int brightnessMax: 0
    property bool brightnessReady: false
    property real brightness: 0

    Component.onCompleted: findBacklightDevice.running = true

    Process {
        id: findBacklightDevice
        command: ["bash", "-c", "ls -d /sys/class/backlight/*/ 2>/dev/null | head -n1"]

        stdout: StdioCollector {
            onStreamFinished: {
                const dir = text.trim()
                if (!dir) {
                    console.error("Power: no backlight device found")
                    return
                }
                root.brightnessDevicePath = dir
                readMaxBrightness.command = ["cat", dir + "max_brightness"]
                readMaxBrightness.running = true
            }
        }
    }

    Process {
        id: readMaxBrightness
        stdout: StdioCollector {
            onStreamFinished: {
                const max = parseInt(text.trim())
                if (!isNaN(max) && max > 0) {
                    root.brightnessMax = max
                    brightnessFile.path = root.brightnessDevicePath + "brightness"
                } else {
                    console.error("Power: invalid max_brightness value")
                }
            }
        }
    }

    FileView {
        id: brightnessFile
        path: ""
        watchChanges: true

        function updateValue() {
            reload()
            const raw = parseInt(text().trim())
            if (isNaN(raw) || root.brightnessMax <= 0)
                return

            const normalized = raw / root.brightnessMax
            if (normalized !== root.brightness) {
                root.brightness = normalized
            }
        }

        onLoaded: {
            root.brightnessReady = true
            updateValue()
        }
        onFileChanged: updateValue()
    }

    // ── Запись яркости ───────────────────────────────────────────
    Process {
        id: setBrightnessProc
    }

    function set(val: real) {
        if (!root.brightnessReady || root.brightnessMax <= 0) return

        const clamped = Math.max(0, Math.min(1, val))
        const raw = Math.round(clamped * root.brightnessMax)

        if (setBrightnessProc.running) {
            setBrightnessProc.running = false
        }

        setBrightnessProc.command = ["brightnessctl", "-d", "amdgpu_bl2", "s", raw.toString()]
        setBrightnessProc.running = true
    }
}