pragma Singleton

import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root
    property var adapter:      Bluetooth.defaultAdapter
    property bool isEnabled:   adapter?.enabled       ?? false
    property bool isScanning:  adapter?.discovering   ?? false
    property bool isConnected: {
        if (!adapter?.devices) return false
        return adapter.devices.values.some(dev => dev.connected)
    }
} 
