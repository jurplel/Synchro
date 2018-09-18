import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.0

import Synchro.Core 1.0
import "synchroqml"
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
        onUpdateGui: {
            if (osc.pressed)
                return;
            osc.value = currentVideoPos
        }
        onPausedChanged: osc.paused = paused
    }

    Timer {
        id: autohideTimer
        interval: 500
        onTriggered: {
            if ((!mouseArea.containsMouse || mouseArea.mouseY < window.height-osc.height) && !videoObject.paused)
            {
                osc.state = "hidden"
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
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
        acceptedButtons: Qt.RightButton
        onClicked: mainContextMenu.popup()
    }
}
