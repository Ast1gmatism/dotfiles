pragma Singleton
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    // ──────────────────────────────────────────────────────────
    readonly property var _wifi: Networking.devices.values.find(
        dev => dev.type === DeviceType.Wifi
    ) ?? null

    readonly property var _network: _wifi?.networks?.values?.find(
        net => net.connected
    ) ?? null

    // ── Публичный UI-контракт ─────────────────────────────────
    readonly property bool hasAdapter:  _wifi !== null
    readonly property bool isEnabled:   Networking.wifiEnabled
    readonly property bool isConnected: _network !== null
    readonly property bool isScanning:  _wifi?.scannerEnabled ?? false

    readonly property string networkName:    _network?.name           ?? ""
    readonly property real   signalStrength: _network?.signalStrength ?? 0.0

    // ── Управление сканером ───────────────────────────────────
    function startScan() {
        if (_wifi) _wifi.scannerEnabled = true
    }

    function stopScan() {
        if (_wifi) _wifi.scannerEnabled = false
    }
}