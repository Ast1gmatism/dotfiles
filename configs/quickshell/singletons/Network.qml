pragma Singleton
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    property bool isEnabled: Networking.wifiEnabled

    property var wifi: {
        return Networking.devices.values.find(dev => dev.type === 1)
        // FIXME: dev.type === 1 магическое число, заменить на enum
    }

    // FIXME: leaks raw Networking objects (wifi, network) to widgets instead of
    // exposing ready-to-use UI state, unlike Power/Volume/Bluetooth singletons.
    // Widget layer shouldn't need to know internal structure of Networking API.
    property var network: {
        if (!wifi?.networks) return null
        return wifi.networks.values.find(net => net.connected)
    }

    property real signalStrength: network?.signalStrength ?? 0
}