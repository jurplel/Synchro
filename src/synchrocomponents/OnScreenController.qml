import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "../synchrostyle"

Rectangle {
    property alias value:seekSlider.value
    property alias state:oscControls.state
    property var videoObject
    property bool paused: true
    property bool muted: false

    id: container
    anchors.fill: parent
    border.width: 0
    color: "#00000000"
    onMutedChanged: {
    if (muted)
        volumeIcon.state = "mute"
    else
        volumeSlider.onValueChanged()
    }

    onPausedChanged: {
    if (paused)
        playPauseIcon.state = ""
    else
        playPauseIcon.state = "playing"
    }

    Timer {
        id: volumeAutohideTimer
        interval: 500
        onTriggered: {
            if (!volumeIconMouseArea.containsMouse && !volumeMouseArea.containsMouse)
                oscVolume.state = ""
        }
    }

    Rectangle {
        id: oscVolume
        width: 42
        height: 135
        color: "#00000000"
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

        Slider {
            id: volumeSlider
            anchors.fill: parent
            anchors.margins: 8
            orientation: Qt.Vertical
            value: 100
            to: 100
            onValueChanged: {
                videoObject.setProperty("volume", value)
                if (value > 50)
                    volumeIcon.state = ""
                else if (value < 1)
                    volumeIcon.state = "mute"
                else
                    volumeIcon.state = "low"
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

    Rectangle {
        id: oscControls
        height: 48
        anchors.right: parent.right
        anchors.left: parent.left
        border.width: 0
        anchors.bottom: parent.bottom
        color: "#00000000"

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

        Rectangle {
            id: controlsWrapper
            color: "#00000000"
            height: oscControls.height-12
            anchors.rightMargin: 0
            border.width: 0
            anchors.fill: parent

            AbstractButton {
                id: playPauseButton
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                onPressed: videoObject.pause()
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
                onPressed: videoObject.mute()

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
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
