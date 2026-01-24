import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "../../theme"
import "../../data"

Item {
    readonly property var audioIcons: ({
        "headphone": "",
        "headset": "",
        "speaker": ["", "", ""],
        "bluetooth": "",
        "muted": "",
        "mic": ""
    })

    implicitWidth: audioRow.implicitWidth
    implicitHeight: audioRow.implicitHeight

    RowLayout {
        id: audioRow
        spacing: 8

        Text {
            id: audioOutput

            function getIcon() {
                if (SystemData.sinkMuted)
                    return audioIcons.muted

                if (SystemData.sinkName.includes("bluetooth")
                    || SystemData.sinkName.includes("bluez")) {
                    return audioIcons.bluetooth
                }

                if (SystemData.sinkName.includes("headphone")
                    || SystemData.sinkName.includes("headset")) {
                    return audioIcons.headphone
                }

                var icons = audioIcons.speaker
                if (SystemData.sinkVolume < 33)
                    return icons[0]
                if (SystemData.sinkVolume < 66)
                    return icons[1]
                return icons[2]
            }

            text: getIcon() + " " + SystemData.sinkVolume + "%"
            color: SystemData.sinkMuted ? Theme.colMuted : Theme.colCyan

            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4

                onClicked: {
                    pavuProc.running = true
                }

                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0) {
                        volUpProc.running = true
                    } else {
                        volDownProc.running = true
                    }
                }
            }
        }

        Text {
            id: audioInput

            text: audioIcons.mic + " " + (SystemData.sourceMuted ? "0%" : SystemData.sourceVolume + "%")
            color: SystemData.sourceMuted ? "#f7768e" : Theme.colGreen

            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4

                onClicked: {
                    micToggleProc.running = true
                }
            }
        }
    }

    Process {
        id: pavuProc
        command: ["pavucontrol"]
    }

    Process {
        id: volUpProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]
    }

    Process {
        id: volDownProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
    }

    Process {
        id: micToggleProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
    }
}
