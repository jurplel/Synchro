import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import Qt.labs.platform 1.0 as Platform
import Qt.labs.settings 1.0

import Synchro.Core 1.0
import "synchrocomponents"
import "synchrostyle"
import "synchroutil"

Window {

    id: window
    visible: true
    width: 1024
    height: 576
    color: Style.backgroundColor
    title: {
        if (NIGHTLY) {
            return "Synchro Nightly"
        } else {
            return "Synchro"
        }
    }

    Shortcuts {
    }

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
        }
        onConnected: {
            videoObject.pause(true)
        }
    }

    property var allTrackMenuItems

    Connections {
        target: videoObject
        onIsPausedChanged: restartAutohideTimer()
        onPaused: {
            synchronyController.sendCommand(1, [videoObject.isPaused, videoObject.percentPos])
        }
        onSeeked: {
            if (synchronize)
                synchronyController.sendCommand(2, [percentPos, dragged])

            restartAutohideTimerSeek();
        }
        onTrackListsUpdated: {
            if (window.allTrackMenuItems) {
                window.allTrackMenuItems.forEach(function(item) {
                    item.destroy()
                })
            }
            allTrackMenuItems = []
            for (var i = 0; i < videoObject.videoTrackList.length; i++) {
                var item = Qt.createQmlObject('import QtQuick 2.10; import QtQuick.Controls 2.3; import "synchrostyle"; MenuItem { text: "'+ videoObject.videoTrackList[i] +'"; onTriggered: videoObject.setVideoTrack(' + (i) + ')}', videoTracksMenu)
                allTrackMenuItems.push(item)
                videoTracksMenu.addItem(allTrackMenuItems[allTrackMenuItems.length-1])
            }

            for (var i = 0; i < videoObject.audioTrackList.length; i++) {
                var item = Qt.createQmlObject('import QtQuick 2.10; import QtQuick.Controls 2.3; import "synchrostyle"; MenuItem { text: "'+ videoObject.audioTrackList[i] +'"; onTriggered: videoObject.setAudioTrack(' + (i) + ')}', audioTracksMenu)
                allTrackMenuItems.push(item)
                audioTracksMenu.addItem(allTrackMenuItems[allTrackMenuItems.length-1])
            }

            for (var i = 0; i < videoObject.subTrackList.length; i++) {
                var item = Qt.createQmlObject('import QtQuick 2.10; import QtQuick.Controls 2.3; import "synchrostyle"; MenuItem { text: "'+ videoObject.subTrackList[i] +'"; onTriggered: videoObject.setSubTrack(' + (i) + ')}', subTracksMenu)
                allTrackMenuItems.push(item)
                subTracksMenu.addItem(allTrackMenuItems[allTrackMenuItems.length-1])
            }
            window.allTrackMenuItems = allTrackMenuItems
        }
        onFileChanged: {
            synchronyController.sendCommand(5, [videoObject.currentFileSize, videoObject.duration, videoObject.currentFileName])
        }
        onCurrentFileSizeChanged: {
            console.log("Current file size changed")
            synchronyController.sendCommand(5, [videoObject.currentFileSize, videoObject.duration, videoObject.currentFileName])
        }
    }


    SynchronyPanel {
        id: synchronyPanel
    }

    PreferencesPanel {
        id: preferencesPanel
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
            },
            State {
            name: "right"
            PropertyChanges {
                target: videoContainer
                anchors.leftMargin: parent.width/3
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
                    videoObject.currentVolume += 5
                else
                    videoObject.currentVolume -= 5
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
            Menu {
                id: videoTracksMenu
                title: "Video Track"
            }
            Menu {
                id: audioTracksMenu
                title: "Audio Track"
            }
            Menu {
                id: subTracksMenu
                title: "Subtitle Track"
            }
            MenuSeparator {
                
            }
            MenuItem {
                text: "Synchrony panel"
                onTriggered: {
                    if (videoContainer.state != "left")
                        videoContainer.state = "left"
                    else
                        videoContainer.state = ""
                }
            }
            MenuItem {
                text: "Preferences"
                onTriggered: {
                    if (videoContainer.state != "right")
                        videoContainer.state = "right"
                    else
                        videoContainer.state = ""
                }
            }
        }
    }



    function restartAutohideTimer() {
        osc.state = ""
        autohideTimer.restart()
        secondaryMouseArea.cursorShape = Qt.ArrowCursor
    }

    function restartAutohideTimerSeek() {
        if (osc.state == "hidden")
            osc.state = "seek"

        autohideTimer.restart()
        secondaryMouseArea.cursorShape = Qt.ArrowCursor
    }

    Timer {
        id: autohideTimer
        interval: 650

        onTriggered: {
            if ((!secondaryMouseArea.containsMouse || secondaryMouseArea.mouseY < videoContainer.height-57) && !videoObject.isPaused)
            {
                osc.state = "hidden"
                secondaryMouseArea.cursorShape = Qt.BlankCursor
            }
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
        property string name: "Rusty Shackleford"

        property bool volumeBoost: false
        onVolumeBoostChanged: {
            var newMaxVolume = volumeBoost ? 200 : 100;
            videoObject.maxVolume = newMaxVolume;
            if (videoObject.currentVolume > 100) {
                videoObject.currentVolume = 100;
            }
        }
    }
}
