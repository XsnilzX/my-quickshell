pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    Component.onCompleted: {
        nmAppletProc.running = true
        bluemanProc.running = true
    }

    property Process nmAppletProc: Process {
        command: ["nm-applet"]
    }

    property Process bluemanProc: Process {
        command: ["blueman-applet"]
    }
}
