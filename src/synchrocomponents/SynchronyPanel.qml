import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Synchro.Core 1.0
import "../synchrostyle"

Item {
    property var clientListModel: []

    id: synchronyPanel
    anchors.right: parent.right
    height: parent.height
    width: parent.width/4


    StackView {
        id: stack
        initialItem: connectScreen
        anchors.fill: parent
    }

    Component {
        id: connectScreen

        ColumnLayout {
            function connectToServer(ip) {
                let stringList = ip.split(":");
                if (stringList.length > 1)
                {
                    synchronyController.connectToServer(stringList[0], stringList[1]);
                }
                // settings.lastName = nameField.text;
                // synchronyController.sendCommand(4, [nameField.text]);
                stack.push(connectedScreen);
            }

            ServerBrowser {
                id: serverBrowser
            }

            Connections {
                target: serverBrowser
                onRefreshed: {
                    serverList.model = serverBrowser.getList()
                }
            }

            // Row {
            //     TextField {
            //         id: ipField
            //         width: 200
            //         text: "35.227.80.175:32019"
            //     }
            // }


            // TextField {
            //     id: nameField
            //     width: 200
            //     text: settings.lastName
            // }

            Layout.fillHeight: true
            Layout.fillWidth: true
            ListView {
                id: serverList 
                Layout.fillHeight: true
                Layout.fillWidth: true

                delegate: Item {
                    height: 20
                    width: parent.width
                    property var text: modelData
                    Text {
                        color: "white"
                        text: parent.text
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: serverList.currentIndex = index
                        onDoubleClicked: connectToServer(serverList.currentItem.text)
                    }
                }

                header: Item {
                    Component.onCompleted: {
                        serverBrowser.refresh()
                    }
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
            Button {
                id: connectButton
                text: "Connect"
                onPressed: connectToServer(serverList.currentItem.text)
            }
        }
    }

    Component {
        id: connectedScreen

        Item {
            ListView {
                id: listOfClients
                anchors.fill: parent
                model: clientListModel
                delegate: Item {
                    height: 20
                    width: parent.width
                    Text {
                        color: "white"
                        text: modelData
                    }
                }

                header: Item {
                    height: 30
                    width: parent.width
                    Text {
                        color: "white"
                        text: "Users: " + listOfClients.model.length
                        font.pointSize: 20
                    }
                }
            }

            Button {
                text: "Disconnect btw"
                anchors.top: parent.top
                anchors.right: parent.right

                onPressed: {
                    stack.pop();
                    synchronyController.disconnect();
                    clientListModel = [];
                }
            }
        }
    }

}
