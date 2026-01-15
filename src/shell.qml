import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    /* ────────────── THEME ────────────── */
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#24283b"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property color colEmpty: "#565f89" // Farbe für inaktive, aber belegte WS

    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 13

    /* ────────────── CPU LOGIC ────────────── */
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                if (lastCpuTotal > 0) cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
                lastCpuTotal = total; lastCpuIdle = idle
            }
        }
        Component.onCompleted: running = true
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: cpuProc.running = true }

    /* ────────────── HELPER COMPONENT (Für Uhr & CPU) ────────────── */
    component BarItem: Rectangle {
        property alias text: label.text
        property alias textColor: label.color
        height: 26
        radius: 6
        color: root.colMuted
        width: label.implicitWidth + 24 // Padding links/rechts
        Text {
            id: label
            anchors.centerIn: parent
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
    }

    /* ────────────── WINDOW CONFIG ────────────── */
    anchors { top: true; left: true; right: true }
    implicitHeight: 36
    color: "transparent"

    GridLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        columns: 3

        /* ────────────── LEFT: WORKSPACES (Gruppiert) ────────────── */
        RowLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            // Ein großes Rechteck um alle Zahlen
            Rectangle {
                color: root.colMuted
                radius: 6
                height: 26
                // Breite passt sich dem Inhalt an + 20px (10 links, 10 rechts Padding)
                width: wsRow.implicitWidth + 20

                RowLayout {
                    id: wsRow
                    anchors.centerIn: parent
                    spacing: 10 // Abstand zwischen den Zahlen

                    Repeater {
                        model: 9 // Prüfe Workspaces 1 bis 9

                        Text {
                            // Finden des Workspace Objekts, falls es existiert (Fenster offen)
                            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                            // Ist es der aktuelle?
                            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                            // HIER IST DIE LOGIK: Nur sichtbar wenn aktiv ODER belegt
                            visible: isActive || (ws !== undefined)
                            
                            // Damit das Layout zusammenrückt wenn etwas unsichtbar ist:
                            Layout.preferredWidth: visible ? implicitWidth : 0
                            Layout.preferredHeight: visible ? implicitHeight : 0

                            text: index + 1
                            
                            // Aktive sind Blau, belegte sind Hellgrau
                            color: isActive ? root.colBlue : root.colFg

                            font {
                                family: root.fontFamily
                                pixelSize: root.fontSize
                                bold: true
                            }

                            // Klickbar machen
                            MouseArea {
                                anchors.fill: parent
                                // Vergrößere Klickbereich etwas, da Text klein ist
                                anchors.margins: -4 
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }
                }
            }
        }

        /* ────────────── CENTER ────────────── */
        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            BarItem {
                text: Qt.formatTime(new Date(), "HH:mm")
                textColor: root.colFg
            }
        }

        /* ────────────── RIGHT ────────────── */
        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            BarItem {
                text: "CPU: " + cpuUsage + "%"
                textColor: root.colYellow
            }
        }
    }
}
