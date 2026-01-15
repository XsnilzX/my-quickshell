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
    property color colPurple: "#bb9af7"
    property color colGreen: "#9ece6a"
    property color colOrange: "#ff9e64"
    
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 13

    /* ────────────── STATUS DATA ────────────── */
    property int cpuUsage: 0
    property int ramUsage: 0
    property int batPercent: 0
    property string batStatus: ""
    property int brightPercent: 0

    // CPU Cache
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    // TIMER
    Timer {
        interval: 2000 
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            batProc.running = true
            brightProc.running = true
        }
    }

    /* ────────────── PROCESSES ────────────── */
    
    // 1. CPU
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
    }

    // 2. RAM
    Process {
        id: ramProc
        // Hinweis: Falls "Speicher" nicht gefunden wird, probiere "Mem" (abhängig von Sprache)
        command: ["sh", "-c", "free -m | awk '/^Speicher|^Mem/ {printf \"%.0f%%\", ($3/$2)*100}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var percentage = parseInt(data.trim().replace('%', ''))
                if (!isNaN(percentage)) ramUsage = percentage
            }
        }
    }

    // 3. BATTERIE
    Process {
        id: batProc
        command: ["sh", "-c", "echo $(cat /sys/class/power_supply/BAT*/capacity | head -1) $(cat /sys/class/power_supply/BAT*/status | head -1)"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(" ")
                if (parts.length >= 2) {
                    batPercent = parseInt(parts[0])
                    batStatus = parts[1]
                }
            }
        }
    }

    // 4. HELLIGKEIT
    Process {
        id: brightProc
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(",")
                if (parts.length > 0) {
                    // Der vorletzte oder letzte Wert bei brightnessctl -m ist %
                    // Wir suchen einfach nach dem Wert mit %
                    var p = parts.find(s => s.includes("%"))
                    if (p) brightPercent = parseInt(p.replace("%", ""))
                }
            }
        }
    }

    /* ────────────── UI KOMPONENTEN ────────────── */
    
    // BarItem (Nur noch für die Mitte/Uhr benutzt)
    component BarItem: Rectangle {
        property alias text: label.text
        property alias textColor: label.color
        height: 26
        radius: 6
        color: root.colMuted
        width: label.implicitWidth + 24
        Text {
            id: label
            anchors.centerIn: parent
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
    }

    /* ────────────── LAYOUT ────────────── */

    anchors { top: true; left: true; right: true }
    implicitHeight: 36
    color: "transparent"

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8
        columns: 3

        /* ────────────── LEFT: WORKSPACES ────────────── */
        RowLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Rectangle {
                color: root.colMuted
                radius: 6
                height: 26
                width: wsRow.implicitWidth + 24 
                
                RowLayout {
                    id: wsRow
                    anchors.centerIn: parent
                    spacing: 12

                    Repeater {
                        model: 9
                        Text {
                            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                            
                            visible: isActive || (ws !== undefined)
                            Layout.preferredWidth: visible ? implicitWidth : 0
                            Layout.preferredHeight: visible ? implicitHeight : 0

                            text: index + 1
                            color: isActive ? root.colBlue : root.colFg
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4 
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }
                }
            }
        }

        /* ────────────── CENTER: UHR ────────────── */
        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter
            BarItem {
                text: Qt.formatTime(new Date(), "HH:mm")
                textColor: root.colFg
            }
        }

        /* ────────────── RIGHT: SYSTEM STATUS ────────────── */
        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            
            // Ein großes Rechteck für alle Status-Infos
            Rectangle {
                color: root.colMuted
                radius: 6
                height: 26
                // Breite passt sich dem Inhalt an + Padding (24px)
                width: sysRow.implicitWidth + 24

                RowLayout {
                    id: sysRow
                    anchors.centerIn: parent
                    spacing: 16 // Abstand zwischen den Modulen innerhalb der Box

                    // 1. CPU
                    Text {
                        text: " " + cpuUsage + "%"
                        color: root.colYellow
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    }

                    // 2. RAM
                    Text {
                        text: " " + ramUsage + "%"
                        color: root.colPurple
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    }

                    // 3. Brightness
                    Text {
                        text: " " + brightPercent + "%"
                        color: root.colOrange
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    }

                    // 4. Bat
                    Text {
                        property bool isCharging: batStatus.includes("Charging") || batStatus.includes("Full")
                        text: (isCharging ? "⚡" : "BAT: ") + batPercent + "%"
                        color: isCharging 
                            ? root.colGreen 
                            : (batPercent < 20 ? "#f7768e" : root.colGreen)
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    }
                }
            }
        }
    }
}
