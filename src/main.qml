import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0 as Platform


import Synchro.Core 1.0
import "synchrocomponents"

Window {
    id: window
    visible: true
    width: 640
    height: 480
    color: "#000"
    title: "Synchro"

    VideoObject {
        id: videoObject
        anchors.fill: parent
    }

    Timer {
        id: autohideTimer
        interval: 500
        onTriggered: {
            if ((!secondaryMouseArea.containsMouse || secondaryMouseArea.mouseY < window.height-57) && !videoObject.paused)
                osc.state = "hidden"
        }
    }

    MouseArea {
        id: primaryMouseArea
        anchors.fill: parent
        onDoubleClicked: if (window.visibility === 5) {window.showNormal()} else {window.showFullScreen()}
        onWheel: {
            if (wheel.angleDelta.y > 0)
                videoObject.currentVolume += 10
            else
                videoObject.currentVolume -= 10
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

        Platform.MenuBar {
            Platform.Menu {
                title: "File"
                Platform.MenuItem {
                    text: "Open..."
                    iconName: "document-open"
                    onTriggered: fileDialog.open()
                }
            }
        }

        Menu {

            id: mainContextMenu
            MenuItem {
                text: "Open..."
                icon.source: "qrc:/resources/basic_folder.svg"
                onTriggered: fileDialog.open()
            }
        }

        Platform.FileDialog {
            id: fileDialog
            folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)
                onAccepted: {
                    videoObject.loadFile(fileDialog.file.toString());
                    fileDialog.close()
                }
        }
    }
}
