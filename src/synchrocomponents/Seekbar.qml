import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.impl 2.2
import "../synchrostyle"

Slider {
    id: control
    padding: 0
    topPadding: 8
    radius: 0

    background.implicitWidth: control.horizontal ? 200 : 2
    background.implicitHeight: control.horizontal ? 2 : 200

    states: State {
        name: "hovered"
        when: seekbarMouseArea.containsMouse
        PropertyChanges {
            target: background
            implicitWidth: control.horizontal ? 200 : 8
            implicitHeight: control.horizontal ? 8 : 200
        }
    }

    transitions: Transition {
        reversible: true
        from: ""
        to: "hovered"
        NumberAnimation {
            target: background
            properties: "implicitHeight,implicitWidth"
            duration: 75
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        id: seekbarMouseArea
        enabled: parent.enabled
        acceptedButtons: Qt.NoButton 
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        hoverEnabled: true
    }
}
