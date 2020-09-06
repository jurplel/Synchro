import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import Synchro.Core 1.0
import "../synchrostyle"

Item {
    id: preferencesPanel 
    height: parent.height
    width: parent.width/3
    TabBar {
        id: tabBar

        width: parent.width
        
        TabButton {
            text: "General"
        }
        TabButton {
            text: "Video"
        }
        TabButton {
            text: "Synchrony"
        }
        TabButton {
            text: "mpv.conf"
        }
    }
    SwipeView {
        id: swipe
        currentIndex: tabBar.currentIndex

        anchors.fill: parent
        anchors.topMargin: 40

        Item {
            id: firstPage
            Column {
                padding: 10
                Row {
                    spacing: 10
                    Switch {
                        id: volumeBoostSwitch
                        text: qsTr("Volume Boost")
                        checked: settings.volumeBoost
                        onToggled: {
                            settings.volumeBoost = volumeBoostSwitch.checked;
                        }
                    }
                }
            }
        }

        Item {
            id: secondPage
        }

        Item {
            id: thirdPage
            Column {
                padding: 10
                Row {
                    spacing: 10
                    Text {
                        text: "Name:"
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 16
                    }
                    TextField {
                        id: nameField
                        width: 200
                        text: settings.name
                        onEditingFinished: {
                            settings.name = nameField.text;
                            synchronyController.sendCommand(4, [nameField.text]);
                        }
                    }
                }
            }
        }
        Item {
            id: fourthPage

            ConfHandler {
                id: confHandler
                vidObj: videoObject
            }
            ColumnLayout {
                width: parent.width
                anchors.bottom: parent.bottom
                anchors.top: parent.top

                ScrollView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    TextEdit {
                        id: confEditor
                        width: fourthPage.width
                        height: fourthPage.height
                        text: confHandler.getConf()
                        selectByMouse: true
                        onEditingFinished: {
                            confHandler.saveMpvConf(confEditor.textDocument);
    //                            settings.conf = nameField.text;
                        }
                        color: "#FFFFFF"

                        Component.onCompleted: confHandler.setSyntaxHighlighter(confEditor.textDocument);
                    }
                }
                Row {
                    Layout.fillWidth: true
                    Button {
                        id: refreshButton
                        width: parent.width/2
                        text: "Refresh"
                        onPressed: {
                            confHandler.readMpvConf();
                            confEditor.text = confHandler.getConf();
                        }
                    }

                    Button {
                        id: applyButton
                        width: parent.width/2
                        text: "Apply"
                        onPressed: confEditor.editingFinished();
                    }
                }
            }
        }
    }
}
