import QtQuick 2.10

Item {
    Shortcut {
        sequence: "Left"
        onActivated: videoObject.seekBy(-5)
    }
    Shortcut {
        sequence: "Right"
        onActivated: videoObject.seekBy(5)
    }
}
