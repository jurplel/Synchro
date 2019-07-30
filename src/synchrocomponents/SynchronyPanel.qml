import QtQuick 2.9
import QtQuick.Controls 2.2

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

        Column {
            width: parent.width
            anchors.top: parent.top
            spacing: 5
            Row {
                TextField {
                    id: ipField
                    width: 200
                    text: "35.227.80.175:32019"
                }
            }


            TextField {
                id: nameField
                width: 200
                text: "rusty shackleford"
            }



            Button {
                id: connectButton
                text: "Connect"

                onPressed: {
                    let stringList = ipField.text.split(":");
                    synchronyController.connectToServer(stringList[0], stringList[1]);
                    synchronyController.sendCommand(4, [nameField.text])
                    stack.push(connectedScreen);
                }
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
