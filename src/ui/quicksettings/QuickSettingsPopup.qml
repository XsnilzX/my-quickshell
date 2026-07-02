import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../theme"
import "../../data"

Rectangle {
    id: root
    width: Theme.popupWidth
    implicitHeight: settingsColumn.implicitHeight + (Theme.popupPadding * 2)
    radius: Theme.popupRadius
    color: Theme.colBg
    border.width: 1
    border.color: Theme.colOverlayAlt

    function profileLabel(profile) {
        switch (profile) {
        case "power-saver":
            return "Power Saver"
        case "performance":
            return "Performance"
        default:
            return "Balanced"
        }
    }

    ColumnLayout {
        id: settingsColumn
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: Theme.spacing

        Text {
            text: "Quick Settings"
            color: Theme.colFg
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: Theme.itemRadius
            color: Theme.colOverlay
            implicitHeight: volumeRow.implicitHeight + 14

            RowLayout {
                id: volumeRow
                anchors.fill: parent
                anchors.margins: 7
                spacing: 8

                Text {
                    text: "Volume"
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: SystemData.sinkMuted ? "Muted" : SystemData.sinkVolume + "%"
                    color: Theme.colGreen
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }

                Repeater {
                    model: [
                        {label: "-", delta: -5},
                        {label: "+", delta: 5}
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        radius: Theme.itemRadius
                        color: Theme.colMuted
                        implicitWidth: 24
                        implicitHeight: 24

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: Theme.colFg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: SystemData.setSinkVolumeDelta(modelData.delta)
                        }
                    }
                }

                Rectangle {
                    radius: Theme.itemRadius
                    color: Theme.colMuted
                    implicitWidth: muteText.implicitWidth + 14
                    implicitHeight: 24

                    Text {
                        id: muteText
                        anchors.centerIn: parent
                        text: "Mute"
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: SystemData.toggleSinkMute()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: Theme.itemRadius
            color: Theme.colOverlay
            implicitHeight: micRow.implicitHeight + 14

            RowLayout {
                id: micRow
                anchors.fill: parent
                anchors.margins: 7
                spacing: 8

                Text {
                    text: "Microphone"
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: SystemData.sourceMuted ? "Muted" : SystemData.sourceVolume + "%"
                    color: Theme.colGreen
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }

                Rectangle {
                    radius: Theme.itemRadius
                    color: Theme.colMuted
                    implicitWidth: micToggleText.implicitWidth + 14
                    implicitHeight: 24

                    Text {
                        id: micToggleText
                        anchors.centerIn: parent
                        text: "Toggle"
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: SystemData.toggleSourceMute()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: Theme.itemRadius
            color: Theme.colOverlay
            implicitHeight: brightnessRow.implicitHeight + 14

            RowLayout {
                id: brightnessRow
                anchors.fill: parent
                anchors.margins: 7
                spacing: 8

                Text {
                    text: "Brightness"
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: SystemData.brightPercent + "%"
                    color: Theme.colYellow
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }

                Repeater {
                    model: [
                        {label: "-", delta: -5},
                        {label: "+", delta: 5}
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        radius: Theme.itemRadius
                        color: Theme.colMuted
                        implicitWidth: 24
                        implicitHeight: 24

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: Theme.colFg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: SystemData.setBrightnessDelta(modelData.delta)
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: Theme.itemRadius
            color: Theme.colOverlay
            implicitHeight: powerRow.implicitHeight + 14

            RowLayout {
                id: powerRow
                anchors.fill: parent
                anchors.margins: 7
                spacing: 8

                Text {
                    text: "Power"
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.profileLabel(SystemData.powerProfile)
                    color: Theme.colOrange
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }

                Rectangle {
                    radius: Theme.itemRadius
                    color: Theme.colMuted
                    implicitWidth: cyclePowerText.implicitWidth + 14
                    implicitHeight: 24

                    Text {
                        id: cyclePowerText
                        anchors.centerIn: parent
                        text: "Cycle"
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (SystemData.powerProfile === "power-saver") {
                                SystemData.setPowerProfile("balanced")
                            } else if (SystemData.powerProfile === "balanced") {
                                SystemData.setPowerProfile("performance")
                            } else {
                                SystemData.setPowerProfile("power-saver")
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    {
                        label: "Network",
                        command: ["nm-connection-editor"]
                    },
                    {
                        label: "Bluetooth",
                        command: ["blueman-manager"]
                    },
                    {
                        label: "Audio",
                        command: ["pavucontrol"]
                    }
                ]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    radius: Theme.itemRadius
                    color: Theme.colMuted
                    implicitHeight: actionLabel.implicitHeight + 10

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.label
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Quickshell.execDetached(modelData.command)
                    }
                }
            }
        }
    }
}
