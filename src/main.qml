import QtQuick 2.9
import QtQuick.Window 2.2

import Synchro.Core 1.0

Window {

    visible: true
    width: 640
    height: 480
    color: "#00010f"
    title: qsTr("Synchro")

    VideoObject {
        id: video
        anchors.fill: parent
    }
}
