import QtQuick 2.9
import QtQuick.Window 2.9

import Synchro.Core 1.0
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.0

Window {
    id: window
    visible: true
    width: 640
    height: 480
    color: "#00010f"
    title: "Synchro"
    VideoObject {
        id: videoObject
        anchors.fill: parent
        onCurrentVideoLengthChanged: seekSlider.to = currentVideoLength
        onCurrentVideoPosChanged: seekSlider.value = currentVideoPos
    }

    Rectangle {
        id: controls
        visible: false
        height: 40
        color: "#e6000219"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        border.width: 0
        anchors.bottom: parent.bottom

        Timer {
            id: autohideTimer
            interval: 350
            onTriggered: controls.visible = false
        }

        Button {
            id: playButton
            x: 0
            text: "Pause"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: videoObject.command(["cycle", "pause"])
        }

        Slider {
            id: volumeSlider
            x: 504
            width: 100
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            value: 1.0
            onValueChanged: videoObject.setProperty("volume", (volumeSlider.value*100).toString())
        }

        Slider {
            id: seekSlider
            height: 22
            anchors.right: parent.right
            anchors.rightMargin: 120
            anchors.left: parent.left
            anchors.leftMargin: 104
            anchors.verticalCenter: parent.verticalCenter
            value: 0
            onMoved: videoObject.setProperty("playback-time", (seekSlider.value).toString())
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: {
            controls.visible = true
            autohideTimer.restart()
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
                        seekSlider.value = 0.0
                        fileDialog.close()
                    }
                }
            }
            MenuItem {
                text: "Pause"
                onClicked: videoObject.command(["cycle", "pause"])
            }
        }
        acceptedButtons: Qt.RightButton
        onClicked: mainContextMenu.popup()
    }
}
