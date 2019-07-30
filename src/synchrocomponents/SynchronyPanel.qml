import QtQuick 2.9
import QtQuick.Controls 2.2

Item {
    property alias clientListModel:listOfClients.model

    id: synchronyPanel
    anchors.right: parent.right
    height: parent.height
    width: parent.width/4

    TextField {
        id: ipField
        width: parent.width-connectButton.width
        text: "35.227.80.175:32019"
    }
    Button {
        id: connectButton
        anchors.right: parent.right
        text: "Connect"

        onPressed: {
            let stringList = ipField.text.split(":");
            synchronyController.connectToServer(stringList[0], stringList[1]);
        }
    }
    ListView {
        id: listOfClients
        anchors.topMargin: ipField.height
        anchors.bottomMargin: nameField.height
        anchors.fill: parent

        model: []
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
    Row {
        width: parent.width
        anchors.bottom: parent.bottom

        TextField {
            id: nameField
            width: parent.width-nameButton.width
        }
        Button {
            id: nameButton
            text: "Set Name"

            onPressed: {
                synchronyController.sendCommand(4, [nameField.text])
            }
        }
    }

}
