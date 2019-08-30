import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.impl 2.3
import QtQuick.Templates 2.3 as T

T.MenuItem {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: 6

    icon.width: 24
    icon.height: 24
    icon.color: control.palette.windowText

    contentItem: IconLabel {
        readonly property real arrowPadding: control.subMenu && control.arrow ? control.arrow.width + control.spacing : 0
        readonly property real indicatorPadding: control.checkable && control.indicator ? control.indicator.width + control.spacing : 0
        leftPadding: !control.mirrored ? indicatorPadding : arrowPadding
        rightPadding: control.mirrored ? indicatorPadding : arrowPadding

        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignLeft

        icon: control.icon
        text: control.text
        font: control.font
        color: control.highlighted ? "white" : Style.lightColor
    }

    indicator: ColorImage {
        x: control.mirrored ? control.width - width - control.rightPadding : control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        height: control.availableHeight*0.8
        fillMode: Image.PreserveAspectFit

        visible: control.checked
        source: control.checkable ? "qrc:/qt-project.org/imports/QtQuick/Controls.2/images/check.png" : ""
        color: control.highlighted ? "white" : Style.lightColor
        defaultColor: "#353637"
    }

    arrow: ColorImage {
        x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        height: control.availableHeight*0.8
        fillMode: Image.PreserveAspectFit

        visible: control.subMenu
        mirror: control.mirrored
        source: control.subMenu ? "qrc:/qt-project.org/imports/QtQuick/Controls.2/images/arrow-indicator.png" : ""
        color: control.highlighted ? "white" : Style.lightColor
        defaultColor: "#353637"
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 28
        x: 1
        y: 1
        width: control.width - 2
        height: control.height - 2
        color: control.down ? Qt.lighter(Style.accentColorDark, 1.1) : Qt.darker(Style.accentColorDark, 1.1)
        visible: control.highlighted
    }
}