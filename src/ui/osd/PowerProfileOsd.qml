import QtQuick

import "../../theme"
import "../../data"

Rectangle {
    width: Theme.osdWidth
    implicitHeight: powerText.implicitHeight + 20
    radius: Theme.popupRadius
    color: Theme.colBg
    border.width: 1
    border.color: Theme.colOverlayAlt

    Text {
        id: powerText
        anchors.centerIn: parent
        text: "Power Profile: " + ShellUiState.powerProfileOsdValue
        color: Theme.colFg
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
            bold: true
        }
    }
}
