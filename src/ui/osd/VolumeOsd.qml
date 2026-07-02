import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../data"

Rectangle {
    width: Theme.osdWidth
    implicitHeight: osdColumn.implicitHeight + 20
    radius: Theme.popupRadius
    color: Theme.colBg
    border.width: 1
    border.color: Theme.colOverlayAlt

    ColumnLayout {
        id: osdColumn
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            text: ShellUiState.volumeOsdMuted
                ? "Volume Muted"
                : "Volume " + ShellUiState.volumeOsdValue + "%"
            color: Theme.colFg
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 8
            radius: 4
            color: Theme.colMuted

            Rectangle {
                width: parent.width * (ShellUiState.volumeOsdValue / 100)
                height: parent.height
                radius: parent.radius
                color: ShellUiState.volumeOsdMuted ? Theme.colRed : Theme.colGreen
            }
        }
    }
}
