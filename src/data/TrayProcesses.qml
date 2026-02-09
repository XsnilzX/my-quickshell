pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    readonly property bool shouldStartNmApplet: Quickshell.env("MYQS_START_NM_APPLET") !== "0"
    readonly property bool shouldStartBluemanApplet: Quickshell.env("MYQS_START_BLUEMAN_APPLET") !== "0"

    Component.onCompleted: {
        if (shouldStartNmApplet)
            nmAppletProc.running = true

        if (shouldStartBluemanApplet)
            bluemanProc.running = true
    }

    property Process nmAppletProc: Process {
        command: ["nm-applet"]
    }

    property Process bluemanProc: Process {
        command: ["blueman-applet"]
    }
}
