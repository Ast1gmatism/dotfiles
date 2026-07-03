pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    // ── Battery ────────────────────────────────────────────────
    readonly property real batteryLevel: UPower.displayDevice.percentage * 100
    readonly property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging
    readonly property bool isFull: UPower.displayDevice.state === UPowerDeviceState.FullyCharged
    readonly property bool onAC: isCharging || isFull
    readonly property real watts: UPower.displayDevice.changeRate 
    readonly property real timeToEmpty: UPower.displayDevice.timeToEmpty 
    readonly property real timeToFull: UPower.displayDevice.timeToFull

    // UI форматирование
    readonly property string timeStr: isFull ? "∞" : formatTime(isCharging ? timeToFull : timeToEmpty)
    readonly property string wattsStr: watts < 0.1 ? "—" : (isCharging ? "+" : "-") + watts.toFixed(1) + "W"

    function formatTime(seconds) {
        if (seconds <= 0) return "—"
        const h = Math.floor(seconds / 3600)
        const m = Math.floor((seconds % 3600) / 60)
        return h > 0 ? `~${h}:${m.toString().padStart(2, "0")}` : `~${m}m`
    }

    // Профили энергопотребления
    readonly property string activeProfile: {
        if (PowerProfiles.profile === PowerProfile.PowerSaver) return "saver"
        if (PowerProfiles.profile === PowerProfile.Performance) return "perf"
        return "balanced"
    }

    function setProfile(id: string) {
        if (id === "saver") PowerProfiles.profile = PowerProfile.PowerSaver
        else if (id === "perf") PowerProfiles.profile = PowerProfile.Performance
        else PowerProfiles.profile = PowerProfile.Balanced
    }

    // ── Brightness ────────────────────────────────────────────────
    readonly property real brightness: _brightness.value
    readonly property bool brightnessReady: _brightness.ready

    QtObject {
        id: _brightness
        property string devicePath: ""
        property int max: 0
        property bool ready: false
        property real value: 0
    }

    Component.onCompleted: {
        _findDevice.running = true
        console.log("PowerProfile enum values:")
        console.log("  PowerSaver:", PowerProfile.PowerSaver)
        console.log("  Balanced:", PowerProfile.Balanced)
        console.log("  Performance:", PowerProfile.Performance)
        console.log("Current profile:", PowerProfiles.profile)
    }

    Process {
        id: _findDevice
        command: ["bash", "-c", "ls -d /sys/class/backlight/*/ 2>/dev/null | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const dir = text.trim()
                if (!dir) { console.error("Power: no backlight device"); return }
                _brightness.devicePath = dir
                _readMax.command = ["cat", dir + "max_brightness"]
                _readMax.running = true
            }
        }
    }

    Process {
        id: _readMax
        stdout: StdioCollector {
            onStreamFinished: {
                const max = parseInt(text.trim())
                if (isNaN(max) || max <= 0) { console.error("Power: invalid max_brightness"); return }
                _brightness.max = max
                _monitor.path = _brightness.devicePath + "brightness"
            }
        }
    }

    FileView {
        id: _monitor
        path: ""
        watchChanges: true

        function read() {
            const raw = parseInt(text().trim())
            if (isNaN(raw) || _brightness.max <= 0) return
            _brightness.value = raw / _brightness.max
            _brightness.ready = true
        }

        onLoaded: read()
        onFileChanged: { reload(); read() }
    }

    Process { id: _setter }

    function set(val: real) {
        if (!brightnessReady || _brightness.max <= 0) return
        const raw = Math.round(Math.max(0, Math.min(1, val)) * _brightness.max)
        if (_setter.running) _setter.running = false
        const device = _brightness.devicePath.split("/").filter(s => s.length > 0).pop()
        _setter.command = ["brightnessctl", "-d", device, "s", raw.toString()]
        _setter.running = true
    }

    // ── Redshift (hyprsunset) ────────────────────────────────
    property bool redshiftEnabled: false
    property int redshiftTemp: 3500

    Process {
        id: _hyprsunsetDaemon
        command: ["hyprsunset"]
        running: true

        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length)
                console.warn("hyprsunset daemon:", text)
        }
    }

    Process {
        id: _redshiftCtl
        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length)
                console.warn("hyprctl hyprsunset:", text)
        }
    }

    function _applyRedshift() {
        _redshiftCtl.command = root.redshiftEnabled
            ? ["hyprctl", "hyprsunset", "temperature", root.redshiftTemp.toString()]
            : ["hyprctl", "hyprsunset", "identity"]
        _redshiftCtl.running = true
    }

    onRedshiftEnabledChanged: _applyRedshift()
}