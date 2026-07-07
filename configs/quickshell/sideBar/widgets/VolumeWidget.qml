import QtQuick
import qs.singletons
import qs.popups
import qs.components
import qs.theme

Item {
    id: root
    implicitWidth: btn.width
    implicitHeight: btn.height
    
    Component {
        id: volumeContent
        VolumePopup {}
    }
    
    StyleButton {
        id: btn
        iconSource: {
            if (!Volume.audioSink) return ""
            if (Volume.isMuted) return Theme.iconsPath + "volume/mute.svg"
            if (Volume.volume === 0) return Theme.iconsPath + "volume/none.svg"
            if (Volume.volume <= 50) return Theme.iconsPath + "volume/low.svg"
            return Theme.iconsPath + "volume/high.svg"
        }
        onClicked: mainPopup.showAt(volumeContent, root, 10)
    }
}