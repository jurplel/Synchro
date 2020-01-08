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
    }
    SwipeView {
        id: swipe
        currentIndex: tabBar.currentIndex

        anchors.fill: parent
        anchors.topMargin: 40

        Item {
            id: firstPage
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
    }
}
