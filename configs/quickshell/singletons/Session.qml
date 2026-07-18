pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    function lock() {
        Quickshell.execDetached(["loginctl", "lock-session"])
    }

    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"])
    }

    function hibernate() {
        Quickshell.execDetached(["systemctl", "hibernate"])
    }

    function logout() {
        Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"])
    }

    function poweroff() {
        Quickshell.execDetached(["systemctl", "poweroff"])
    }
}