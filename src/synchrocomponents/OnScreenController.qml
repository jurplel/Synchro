import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "../synchrostyle"

import Synchro.Core 1.0

Item {
    property alias state:oscPanel.state
    property var videoObject
    property var synchronyController

    id: container
    anchors.fill: parent
    clip: true


    Connections {
        target: videoObject
        onMutedChanged: volumeOsc.changeIcon()

        onPausedChanged: {
        if (videoObject.paused)
            playPauseIcon.state = ""
        else
            playPauseIcon.state = "playing"
        }

        onCurrentVolumeChanged: volumeOsc.storedValue = videoObject.currentVolume

        onPercentPosChanged: seekSlider.value = videoObject.percentPos

        onTimePosStringChanged: videoTimeLabel.timePosString = videoObject.timePosString

        onDurationStringChanged: videoTimeLabel.durationString = videoObject.durationString
    }

    Rectangle {
        id: shadow
        anchors.bottomMargin: oscPanel.height+1
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: 5
        opacity: oscPanel.opacity-0.7
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }

        states: State {
            name: "seekbarexpanded"
            when: seekSlider.state != ""
            PropertyChanges {
                target: shadow
                anchors.bottomMargin: oscPanel.height+3
            }
        }

        transitions: Transition {
            reversible: true
            from: ""
            to: "seekbarexpanded"
            NumberAnimation {
                target: shadow
                properties: "anchors.bottomMargin"
                duration: 75
                easing.type: Easing.InOutQuad
            }
        }
    }
    Seekbar {
        id: seekSlider
        transformOrigin: Item.Bottom
        anchors.bottomMargin: oscPanel.height-bottomPadding
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        opacity: oscPanel.opacity
        implicitWidth: 99999999
        z: 1
        onSeek: {
            videoObject.seek(value, dragged)
            synchronyController.sendCommand(SynchronyController.Seek, [value, dragged])
        }
    }

    Item {
        id: oscPanel
        height: 48
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        SynchroBackground {
            sourceItem: videoObject
            sourceRect: Qt.rect(parent.x, parent.y, parent.width, parent.height)
        }

        states: State {
            name: "hidden"
            PropertyChanges {
                target: oscPanel
                opacity: 0
                enabled: false
            }
        }

        transitions: Transition {
            reversible: true
            NumberAnimation {
                target: oscPanel
                properties: "opacity"
                duration: 165
                easing.type: Easing.InOutQuad
            }
        }

        Item {
            id: controlsWrapper
            height: oscPanel.height-12
            anchors.rightMargin: 0
            anchors.fill: parent

            AbstractButton {
                id: playPauseButton
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                onPressed: {
                    var newPausedState = !videoObject.paused
                    videoObject.paused = newPausedState
                    synchronyController.sendCommand(SynchronyController.Pause, [newPausedState, videoObject.percentPos])
                }
                AnimatedSprite {
                    id: playPauseIcon
                    width: parent.height
                    height: parent.width
                    source: "qrc:/resources/play-pause.png"
                    frameWidth: 36
                    frameHeight: 36
                    frameCount: 16
                    frameDuration: 16
                    running: false
                    currentFrame: 15
                    reverse: true
                    onCurrentFrameChanged: if (currentFrame == 15) running = false
                    onStateChanged: {
                        running = false
                        reverse = !reverse
                        currentFrame = 15-currentFrame
                        running = true
                    }

                    states: State {
                            name: "playing"
                        }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            Label {
                id: videoTimeLabel
                property string timePosString;
                property string durationString;

                text: timePosString + "/" + durationString
                anchors.leftMargin: 10
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Image {
                width: 34
                height: 34
                id: icon1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -40
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/resources/music_beginning_button.svg"
            }

            Image {
                width: 34
                height: 34
                id: icon2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 40
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/resources/music_end_button.svg"
            }

            AbstractButton {
                id: volumeButton
                width: 22
                height: 22
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onPressed: videoObject.muted = !videoObject.muted

                Image {
                    id: volumeIcon
                    width: parent.width
                    height: parent.height
                    source: "qrc:/resources/music_volume_up.svg"

                    states: [
                        State {
                            name: "low"
                            PropertyChanges {
                                target: volumeIcon
                                source: "qrc:/resources/music_volume_down.svg"
                            }
                        },
                        State {
                            name: "mute"
                            PropertyChanges {
                                target: volumeIcon
                                source: "qrc:/resources/music_mute.svg"
                            }
                        }
                    ]
                }

                MouseArea {
                    id: volumeIconMouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        volumeOsc.state = "revealed"
                        volumeAutohideTimer.restart()
                    }
                }
            }
        }
    }
    Timer {
        id: volumeAutohideTimer
        interval: 500
        onTriggered: {
            if (!volumeIconMouseArea.containsMouse && !volumeOsc.containsMouse)
                volumeOsc.state = ""
        }
    }

    VolumeOsc {
        id: volumeOsc

        onVolumeChanged: changeIcon()

        function changeIcon()
        {
            if (videoObject.muted || value < 1)
                volumeIcon.state = "mute"
            else if (value > 50)
                volumeIcon.state = ""
            else
                volumeIcon.state = "low"
        }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
