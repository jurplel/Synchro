import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.impl 2.3
import QtQuick.Templates 2.3 as T

T.MenuSeparator {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentItem.implicitHeight + topPadding + bottomPadding)

    padding: 4
    topPadding: 1
    bottomPadding: topPadding

    contentItem: Rectangle {
        implicitWidth: 188
        implicitHeight: 1
        color: Style.lightColor
    }
}
