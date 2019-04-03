import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.impl 2.2
import QtQuick.Templates 2.2 as T
import QtGraphicalEffects 1.0

T.Slider {
    property int radius: 6
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                           (handle ? handle.implicitWidth : 0) + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                            (handle ? handle.implicitHeight : 0) + topPadding + bottomPadding)

    padding: 6

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 200 : 6
        implicitHeight: control.horizontal ? 6 : 200
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight
        radius: parent.radius
        color: Style.middleColor
        scale: control.horizontal && control.mirrored ? -1 : 1

        Rectangle {

            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : parent.width
            height: control.horizontal ? parent.height : control.position * parent.height

            radius: parent.radius
            color: Style.accentColorMiddle

            layer.enabled: true
            layer.effect: LinearGradient {
                start: Qt.point(0, 0)
                end: control.horizontal ? Qt.point(parent.width, 0) : Qt.point(0, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Style.accentColorLight }
                    GradientStop { position: 1.0; color: Style.accentColorDark }
                }
            }
        }
    }

    MouseArea { enabled: false; anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.PointingHandCursor }
}
