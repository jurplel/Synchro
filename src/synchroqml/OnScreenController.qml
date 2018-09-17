import QtQuick 2.9
import QtQuick.Window 2.9
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
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                AnimatedImage {
                    id: playPauseIcon
                    width: parent.height
                    height: parent.width
                    source: "qrc:/resources/pause-play.mng"
                    currentFrame: 30
                    playing: false
                    onCurrentFrameChanged: if (currentFrame == 30) playing = false
                    onStateChanged: playing = true
                    states: [
                        State {
                            name: "playing"
                            PropertyChanges {
                                target: playPauseIcon
                                source: "qrc:/resources/play-pause.mng"
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

//            AbstractButton {
//                width: 34
//                height: 34
//                anchors.verticalCenter: parent.verticalCenter
//                anchors.horizontalCenter: parent.horizontalCenter
//                AnimatedImage {
//                    id: fullScreenIcon
//                    width: parent.height
//                    height: parent.width
//                    source: "qrc:/resources/pause-play.mng"
//                    currentFrame: 30
//                    playing: false
//                    onCurrentFrameChanged: if (currentFrame == 30) playing = false
//                    onStateChanged: playing = true
//                    states: [
//                        State {
//                            name: "playing"
//                            PropertyChanges {
//                                target: volumeIcon
//                                source: "qrc:/resources/play-pause.mng"
//                            }
//                        }
//                    ]

//                    MouseArea {
//                        anchors.fill: parent
//                        acceptedButtons: Qt.NoButton
//                        cursorShape: Qt.PointingHandCursor
//                    }
//                }
//                onPressed: videoObject.pause()
//            }

//            Slider {
//                id: volumeSlider
//                width: 100
//                value: 1.0
//                onValueChanged: videoObject.setProperty("volume", (volumeSlider.value*100).toString())
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
