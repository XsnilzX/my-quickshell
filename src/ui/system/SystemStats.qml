import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../data"

Item {
    implicitWidth: statsRow.implicitWidth
    implicitHeight: statsRow.implicitHeight

    RowLayout {
        id: statsRow
        spacing: 16

        Text {
            text: " " + SystemData.cpuUsage + "%"
            color: Theme.colYellow
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }
        }

        Text {
            text: " " + SystemData.ramUsage + "%"
            color: Theme.colPurple
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }
        }

        Text {
            text: " " + SystemData.brightPercent + "%"
            color: Theme.colOrange
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }
        }

        Text {
            property bool isCharging: SystemData.batStatus.includes("Charging")
                || SystemData.batStatus.includes("Full")

            text: (isCharging ? "⚡ " : " ") + SystemData.batPercent + "%"
            color: isCharging
                ? Theme.colGreen
                : (SystemData.batPercent < 20 ? "#f7768e" : Theme.colGreen)

            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }
        }
    }
}
