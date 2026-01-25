import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "../../theme"
import "../../data"

Item {
    readonly property var audioIcons: ({
        "headphone": "",
        "headset": "",
        "speaker1": "",
        "speaker2": "",
        "speaker3": "",
        "bluetooth": "",
        "muted": "",
        "mic": "",
        "micmuted": ""
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

                if (SystemData.sinkVolume < 33)
                    return audioIcons.speaker1
                if (SystemData.sinkVolume < 66)
                    return audioIcons.speaker2
                return audioIcons.speaker3
            }

            text: getIcon() + (SystemData.sinkMuted ? "" : SystemData.sinkVolume + "%")
            color: SystemData.sinkMuted ? Theme.colRed : Theme.colCyan

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

            function getIcon() {
                if (SystemData.sourceMuted) {
                    return audioIcons.micmuted
                } else {
                    return audioIcons.mic
                }
            }

            text: getIcon() + (SystemData.sourceMuted ? "" : SystemData.sourceVolume + "%")
            color: SystemData.sourceMuted ? Theme.colRed : Theme.colGreen

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
