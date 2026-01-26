import QtQuick
import Quickshell

import "theme"
import "ui/bar"
import "ui/notifications"

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: "transparent"
    exclusiveZone: Theme.barHeight + 2

    Bar {
        anchors.fill: parent
        panelWindow: root
    }

    NotificationToasts { }
}
