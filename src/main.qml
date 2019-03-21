import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0 as Platform

import Synchro.Core 1.0
import "synchrocomponents"
import "synchrostyle"

Window {

    id: window
    visible: true
    width: 640
    height: 480
    color: Style.backgroundColor
    title: "Synchro"

    SynchronyController {
        id: synchronyController
    }

    Connections {
        target: synchronyController
        onPause: {
            videoObject.paused = paused
            videoObject.seek(percentPos, false)
        }
        onSeek: {
            videoObject.seek(percentPos, useKeyframes)
            restartAutohideTimer()
        }
    }

    Connections {
        target: videoObject
        onPausedChanged: restartAutohideTimer()
    }



    Item {
        id: videoContainer
        anchors.fill: parent

        states: [
            State {
            name: "bottomright"
            PropertyChanges {
                target: videoContainer
                anchors.topMargin: parent.height/3
                anchors.leftMargin: parent.width/3
            }
            },
            State {
            name: "bottomleft"
            PropertyChanges {
                target: videoContainer
                anchors.topMargin: parent.height/3
                anchors.rightMargin: parent.width/3
            }
            },
            State {
            name: "bottomcenter"
            PropertyChanges {
                target: videoContainer
                anchors.topMargin: parent.height/3
                anchors.leftMargin: parent.width/6
                anchors.rightMargin: parent.width/6
            }
            },
            State {
            name: "topcenter"
            PropertyChanges {
                target: videoContainer
                anchors.bottomMargin: parent.height/3
                anchors.leftMargin: parent.width/6
                anchors.rightMargin: parent.width/6
            }
            }
        ]


        transitions: Transition {
            NumberAnimation {
                target: videoContainer
                properties: "anchors.topMargin,anchors.leftMargin,anchors.rightMargin,anchors.bottomMargin"
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            id: primaryMouseArea
            anchors.fill: parent
            onDoubleClicked: if (window.visibility === 5) {window.showNormal()} else {window.showFullScreen()}
            onWheel: {
                if (wheel.angleDelta.y > 0)
                    videoObject.currentVolume += 10
                else
                    videoObject.currentVolume -= 10
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
                videoObject: videoObject
                synchronyController: synchronyController
            }
        }

        Menu {
            id: mainContextMenu
            MenuItem {
                text: "Open..."
                icon.source: "qrc:/resources/basic_folder.svg"
                onTriggered: fileDialog.open()
            }
            MenuItem {
                text: connectDialog.title
                icon.source: "qrc:/resources/basic_server.svg"
                onTriggered: connectDialog.open()
            }
            MenuItem {
                text: "switch corner mode"
                onTriggered: {
                    if (videoContainer.state == "")
                        videoContainer.state = "bottomright"
                    else if (videoContainer.state == "bottomright")
                        videoContainer.state = "bottomleft"
                    else if (videoContainer.state == "bottomleft")
                        videoContainer.state = "bottomcenter"
                    else if (videoContainer.state == "bottomcenter")
                        videoContainer.state = "topcenter"
                    else if (videoContainer.state == "topcenter")
                        videoContainer.state = ""
                }
            }
        }
    }



    function restartAutohideTimer() {
        osc.state = ""
        autohideTimer.restart()
    }

    Timer {
        id: autohideTimer
        interval: 500

        onTriggered: {
            if ((!secondaryMouseArea.containsMouse || secondaryMouseArea.mouseY < videoContainer.height-57) && !videoObject.paused)
                osc.state = "hidden"
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
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)
        onAccepted: {
            videoObject.loadFile(fileDialog.file.toString())
            fileDialog.close()
        }
    }
    Dialog {
        id: connectDialog
        title: "Connect to server..."

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 300
        height: 100
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        TextField {
            id: ipField
        }
        SpinBox {
            id: portField
            x: ipField.width + 10
            width: 70
            to: 65535
            editable: true
        }
        onAccepted: {
            synchronyController.connectToServer(ipField.text, portField.value)
            fileDialog.close()
        }
    }
}
