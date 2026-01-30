import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import "../common"
import "../../theme"

Item {
    id: clockRoot

    property string clockText: ""

    Layout.preferredWidth: clockItem.implicitWidth
    Layout.fillHeight: true

    BarItem {
        id: clockItem
        anchors.centerIn: parent
        text: clockRoot.clockText
        textColor: Theme.colFg
    }

    Process {
        id: dateProc

        command: ["date", "+%H:%M"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: clockRoot.clockText = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: dateProc.running = true
    }
}
