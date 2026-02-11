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

        Item {
            id: audioOutput
            implicitWidth: outputRow.implicitWidth
            implicitHeight: outputRow.implicitHeight

            readonly property color outputColor: SystemData.sinkMuted || (SystemData.sinkVolume <= 0)
                ? Theme.colRed
                : Theme.colGreen

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

                if (SystemData.sinkVolume <= 0)
                    return audioIcons.muted
                if (SystemData.sinkVolume < 33)
                    return audioIcons.speaker1
                if (SystemData.sinkVolume < 66)
                    return audioIcons.speaker2
                return audioIcons.speaker3
            }

            RowLayout {
                id: outputRow
                anchors.fill: parent
                spacing: 4

                Text {
                    text: audioOutput.getIcon()
                    color: audioOutput.outputColor

                    font {
                        family: Theme.fontIcons
                        pixelSize: Theme.fontSize
                        bold: true
                    }
                }

                Text {
                    text: SystemData.sinkMuted || (SystemData.sinkVolume <= 0) ? "" : SystemData.sinkVolume + "%"
                    color: audioOutput.outputColor
                    visible: !SystemData.sinkMuted && SystemData.sinkVolume > 0

                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize
                        bold: true
                    }
                }
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

        Item {
            id: audioInput
            implicitWidth: inputRow.implicitWidth
            implicitHeight: inputRow.implicitHeight

            readonly property color inputColor: SystemData.sourceMuted || (SystemData.sourceVolume <= 0)
                ? Theme.colRed
                : Theme.colGreen

            function getIcon() {
                if (SystemData.sourceMuted || (SystemData.sourceVolume <= 0)) {
                    return audioIcons.micmuted
                } else {
                    return audioIcons.mic
                }
            }

            RowLayout {
                id: inputRow
                anchors.fill: parent
                spacing: 4

                Text {
                    text: audioInput.getIcon()
                    color: audioInput.inputColor

                    font {
                        family: Theme.fontIcons
                        pixelSize: Theme.fontSize
                        bold: true
                    }
                }

                
                Text {
                    text: SystemData.sourceMuted || (SystemData.sourceVolume <= 0) ? "" : SystemData.sourceVolume + "%"
                    color: audioInput.inputColor
                    visible: !SystemData.sourceMuted && SystemData.sourceVolume > 0

                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize
                        bold: true
                    }
                }
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
