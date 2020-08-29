import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import Synchro.Core 1.0
import "../synchrostyle"

Item {
    id: synchronyPanel

    anchors.right: parent.right
    height: parent.height
    width: parent.width/4


    ClientListModel { 
        id: clientListModel
        onDataChanged: console.log("changed");
    }

    Connections {
        target: synchronyController
        onUpdateClientList: {
            clientListModel.updateClientList(clientList);
        }
        onConnected: {
            stack.push(connectedScreen);
            synchronyController.sendCommand(4, [settings.name]);
            synchronyController.sendCommand(5, [videoObject.currentFileSize, videoObject.duration, videoObject.currentFileName]);
        }
        onDisconnected: {
            clientListModel.updateClientList("");
            stack.pop();
        }
    }


    StackView {
        id: stack
        initialItem: connectScreen
        anchors.fill: parent
    }

    function connectToServer(ip) {
        let stringList = ip.split(":");
        if (stringList.length > 1)
        {
            synchronyController.connectToServer(stringList[0], stringList[1]);
        }
    }

    Component {
        id: connectScreen

        ColumnLayout {
            ListView {
                id: serverList

                Layout.fillHeight: true
                Layout.fillWidth: true

                model: ServerListModel {}

                delegate: Item {
                    height: 32
                    width: parent.width

                    property var ipAddress: ip

                    Text {
                        color: "white"
                        font.pointSize: 12
                        text: name
                    }

                    Text {
                        topPadding: 16
                        color: "gray"
                        text: ip
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: serverList.currentIndex = index
                        onDoubleClicked: connectToServer(parent.ipAddress)
                    }
                }

                header: Item {
                    height: 30
                    width: parent.width
                    Text {
                        color: "white"
                        text: "Servers"
                        font.pointSize: 20
                    }
                }

                highlight: Component {
                    id: highlight
                    Rectangle {
                        width: 180; height: 40
                        color: Style.accentColorMiddle
                        radius: 1
                        y: serverList.currentItem.y
                        Behavior on y {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutExpo
                            }
                        }
                    }
                }
            }
            Row {
                height: 40
                Layout.fillWidth: true
                Button {
                    id: directConnectButton
                    text: "Direct Connect"
                    width: parent.width/2
                    onPressed: stack.push(directConnectScreen)
                }
                Button {
                    id: connectButton
                    text: "Connect"
                    width: parent.width/2
                    onPressed: connectToServer(serverList.currentItem.ipAddress)
                }
            }
        }
    }
    
    Component {
        id: directConnectScreen
        Item {
            ColumnLayout {
                width: parent.width
                anchors.bottom: parent.bottom

                Text {
                    color: "white"
                    text: "Direct Connect"
                    font.pointSize: 20
                }

                TextField {
                    id: ipField
                    Layout.fillWidth: true
                    text: "0.0.0.0:32019"
                }
                Row {
                    Layout.fillWidth: true
                    Button {
                        id: directConnectButton
                        width: parent.width/2
                        text: "Back"
                        onPressed: stack.pop();
                    }

                    Button {
                        id: connectButton
                        width: parent.width/2
                        text: "Connect"
                        onPressed: connectToServer(ipField.text)
                    }
                }
            }
        }
    }

    Component {
        id: connectedScreen

        ColumnLayout {
            ListView {
                id: listOfClients
                
                Layout.fillHeight: true
                Layout.fillWidth: true

                model: clientListModel

                delegate: Column {
                    width: parent.width

                    Text {
                        id: nameField
                        color: "white"
                        font.pointSize: 12
                        text: name
                    }

                    Text {
                        id: fileNameField
                        width: parent.width
                        color: "gray"
                        text: fileName === "" ? "No file loaded" : fileName
                        wrapMode: Text.Wrap
                    }
                    Text {
                        width: parent.width
                        color: "gray"
                        text: fileSize + " | " + fileDuration
                        visible: fileDuration == "0:00:00" ? false : true
                    }
                }

                header: Item {
                    height: 30
                    width: parent.width
                    Text {
                        color: "white"
                        text: "Users: " + listOfClients.count;
                        font.pointSize: 20
                    }
                }
            }
            
            Row {
                height: 40
                Layout.fillWidth: true
                Button {
                    text: "Disconnect"
                    width: parent.width
                    onPressed: {
                        stack.pop();
                        synchronyController.disconnect();
                    }
                }
            }
        }
    }

}
