import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import Synchro.Core 1.0
import "synchroqml"
Window {
    id: window
    visible: true
    width: 640
    height: 480
    color: "#00010f"
    title: "Synchro"

    onWidthChanged: videoObject.resized()

    onHeightChanged: videoObject.resized()

    VideoObject {
        id: videoObject
        anchors.fill: parent
        onUpdateGui: {
            if (seekSlider.pressed)
                return;
            seekSlider.value = currentVideoPos
        }
        onPausedChanged: paused ? playPauseIcon.state = "paused" : playPauseIcon.state = ""

    }

    Timer {
        id: autohideTimer
        interval: 500
        onTriggered: {
            if (!mouseArea.containsMouse || mouseArea.mouseY < window.height-controls.height-8)
            {
                controls.state = "hidden"
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: {
            controls.state = ""
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

        Seekbar {
            id: seekSlider
            anchors.bottomMargin: controls.height
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            Layout.fillWidth: true
            to: 100
            opacity: controls.opacity
            onMoved: videoObject.seek(value)
        }

        Rectangle {
            id: controls
            height: 50
            color: "#000000"
            anchors.right: parent.right
            anchors.left: parent.left
            border.width: 0
            anchors.bottom: parent.bottom

            ShaderEffectSource {
                id: effectSource

                sourceItem: videoObject
                width: parent.width
                height: parent.height
                sourceRect: Qt.rect(controls.x,controls.y, width, height)
            }

            FastBlur{
                anchors.fill: effectSource
                source: effectSource
                radius: 64
            }

            states: [
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: controls
                        opacity: 0
                    }
                }
            ]

            transitions: [
                Transition {
                    reversible: true
                    from: ""
                    to: "hidden"
                    NumberAnimation {
                        target: controls
                        properties: "opacity"
                        duration: 165
                        easing.type: Easing.InOutQuad
                    }
                }
            ]

            Rectangle {
                id: oscControls
                color: "#00000000"
                anchors.topMargin: 11
                anchors.bottomMargin: 11
                anchors.rightMargin: 0
                border.width: 0
                anchors.fill: parent

                AbstractButton {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Image {
                        id: playPauseIcon
                        width: parent.height
                        height: parent.width
                        sourceSize.width: 64
                        sourceSize.height: 64
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/resources/music_play_button.png"
                        states: [
                            State {
                                name: "paused"
                                PropertyChanges {
                                    target: playPauseIcon
                                    source: "qrc:/resources/music_pause_button.png"
                                }
                            }
                        ]
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                    onPressed: videoObject.pause()
                }

                //                Slider {
                //                    id: volumeSlider
                //                    width: 100
                //                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                //                    Layout.preferredWidth: 100
                //                    value: 1.0
                //                    onValueChanged: videoObject.setProperty("volume", (volumeSlider.value*100).toString())
                //                }

                //                Button {
                //                    id: settingsButton
                //                    text: "Settings"
                //                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                //                    onClicked: {

                //                    }
                //                }

                //                Button {
                //                    id: fullscreenButton
                //                    text: "Fullscreen"
                //                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                //                    onClicked: {
                //                        if (window.visibility === 5)
                //                            window.showNormal()
                //                        else
                //                            window.showFullScreen()
                //                    }
                //                }
            }

        }
    }
}
