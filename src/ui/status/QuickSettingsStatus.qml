import QtQuick

import "../../theme"
import "../../data"

Rectangle {
    implicitWidth: quickText.implicitWidth + 14
    implicitHeight: Theme.itemHeight - 8
    radius: Theme.itemRadius
    color: ShellUiState.quickSettingsOpen ? Theme.colCyan : "transparent"
    border.width: ShellUiState.quickSettingsOpen ? 0 : 1
    border.color: Theme.colOverlayAlt

    Text {
        id: quickText
        anchors.centerIn: parent
        text: ""
        color: Theme.colFg
        font {
            family: Theme.fontIcons
            pixelSize: Theme.fontSize
            bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellUiState.toggleQuickSettings()
    }
}
