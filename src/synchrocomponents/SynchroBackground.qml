import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Rectangle {
    anchors.fill: parent
    property alias sourceRect:effectSource.sourceRect
    property alias sourceItem:effectSource.sourceItem

    ShaderEffectSource {
        id: effectSource
        sourceItem: videoObject
        width: parent.width
        height: parent.height
    }

    FastBlur {
        anchors.fill: effectSource
        source: effectSource
        radius: 64
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.66
        border.width: 0
        radius: parent.radius
    }
}
