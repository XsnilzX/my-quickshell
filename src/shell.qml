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

    // Margins für Abstand vom Bildschirmrand (optional)
    /*margins {
        top: 4
        left: 8
        right: 8
    }*/

    implicitHeight: 36
    color: "transparent"
    
    // Wichtig: Exclusive Zone damit Fenster nicht unter die Bar gehen
    exclusiveZone: implicitHeight + 8

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
    readonly property int    inHeight:   34
    readonly property int    inRadius:   6

    /* ────────────── STATUS DATA ────────────── */

    property int cpuUsage:     0
    property int ramUsage:     0
    property int batPercent:   0
    property string batStatus: ""
    property int brightPercent: 0

    // CPU-Cache
    property var lastCpuIdle:  0
    property var lastCpuTotal: 0

    /* ────────────── AUDIO DATA ────────────── */

    property int sinkVolume: 0
    property bool sinkMuted: false
    property string sinkName: ""

    property int sourceVolume: 0
    property bool sourceMuted: false

    // Audio-Icons basierend auf Gerät/Lautstärke
    readonly property var audioIcons: ({
        "headphone": "",
        "headset": "",
        "speaker": ["", "", ""],
        "bluetooth": "",
        "muted": ""
    })

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
            sinkProc.running = true
            sourceProc.running = true
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

                var p = parts.find(s => s.includes("%"))
                if (p)
                    brightPercent = parseInt(p.replace("%", ""))
            }
        }
    }

    // 5. Audio Sink (Lautsprecher/Kopfhörer)
    Process {
        id: sinkProc
        command: ["sh", "-c", `
            vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
            name=$(pactl get-default-sink 2>/dev/null)
            echo "$vol|$name"
        `]

        stdout: SplitParser {
            onRead: data => {
                if (!data) return

                var parts = data.trim().split("|")
                var volPart = parts[0] || ""
                var namePart = parts[1] || ""

                // Volume parsen: "Volume: 0.75" oder "Volume: 0.75 [MUTED]"
                var volMatch = volPart.match(/Volume:\s*([\d.]+)/)
                if (volMatch) {
                    sinkVolume = Math.round(parseFloat(volMatch[1]) * 100)
                }

                sinkMuted = volPart.includes("[MUTED]")
                sinkName = namePart.toLowerCase()
            }
        }
    }

    // 6. Audio Source (Mikrofon)
    Process {
        id: sourceProc
        command: ["sh", "-c", `
            wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null
        `]

        stdout: SplitParser {
            onRead: data => {
                if (!data) return

                var volMatch = data.match(/Volume:\s*([\d.]+)/)
                if (volMatch) {
                    sourceVolume = Math.round(parseFloat(volMatch[1]) * 100)
                }

                sourceMuted = data.includes("[MUTED]")
            }
        }
    }

    /* ────────────── UI KOMPONENTEN ────────────── */

    component BarItem: Rectangle {
        property alias text:      label.text
        property alias textColor: label.color

        height: inHeight
        radius: inRadius
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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 0

    /* ────────────── LEFT: WORKSPACES ────────────── */

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color: root.colMuted
                radius: inRadius
                height: inHeight
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

        Item {
            Layout.preferredWidth: clockText.implicitWidth + 24
            Layout.fillHeight: true

            BarItem {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatTime(new Date(), "HH:mm")
                textColor: root.colFg
            }
        }

    /* ────────────── RIGHT: SYSTEM STATUS ────────────── */

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: root.colMuted
                radius: inRadius
                height: inHeight
                width: sysRow.implicitWidth + 24

                RowLayout {
                    id: sysRow
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        text: " " + cpuUsage + "%"
                        color: root.colYellow
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }

                    Text {
                        text: " " + ramUsage + "%"
                        color: root.colPurple
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }

                    Text {
                        text: " " + brightPercent + "%"
                        color: root.colOrange
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }

                    Text {
                        property bool isCharging: batStatus.includes("Charging")
                                                || batStatus.includes("Full")

                        text: (isCharging ? "⚡ " : " ") + batPercent + "%"
                        color: isCharging
                            ? root.colGreen
                            : (batPercent < 20 ? "#f7768e" : root.colGreen)

                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }
                    }

                    /* ────────────── AUDIO WIDGET ────────────── */

                    // Lautsprecher/Output
                    Text {
                        id: audioOutput

                        function getIcon() {
                            if (sinkMuted) return root.audioIcons.muted

                            // Gerät erkennen
                            if (sinkName.includes("bluetooth") || sinkName.includes("bluez"))
                                return root.audioIcons.bluetooth
                            if (sinkName.includes("headphone") || sinkName.includes("headset"))
                                return root.audioIcons.headphone

                            // Standard-Speaker Icons basierend auf Lautstärke
                            var icons = root.audioIcons.speaker
                            if (sinkVolume < 33) return icons[0]
                            if (sinkVolume < 66) return icons[1]
                            return icons[2]
                        }

                        text: getIcon() + " " + sinkVolume + "%"
                        color: sinkMuted ? root.colMuted : root.colCyan

                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4

                            // Linksklick: pavucontrol öffnen
                            onClicked: {
                                pavuProc.running = true
                            }

                            // Scrollrad: Lautstärke ändern
                            onWheel: wheel => {
                                if (wheel.angleDelta.y > 0) {
                                    volUpProc.running = true
                                } else {
                                    volDownProc.running = true
                                }
                            }
                        }
                    }

                    // Trenner
                    Text {
                        text: "|"
                        color: root.colMuted
                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                        }
                    }

                    // Mikrofon/Input
                    Text {
                        id: audioInput

                        text: (sourceMuted ? "" : "") + " " + (sourceMuted ? "" : sourceVolume + "%")
                        color: sourceMuted ? "#f7768e" : root.colGreen

                        font {
                            family: root.fontFamily
                            pixelSize: root.fontSize
                            bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4

                            // Klick: Mikrofon muten/unmuten
                            onClicked: {
                                micToggleProc.running = true
                            }
                        }
                    }

                    // Trenner zum Rest
                    Rectangle {
                        width: 1
                        height: 16
                        color: root.colMuted
                    }
                }
            }
        }
    }
}