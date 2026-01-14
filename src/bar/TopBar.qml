import Quickshell
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Hyprland._Ipc
import Quickshell._Window
import QtQuick
import QtQuick.Layouts

WlrLayershell {
    id: topBar

    implicitHeight: 32
    layer: WlrLayer.Top
    keyboardFocus: WlrKeyboardFocus.None
    anchors {
        top: true
        left: true
        right: true
    }
    exclusiveZone: height

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        // 🔹 LINKS: Workspaces
        RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: Hyprland.workspaces

                delegate: Rectangle {
                    property var workspace: modelData

                    color: workspace.focused ? "#cdd6f4" : "transparent"
                    radius: 4
                    implicitHeight: 22
                    implicitWidth: workspaceLabel.implicitWidth + 10
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        id: workspaceLabel
                        anchors.centerIn: parent
                        text: workspace.name.length ? workspace.name : workspace.id
                        color: workspace.focused ? "#1e1e2e" : "#cdd6f4"
                        font.pixelSize: 13
                        font.bold: workspace.focused
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // 🔸 MITTE (Uhr)
        Text {
            id: clock
            text: Qt.formatTime(new Date(), "HH:mm")
            color: "#f5c2e7"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        // 🔹 RECHTS
        Text {
            text: "⚡"
            color: "#a6e3a1"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // ⏱ Uhr aktualisieren
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
    }
}
