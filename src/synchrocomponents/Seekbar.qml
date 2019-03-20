import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.impl 2.2
import "../synchrostyle"

import Synchro.Core 1.0

Slider {
    id: control
    padding: 0
    topPadding: 8
    bottomPadding: 4
    radius: 0
    live: false
    to: 100

    background.implicitWidth: control.horizontal ? 200 : 2
    background.implicitHeight: control.horizontal ? 2 : 200

    signal clickSeek()
    signal draggedSeek()

    background.transform: Scale {
        id: seekbarTransformScale
        origin.y: background.height
    }

    states: State {
        name: "hovered"
        when: seekbarMouseArea.containsMouse
        PropertyChanges {
            target: seekbarTransformScale
            yScale: 2.5
        }
    }

    transitions: Transition {
        reversible: true
        from: ""
        to: "hovered"
        NumberAnimation {
            target: seekbarTransformScale
            properties: "yScale"
            duration: 75
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        function moveSeekbar(dragged)
        {
            control.value = (mouseX/background.width)*100
            if (dragged)
                draggedSeek()
            else
                clickSeek()
        }

        id: seekbarMouseArea
        enabled: parent.enabled
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        hoverEnabled: true
        onPressed: {
            moveSeekbar(false)
        }
        onPositionChanged: {
            if (!pressed)
                return;
            moveSeekbar(true)
        }
    }
}
