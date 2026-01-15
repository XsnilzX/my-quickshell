import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    /* ────────────── LAYOUT / ROOT ────────────── */

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 36
    color: "transparent"

    /* ────────────── THEME ────────────── */

    readonly property color colBg:     "#1a1b26"
    readonly property color colFg:     "#a9b1d6"
    readonly property color colMuted:  "#24283b"
    readonly property color colCyan:   "#0db9d7"
    readonly property color colBlue:   "#7aa2f7"
    readonly property color colYellow: "#e0af68"
    readonly property color colPurple: "#bb9af7"
    readonly property color colGreen:  "#9ece6a"
    readonly property color colOrange: "#ff9e64"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int    fontSize:   13

    /* ────────────── STATUS DATA ────────────── */

    property int cpuUsage:     0
    property int ramUsage:     0
    property int batPercent:   0
    property string batStatus: ""
    property int brightPercent: 0

    // CPU-Cache
    property var lastCpuIdle:  0
    property var lastCpuTotal: 0

    /* ────────────── TIMER ────────────── */

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
                if (!data)
                    return

                var p = data.trim().split(/\s+/)
                var idle  = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)

                if (lastCpuTotal > 0) {
                    cpuUsage = Math.round(
                        100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal))
                    )
                }

                lastCpuTotal = total
                lastCpuIdle  = idle
            }
        }
    }

    // 2. RAM
    Process {
        id: ramProc
        // Hinweis: bei anderen Sprachen ggf. "Mem" statt "Speicher"
        command: [
            "sh",
            "-c",
            "free -m | awk '/^Speicher|^Mem/ {printf \"%.0f%%\", ($3/$2)*100}'"
        ]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return

                var percentage = parseInt(data.trim().replace('%', ''))
                if (!isNaN(percentage))
                    ramUsage = percentage
            }
        }
    }

    // 3. BATTERIE
    Process {
        id: batProc
        command: [
            "sh",
            "-c",
            "echo $(cat /sys/class/power_supply/BAT*/capacity | head -1) " +
            "$(cat /sys/class/power_supply/BAT*/status | head -1)"
        ]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return

                var parts = data.trim().split(" ")
                if (parts.length >= 2) {
                    batPercent = parseInt(parts[0])
                    batStatus  = parts[1]
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
                if (!data)
                    return

                var parts = data.trim().split(",")
                if (parts.length === 0)
                    return

                // suche den Eintrag mit "%"
                var p = parts.find(s => s.includes("%"))
                if (p)
                    brightPercent = parseInt(p.replace("%", ""))
            }
        }
    }

    /* ────────────── UI KOMPONENTEN ────────────── */

    // Generische Box mit Text, z.B. für die Uhr in der Mitte
    component BarItem: Rectangle {
        property alias text:      label.text
        property alias textColor: label.color

        height: 26
        radius: 6
        color: root.colMuted
        width: label.implicitWidth + 24

        Text {
            id: label
            anchors.centerIn: parent
            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }
    }

    /* ────────────── LAYOUT ────────────── */

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
                            readonly property int workspaceId: index + 1
                            property var ws: Hyprland.workspaces.values.find(
                                                w => w.id === workspaceId
                                            )
                            property bool isActive: Hyprland.focusedWorkspace?.id === workspaceId

                            visible: isActive || ws !== undefined

                            Layout.preferredWidth:  visible ? implicitWidth  : 0
                            Layout.preferredHeight: visible ? implicitHeight : 0

                            text: workspaceId
                            color: isActive ? root.colBlue : root.colFg

                            font {
                                family: root.fontFamily
                                pixelSize: root.fontSize
                                bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                onClicked: Hyprland.dispatch("workspace " + workspaceId)
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

            Rectangle {
                color: root.colMuted
                radius: 6
                height: 26
                width: sysRow.implicitWidth + 24

                RowLayout {
                    id: sysRow
                    anchors.centerIn: parent
                    spacing: 16

                    // 1. CPU
                    Text {
                        text: " " + cpuUsage + "%"
                        color: root.colYellow
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }

                    // 2. RAM
                    Text {
                        text: " " + ramUsage + "%"
                        color: root.colPurple
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }

                    // 3. Helligkeit
                    Text {
                        text: " " + brightPercent + "%"
                        color: root.colOrange
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }

                    // 4. Batterie
                    Text {
                        property bool isCharging: batStatus.includes("Charging")
                                                  || batStatus.includes("Full")

                        text: (isCharging ? "⚡" : "BAT: ") + batPercent + "%"
                        color: isCharging
                               ? root.colGreen
                               : (batPercent < 20 ? "#f7768e" : root.colGreen)

                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }
                }
            }
        }
    }
}
