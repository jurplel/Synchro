import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0 as Platform


import Synchro.Core 1.0
import "synchrocomponents"


Window {

    id: window
    visible: true
    width: 640
    height: 480
    color: "#000"
    title: "Synchro"

    VideoObject {
        id: videoObject
        anchors.fill: parent
    }

    SynchronyController {
        id: synchronyController
    }

    Connections {
        target: synchronyController
        onPause: {
            videoObject.paused = !videoObject.paused
            videoObject.seek(percentPos, false)
        }
        onSeek: videoObject.seek(percentPos, useKeyframes)
    }

    Connections {
        target: videoObject
        onPausedChanged: restartAutohideTimer()
    }

    function restartAutohideTimer() {
        osc.state = ""
        autohideTimer.restart()
    }

    Timer {
        id: autohideTimer
        interval: 500

        onTriggered: {
            if ((!secondaryMouseArea.containsMouse || secondaryMouseArea.mouseY < window.height-57) && !videoObject.paused)
                osc.state = "hidden"
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
}
