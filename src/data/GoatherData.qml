pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    property string display: ""
    property string tooltip: ""
    property string className: ""

    Timer {
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: goatherProc.running = true
    }

    Process {
        id: goatherProc
        command: ["goather"]

        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                if (!output)
                    return

                var payload
                try {
                    payload = JSON.parse(output)
                } catch (error) {
                    return
                }

                display = payload.display || ""
                tooltip = payload.tooltip || ""
                className = payload.class || ""
            }
        }
    }
}
