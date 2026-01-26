import QtQuick

import Quickshell
import Quickshell.Wayland

import "../../data"

PanelWindow {
    id: root

    signal dismissRequested()

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"
    exclusiveZone: 0

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    mask: Region {
        item: overlayRoot

        Region {
            item: centerRect
            intersection: Intersection.Subtract
        }
    }

    Item {
        id: overlayRoot
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: root.dismissRequested()

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissRequested()
        }
    }

    Item {
        id: centerRect
        x: NotificationsData.centerX
        y: NotificationsData.centerY
        width: NotificationsData.centerWidth
        height: NotificationsData.centerHeight
        visible: false
    }
}
