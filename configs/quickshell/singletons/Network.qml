pragma Singleton
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    property bool isEnabled: Networking.wifiEnabled

    property var wifi: {
        return Networking.devices.values.find(dev => dev.type === 1)
    }

    property var network: {
        if (!wifi?.networks) return null
        return wifi.networks.values.find(net => net.connected)
    }

    property real signalStrength: network?.signalStrength ?? 0
}