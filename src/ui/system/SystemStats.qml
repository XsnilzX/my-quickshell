import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../data"

Item {
    implicitWidth: statsRow.implicitWidth
    implicitHeight: statsRow.implicitHeight

    RowLayout {
        id: statsRow
        spacing: 8

        RowLayout {
            spacing: 4

            Text {
                text: ""
                color: Theme.colYellow
                font {
                    family: Theme.fontIcons
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }

            Text {
                text: SystemData.cpuUsage + "%"
                color: Theme.colYellow
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }
        }

        RowLayout {
            spacing: 4

            Text {
                text: ""
                color: Theme.colPurple
                font {
                    family: Theme.fontIcons
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }

            Text {
                text: SystemData.ramUsage
                color: Theme.colPurple
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }
        }

        RowLayout {
            spacing: 4

            Text {
                text: ""
                color: Theme.colOrange
                font {
                    family: Theme.fontIcons
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }

            Text {
                text: SystemData.brightPercent + "%"
                color: Theme.colOrange
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }
        }

        RowLayout {
            id: batteryRow
            spacing: 4

            property bool isCharging: SystemData.batStatus.includes("Charging")
                || SystemData.batStatus.includes("Full")
            readonly property color batteryColor: isCharging
                ? Theme.colGreen
                : (SystemData.batPercent < 20 ? "#f7768e" : Theme.colGreen)

            Text {
                text: batteryRow.isCharging ? "" : ""
                color: batteryRow.batteryColor
                font {
                    family: Theme.fontIcons
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }

            Text {
                text: SystemData.batPercent + "%"
                color: batteryRow.batteryColor
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }
        }

        Text {
            id: powerProfileText
            property string profile: SystemData.powerProfile

            function profileIcon(profile) {
                switch (profile) {
                case "balanced":
                    return ""
                case "performance":
                    return ""
                case "power-saver":
                    return ""
                default:
                    return "?"
                }
            }

            function nextProfile(profile) {
                switch (profile) {
                case "power-saver":
                    return "balanced"
                case "balanced":
                    return "performance"
                case "performance":
                    return "power-saver"
                default:
                    return "balanced"
                }
            }

            function colorProfile(profile) {
                switch(profile) {
                    case "power-saver":
                        return Theme.colGreen
                    case "balanced":
                        return Theme.colOrange
                    case "performance":
                        return Theme.colRed
                    default:
                        return Theme.colCyan
                }
            }

            text: profileIcon(profile)
            color: colorProfile(profile)

            font {
                family: Theme.fontIcons
                pixelSize: Theme.fontSize
                bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: SystemData.setPowerProfile(powerProfileText.nextProfile(powerProfileText.profile))
            }
        }
    }
}
