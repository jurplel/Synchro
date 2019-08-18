import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0 as Platform
import Qt.labs.settings 1.0

import Synchro.Core 1.0
import "synchrocomponents"
import "synchrostyle"

Window {

    id: window
    visible: true
    width: 1024
    height: 576
    color: Style.backgroundColor
    title: "Synchro"

    SynchronyController {
        id: synchronyController
    }

    Connections {
        target: synchronyController
        onPause: {
            videoObject.isPaused = paused
            videoObject.seek(percentPos, false)
        }
        onSeek: {
            videoObject.seek(percentPos, useKeyframes)
            restartAutohideTimer()
        }
        onUpdateClientList: {
            synchronyPanel.clientListModel = clientList
        }
    }

    Connections {
        target: videoObject
        onIsPausedChanged: restartAutohideTimer()
        onPaused: {
            synchronyController.sendCommand(1, [videoObject.isPaused, videoObject.percentPos])
        }
        onSeeked: synchronyController.sendCommand(2, [percentPos, dragged])
    }


    SynchronyPanel {
        id: synchronyPanel
    }

    Item {
        id: videoContainer
        anchors.fill: parent

        states: [
            State {
            name: "left"
            PropertyChanges {
                target: videoContainer
                anchors.rightMargin: parent.width/4
            }
            }
        ]


        transitions: Transition {
            NumberAnimation {
                target: videoContainer
                properties: "anchors.topMargin,anchors.leftMargin,anchors.rightMargin,anchors.bottomMargin"
                duration: 450
                easing.type: Easing.InOutCubic
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

        VideoObject {
            id: videoObject
            anchors.fill: parent
        }


        MouseArea {
            id: secondaryMouseArea
            hoverEnabled: true
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: mainContextMenu.popup()
            onPositionChanged: restartAutohideTimer()

            OnScreenController {
                id: osc
                videoObject: videoObject
                synchronyController: synchronyController
            }
        }

        Menu {
            id: mainContextMenu
            MenuItem {
                text: "Open..."
//                icon.source: "qrc:/resources/basic_folder.svg"
                onTriggered: fileDialog.open()
            }
            MenuSeparator {

            }
            MenuItem {
                text: "View synchrony panel..."
                onTriggered: {
                    if (videoContainer.state != "left")
                        videoContainer.state = "left"
                    else
                        videoContainer.state = ""
                }
            }
        }
    }



    function restartAutohideTimer() {
        osc.state = ""
        autohideTimer.restart()
    }

    Timer {
        id: autohideTimer
        interval: 650

        onTriggered: {
            if ((!secondaryMouseArea.containsMouse || secondaryMouseArea.mouseY < videoContainer.height-57) && !videoObject.isPaused)
                osc.state = "hidden"
        }
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

    Platform.FileDialog {
        id: fileDialog
        folder: settings.lastFolder
        onAccepted: {
            videoObject.loadFile(fileDialog.file.toString())
            fileDialog.close()
            settings.lastFolder = fileDialog.folder
        }
    }

    Settings {
        id: settings
        property url lastFolder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)
        property string lastName: ""
    }
}
