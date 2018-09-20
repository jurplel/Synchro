import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.0

import Synchro.Core 1.0
import "synchrocomponents"

Window {
    id: window
    visible: true
    width: 640
    height: 480
    color: "#000"
    title: "Synchro"

    onWidthChanged: videoObject.resized()
    onHeightChanged: videoObject.resized()

    VideoObject {
        id: videoObject
        anchors.fill: parent
    }

    Timer {
        id: autohideTimer
        interval: 500
        onTriggered: {
            if ((!secondaryMouseArea.containsMouse || secondaryMouseArea.mouseY < window.height-56) && !videoObject.paused)
                osc.state = "hidden"
        }
    }

    MouseArea {
        id: primaryMouseArea
        anchors.fill: parent
        onDoubleClicked: if (window.visibility === 5) {window.showNormal()} else {window.showFullScreen()}
        onWheel: {
            if (wheel.angleDelta.y > 0)
                videoObject.volume(videoObject.currentVolume+10)
            else
                videoObject.volume(videoObject.currentVolume-10)
        }
    }

    MouseArea {
        id: secondaryMouseArea
        hoverEnabled: true
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: mainContextMenu.popup()
        onPositionChanged: {
            osc.state = ""
            autohideTimer.restart()
        }

        OnScreenController {
            id: osc
            videoObject: videoObject
        }

        Menu {
            id: mainContextMenu
            MenuItem {
                text: "Open file"
                onClicked: fileDialog.open()
                FileDialog {
                    id: fileDialog
                    title: "Pick a file"
                    folder: shortcuts.home
                    onAccepted: {
                        videoObject.command(["loadfile", fileDialog.fileUrl.toString()])
                        osc.value = 0.0
                        fileDialog.close()
                    }
                }
            }
            MenuItem {
                text: "Pause"
                onClicked: videoObject.pause()
            }
        }
    }
}
