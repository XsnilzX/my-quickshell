import Quickshell
import QtQuick

import "theme"
import "ui/bar"

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
        window: root
    }
}
