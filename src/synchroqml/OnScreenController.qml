import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Rectangle {
    property alias value:seekSlider.value
    property alias state:controls.state
    property var videoObject
    property bool paused: true

    id: container
    height: controls.height+seekSlider.height
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    color: "#00000000"
    anchors.bottom: parent.bottom
    onPausedChanged: paused ? playPauseIcon.state = "" : playPauseIcon.state = "playing"

    Seekbar {
        id: seekSlider
        anchors.bottomMargin: controls.height
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        to: 100
        opacity: controls.opacity
        onMoved: videoObject.seek(value)
    }

    Rectangle {
        id: controls
        height: 48
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
            sourceRect: Qt.rect(container.x,container.y+seekSlider.height, width, height)
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
            anchors.fill: parent
            color: "#33000000"
            border.width: 0
        }

        Rectangle {
            id: oscControls
            color: "#00000000"
            height: controls.height-12
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
                    onCurrentFrameChanged: if (currentFrame ==15) running = false
                    onStateChanged: {
                        reverse = !reverse
                        if (currentFrame == 15)
                            currentFrame = 0
                        else
                            currentFrame = 15-currentFrame
                        running = true
                    }

                    states: [
                        State {
                            name: "playing"
                        }
                    ]

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
                width: 32
                height: 32
                id: icon1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -40
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/resources/music_beginning_button.svg"
            }

            ColorOverlay
            {
                anchors.fill: icon1
                source: icon1
                color: "#FFFFFF"
            }

            Image {
                width: 32
                height: 32
                id: icon2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 40
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/resources/music_end_button.svg"
            }

            ColorOverlay
            {
                anchors.fill: icon2
                source: icon2
                color: "#FFFFFF"
            }

            Image {
                width: 22
                height: 22
                id: volumeIcon
                anchors.rightMargin: 46
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/resources/music_volume_up.svg"
            }

            ColorOverlay
            {
                anchors.fill: volumeIcon
                source: volumeIcon
                color: "#FFFFFF"
            }

            Image {
                width: 22
                height: 22
                id: icon3
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/resources/arrows_expand.svg"
            }

            ColorOverlay
            {
                anchors.fill: icon3
                source: icon3
                color: "#FFFFFF"
            }
//            Slider {
//                id: volumeSlider
//                width: 100
//                anchors.verticalCenter: parent.verticalCenter
//                anchors.right: parent.right
//                value: 100
//                from: 0
//                to: 100
//                onValueChanged: videoObject.setProperty("volume", volumeSlider.value)
//            }

    //        //                Button {
    //        //                    id: settingsButton
    //        //                    text: "Settings"
    //        //                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    //        //                    onClicked: {

    //        //                    }
    //        //                }

    //        //                Button {
    //        //                    id: fullscreenButton
    //        //                    text: "Fullscreen"
    //        //                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    //        //                    onClicked: {
    //        //                        if (window.visibility === 5)
    //        //                            window.showNormal()
    //        //                        else
    //        //                            window.showFullScreen()
    //        //                    }
    //        //                }
        }

    }
}
