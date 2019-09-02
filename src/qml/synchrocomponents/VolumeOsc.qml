import QtQuick 2.10
import QtQuick.Controls 2.3
import "../synchrostyle"

Item {
    id: oscVolume
    width: 42
    height: 135
    anchors.rightMargin: -width
    anchors.right: parent.right
    anchors.bottomMargin: oscPanel.height
    anchors.bottom: parent.bottom

    property alias value:volumeSlider.value
    property alias containsMouse:volumeMouseArea.containsMouse
    property real storedValue: 100

    signal volumeChanged()

    function showOsc() {
        volumeAutohideTimer.restart()
    }

    Connections {
        target: videoObject

        onCurrentVolumeChanged: {
            storedValue = videoObject.currentVolume
            showOsc();
        }
    }

    SynchroBackground {
        id: oscVolumeBg
        sourceItem: videoObject
        sourceRect: Qt.rect(parent.x, parent.y, parent.width, parent.height)
        tintOpacity: 0
        radius: 4

        Rectangle {
            width: oscVolume.width
            height: oscVolume.height
            color: 'transparent'
            clip: true

            Rectangle {
                width: parent.width + radius
                height: oscPanel.state == "hidden" ? parent.height : parent.height + radius
                radius: oscVolumeBg.radius
                opacity: 0.66
                color: '#000000'
            }
        }
    }

    states: State {
        name: "revealed"
        PropertyChanges {
            target: oscVolume
            anchors.rightMargin: 0
        }
        PropertyChanges {
            target: seekSlider
            anchors.rightMargin: oscVolume.width
        }
        PropertyChanges {
            target: shadow
            anchors.rightMargin: oscVolume.width
        }
    }

    transitions: Transition {
        reversible: true
        to: "revealed"
        NumberAnimation {
            target: oscVolume
            properties: "anchors.rightMargin"
            duration: 175
            easing.type: Easing.InOutSine
        }

        NumberAnimation {
            target: seekSlider
            properties: "anchors.rightMargin"
            duration: 175
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: shadow
            properties: "anchors.rightMargin"
            duration: 175
            easing.type: Easing.InOutSine
        }
    }

    Timer {
        id: volumeAutohideTimer
        interval: 500

        onRunningChanged: {
            if (running)
                volumeOsc.state = "revealed"
        }

        onTriggered: {
            if (!volumeIconMouseArea.containsMouse && !volumeOsc.containsMouse)
                volumeOsc.state = ""
        }
    }

    MouseArea {
        id: volumeMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onContainsMouseChanged: {
            showOsc()
        }

        Slider {
            id: volumeSlider
            anchors.fill: parent
            anchors.margins: 8
            orientation: Qt.Vertical
            to: 100
            value: videoObject.muted ? 0 : oscVolume.storedValue
            onValueChanged: {
                volumeChanged()
                showOsc()
            }
            onMoved: { videoObject.currentVolume = value}
        }
    }
}
