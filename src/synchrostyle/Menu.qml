import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.impl 2.3
import QtQuick.Templates 2.3 as T

import "../synchrocomponents"
import "./"

T.Menu {
    id: control


    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : 0)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem ? contentItem.implicitHeight : 0) + topPadding + bottomPadding

    margins: 0
    overlap: 1

    delegate: MenuItem { }

    contentItem: ListView {
        implicitHeight: contentHeight
        model: control.contentModel
        // TODO: improve this?
        interactive: ApplicationWindow.window ? contentHeight > ApplicationWindow.window.height : false
        clip: true
        keyNavigationWraps: false
        currentIndex: -1

        ScrollIndicator.vertical: ScrollIndicator {}
    }

    background: Rectangle {
        SynchroBackground {
            sourceItem: videoObject
            sourceRect: Qt.rect(control.x, control.y, control.width, control.height)
            border.color: Style.lightColor
            border.width: 1
            radius: 1
        }
        implicitWidth: 200
        implicitHeight: 0
    }

    T.Overlay.modal: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.5)
    }

    T.Overlay.modeless: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.12)
    }
}