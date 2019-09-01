import QtQuick 2.10
import QtQuick.Controls 2.3
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
    property var cachedRanges

    function clearChapterMarkers() {
        if (control.chapterMarkers) {
            control.chapterMarkers.forEach(function(marker) {
                marker.destroy()
            })
        }
    }

    function clearCachedRanges() {
        if (control.cachedRanges) {
            control.cachedRanges.forEach(function(range) {
                range.destroy()
            })
        }
    }

    Connections {
        target: videoObject

        onChapterListChanged: {
            clearChapterMarkers()

            var chapterLocations = []
            videoObject.chapterList.forEach(function(chapter) {
                chapterLocations.push(chapter.time/videoObject.duration)
            })

            var chapterMarkers = []
            for (var i = 1; i < chapterLocations.length; i++) {
                chapterMarkers.push(Qt.createQmlObject('import QtQuick 2.0; import "../synchrostyle"; Rectangle {color: Style.lightColor; width: 1; height: 2; y: 0; x:' +  chapterLocations[i] + '*control.width; z: 10;}', background))
            }
            control.chapterMarkers = chapterMarkers
        }

        onCachedListChanged: {
            clearCachedRanges()
            
            var range = []
            var ranges = []
            var i = 1
            videoObject.cachedList.forEach(function(number) {
                range.push(number)
                if (i % 2 == 0) {
                    ranges.push(range)
                    range = [];
                }
                i++
            })
            ranges.forEach(function(range) {
                chapterMarkers.push(Qt.createQmlObject('import QtQuick 2.0; import "../synchrostyle"; Rectangle {color: Style.middleLightColor; width:' + (range[1]-range[0]) + '*control.width; height: 2; y: 0; x:' +  range[0] + '*control.width; z: 1;}', background))
            })
        }

        onFileChanged: {
            clearChapterMarkers()
            clearCachedRanges()
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
