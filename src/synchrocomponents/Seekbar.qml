import QtQuick 2.9
import QtQuick.Controls 2.2
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

    signal seek(bool dragged)

    property var chapterMarkers

    Connections {
        target: videoObject

        onChapterListChanged: {
        if (control.chapterMarkers)
        {
            control.chapterMarkers.forEach(function(currentValue) {
                currentValue.destroy()
            })
        }

        var chapterLocations = []
        videoObject.chapterList.forEach(function(currentValue) {
            chapterLocations.push(currentValue.time/videoObject.duration)
        })

        var chapterMarkers = []
        for (var i = 1; i < chapterLocations.length; i++) {
            chapterMarkers.push(Qt.createQmlObject('import QtQuick 2.0; import "../synchrostyle"; Rectangle {color: Style.lightColor; width: 1; height: 2; y: 0; x:' +  chapterLocations[i] + '*control.width; }', background))
        }
        control.chapterMarkers = chapterMarkers
        }
    }

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
            seek(dragged)
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
