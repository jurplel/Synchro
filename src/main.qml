import QtQuick 2.9
import QtQuick.Window 2.9

import Synchro.Core 1.0
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.0

Window {
    visible: true
    width: 640
    height: 480
    color: "#00010f"
    title: "Synchro"

    VideoObject {
        id: videoObject
        anchors.fill: parent
        MouseArea {
            Menu {
                id: mainContextMenu
                MenuItem {
                    text: "Open file"
                    onClicked: fileDialog.open()
                    //onClicked: videoObject.command(["loadfile", "test.avi"])
                }
            }
            acceptedButtons: Qt.RightButton
            anchors.fill: parent
            onClicked: mainContextMenu.popup()
        }
    }

    FileDialog {
        id: fileDialog
        title: "Pick a file, boi"
        folder: shortcuts.home
        onAccepted: {
            videoObject.command(["loadfile", fileDialog.fileUrl.toString()])
            fileDialog.close()
            console.log(fileDialog.fileUrl)
        }
    }
}
