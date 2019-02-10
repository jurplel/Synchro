import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "../synchrostyle"

Rectangle {
    property alias state:oscControls.state
    property var videoObject

    id: container
    anchors.fill: parent
    border.width: 0
    color: "#00000000"
    Connections {
        target: videoObject
        onMutedChanged: volumeSlider.changeIcon()

        onPausedChanged: {
        if (videoObject.paused)
            playPauseIcon.state = ""
        else
            playPauseIcon.state = "playing"
        }

        onCurrentVolumeChanged: volumeSlider.storedValue = videoObject.currentVolume

        onCurrentVideoPosChanged: seekSlider.value = videoObject.currentVideoPos
    }

    Timer {
        id: volumeAutohideTimer
        interval: 500
        onTriggered: {
            if (!volumeIconMouseArea.containsMouse && !volumeMouseArea.containsMouse)
                oscVolume.state = ""
        }
    }

    Seekbar {
        id: seekSlider
        anchors.bottomMargin: oscControls.height
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        to: 100
        opacity: oscControls.opacity
        onMoved: videoObject.seek(value)

        z: -1
    }

    Item {
        id: oscControls
        height: 48
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        SynchroBackground {
            sourceItem: videoObject
            sourceRect: Qt.rect(container.width-parent.width,container.height-parent.height, width, height)
        }

        states: State {
            name: "hidden"
            PropertyChanges {
                target: oscControls
                opacity: 0
                enabled: false
            }
        }

        transitions: Transition {
            reversible: true
            NumberAnimation {
                target: oscControls
                properties: "opacity"
                duration: 165
                easing.type: Easing.InOutQuad
            }
        }

        Item {
            id: controlsWrapper
            height: oscControls.height-12
            anchors.rightMargin: 0
            anchors.fill: parent

            AbstractButton {
                id: playPauseButton
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                onPressed: videoObject.paused = !videoObject.paused
                AnimatedSprite {
                    id: playPauseIcon
                    width: parent.height
                    height: parent.width
                    source: "qrc:/resources/play-pause.png"
                    frameWidth: 36
                    frameHeight: 36
                    frameCount: 16
                    frameSync: true
                    running: false
                    currentFrame: 15
                    reverse: true
                    onCurrentFrameChanged: if (currentFrame == 15) running = false
                    onStateChanged: {
                        reverse = !reverse
                        if (currentFrame == 15)
                            currentFrame = 0
                        else
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
                text: "0:00/0:00"
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
                        oscVolume.state = "revealed"
                        volumeAutohideTimer.restart()
                    }
                }
            }
        }
    }
    Item {
        id: oscVolume
        width: 42
        height: 135
        anchors.rightMargin: -width
        anchors.right: parent.right
        anchors.bottomMargin: oscControls.height
        anchors.bottom: parent.bottom

        SynchroBackground {
            sourceItem: videoObject
            sourceRect: Qt.rect(container.width-parent.width-(-radius),container.height-parent.height-parent.anchors.bottomMargin, width, height)
        }

        states: State {
            name: "revealed"
            PropertyChanges {
                target: oscVolume
                anchors.rightMargin: 0
            }
            PropertyChanges {
                target: seekSlider
                anchors.rightMargin: oscVolume.width-oscVolume.radius
            }
        }

        transitions: Transition {
            reversible: true
            to: "revealed"
            NumberAnimation {
                target: oscVolume
                properties: "anchors.rightMargin"
                duration: 165
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                target: seekSlider
                properties: "anchors.rightMargin"
                duration: 165
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            id: volumeMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onContainsMouseChanged: {
                oscVolume.state = "revealed"
                volumeAutohideTimer.restart()
            }
        }

        Slider {
            property real storedValue: 100
            id: volumeSlider
            anchors.fill: parent
            anchors.margins: 8
            orientation: Qt.Vertical
            to: 100
            value: videoObject.muted ? 0 : storedValue
            onValueChanged: {
                changeIcon()
                oscVolume.state = "revealed"
                volumeAutohideTimer.restart()
            }
            onMoved: { videoObject.currentVolume = value}

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
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
