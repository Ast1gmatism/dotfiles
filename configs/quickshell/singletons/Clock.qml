pragma Singleton

import Quickshell

Singleton {
    id: root
    property var time: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}