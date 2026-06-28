pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    property var audioSink: Pipewire.defaultAudioSink?.audio ?? null

    property int volume: audioSink ? Math.round(audioSink.volume * 100) : 0
    property bool isMuted: audioSink?.muted ?? false
}