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
    }

    Rectangle {
        id: controls
        height: 40
        color: "#e6000219"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        border.width: 0
        anchors.bottom: parent.bottom

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
            value: videoObject.getProperty("percent-pos")/100
            onValueChanged: videoObject.setProperty("percent-pos", (seekSlider.value*100).toString())
        }
    }

    MouseArea {
        anchors.fill: parent
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

/*##^## Designer {
    D{i:66;anchors_height:22}D{i:45;anchors_height:40;anchors_width:640}
}
 ##^##*/
