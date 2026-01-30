pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    property int cpuUsage: 0
    property string ramUsage: "0.0GB"
    property int batPercent: 0
    property string batStatus: ""
    property int brightPercent: 0
    property string powerProfile: ""
    property string powerProfileTarget: ""

    property int sinkVolume: 0
    property bool sinkMuted: false
    property string sinkName: ""

    property int sourceVolume: 0
    property bool sourceMuted: false

    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    function refreshPowerProfile() {
        powerProfileProc.running = true
    }

    function setPowerProfile(profile) {
        if (!profile || profile === powerProfile)
            return

        powerProfileTarget = profile
        powerProfileSetProc.running = true
        powerProfileRefreshTimer.restart()
        powerProfile = profile
    }

    Component.onCompleted: powerProfileProc.running = true

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            batProc.running = true
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            brightProc.running = true
            sinkProc.running = true
            sourceProc.running = true
        }
    }

    Timer {
        id: powerProfileRefreshTimer
        interval: 500
        repeat: false

        onTriggered: {
            powerProfileProc.running = true
        }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return

                var parts = data.trim().split(/\s+/)
                var idle = parseInt(parts[4]) + parseInt(parts[5])
                var total = parts.slice(1, 8).reduce((acc, value) => acc + parseInt(value), 0)

                if (lastCpuTotal > 0) {
                    cpuUsage = Math.round(
                        100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal))
                    )
                }

                lastCpuTotal = total
                lastCpuIdle = idle
            }
        }
    }

    Process {
        id: ramProc
        command: [
            "sh",
            "-c",
            "free -m | awk '/^Speicher|^Mem/ {printf \"%.1fGB\", $3/1024}'"
        ]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return

                var usage = data.trim()
                if (usage.length > 0)
                    ramUsage = usage
            }
        }
    }

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
                    batStatus = parts[1]
                }
            }
        }
    }

    Process {
        id: powerProfileProc
        command: ["powerprofilesctl", "get"]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return

                powerProfile = data.trim()
            }
        }
    }

    Process {
        id: powerProfileSetProc
        command: ["powerprofilesctl", "set", powerProfileTarget]
    }

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

                var percentage = parts.find(segment => segment.includes("%"))
                if (percentage)
                    brightPercent = parseInt(percentage.replace("%", ""))
            }
        }
    }

    Process {
        id: sinkProc
        command: ["sh", "-c", `
            vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
            name=$(pactl get-default-sink 2>/dev/null)
            echo "$vol|$name"
        `]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return

                var parts = data.trim().split("|")
                var volPart = parts[0] || ""
                var namePart = parts[1] || ""

                var volMatch = volPart.match(/Volume:\s*([\d.]+)/)
                if (volMatch)
                    sinkVolume = Math.round(parseFloat(volMatch[1]) * 100)

                sinkMuted = volPart.includes("[MUTED]")
                sinkName = namePart.toLowerCase()
            }
        }
    }

    Process {
        id: sourceProc
        command: ["sh", "-c", `
            wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null
        `]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return

                var volMatch = data.match(/Volume:\s*([\d.]+)/)
                if (volMatch)
                    sourceVolume = Math.round(parseFloat(volMatch[1]) * 100)

                sourceMuted = data.includes("[MUTED]")
            }
        }
    }
}
