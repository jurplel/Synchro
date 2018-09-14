import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.impl 2.2
import QtQuick.Templates 2.2 as T

T.Slider {
    id: control
    topPadding: 8

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                           (handle ? handle.implicitWidth : 0) + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                            (handle ? handle.implicitHeight : 0) + topPadding + bottomPadding)

//    handle: Rectangle {
//        id: handle
//        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
//        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
//        implicitWidth: 10
//        implicitHeight: 2
//        radius: 0
//        color: control.pressed ? control.palette.light : control.palette.window
//        border.width: control.visualFocus ? 2 : 1
//        border.color: control.visualFocus ? control.palette.highlight : control.enabled ? control.palette.mid : control.palette.midlight
//        visible: false
//    }

    background: Rectangle {
        id: background
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 200 : 2
        implicitHeight: control.horizontal ? 2 : 200
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight
        color: "#404040"
        radius: 1
        scale: control.horizontal && control.mirrored ? -1 : 1

        Rectangle {
            id: foreground
            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : 2
            height: control.horizontal ? 2 : control.position * parent.height
            color: "#0ba9db"
            radius: 1
        }
    }

    states: [
        State {
            name: "hovered"
            when: seekbarMouseArea.containsMouse
            PropertyChanges {
                target: background
                implicitWidth: control.horizontal ? 200 : 6
                implicitHeight: control.horizontal ? 6 : 200
            }

            PropertyChanges {
                target: foreground
                width: control.horizontal ? control.position * parent.width : 6
                height: control.horizontal ? 6 : control.position * parent.height

            }
        }
    ]

    transitions: [
        Transition {
            reversible: true
            from: ""
            to: "hovered"
            NumberAnimation {
                target: background
                properties: "implicitHeight"
                duration: 75
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: foreground
                properties: "height"
                duration: 75
                easing.type: Easing.InOutQuad
            }
        }
    ]

    MouseArea {
        id: seekbarMouseArea
        enabled: parent.enabled
        acceptedButtons: Qt.NoButton
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
    }
}
