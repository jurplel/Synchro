import QtQuick 2.9
import QtQuick.Window 2.9

import Synchro.Core 1.0
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.1

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
        onUpdateGui: {
            seekSlider.to = currentVideoLength
            seekSlider.value = currentVideoPos
        }

    }

    Rectangle {
        id: controls
        visible: true
        height: 40
        color: "#b3000000"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        border.width: 0
        anchors.bottom: parent.bottom

        RowLayout {
            id: rowLayout
            anchors.fill: parent

            Button {
                id: playButton
                text: "Pause"
                onClicked: videoObject.command(["cycle", "pause"])
            }


            Slider {
                id: seekSlider
                Layout.fillWidth: true
                value: 0
                onMoved: {
                    console.log(seekSlider.pressed)
                    videoObject.currentVideoPos = seekSlider.value

                }
            }

            Slider {
                id: volumeSlider
                width: 100
                Layout.preferredWidth: 100
                value: 1.0
                onValueChanged: videoObject.setProperty("volume", (volumeSlider.value*100).toString())
            }

            Button {
                id: settingsButton
                text: "Settings"
                onClicked: {

                }
            }

            Button {
                id: fullscreenButton
                text: "Fullscreen"
                onClicked: {
                    if (window.visibility === 5)
                        window.showNormal()
                    else
                        window.showFullScreen()
                }
            }
        }

        Timer {
            id: autohideTimer
            interval: 350
            onTriggered: controls.visible = false
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
