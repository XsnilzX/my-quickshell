import QtQuick

import "../../theme"
import "../../data"

Rectangle {
    implicitWidth: notifText.implicitWidth + 14
    implicitHeight: Theme.itemHeight - 8
    radius: Theme.itemRadius
    color: ShellUiState.notificationCenterOpen
        ? Theme.colBlue
        : (NotificationsData.unreadCount > 0 ? Theme.colOverlayAlt : "transparent")
    border.width: NotificationsData.unreadCount > 0 || ShellUiState.notificationCenterOpen ? 0 : 1
    border.color: Theme.colOverlayAlt

    Text {
        id: notifText
        anchors.centerIn: parent
        text: NotificationsData.unreadCount > 0
            ? " " + NotificationsData.unreadCount
            : ""
        color: Theme.colFg
        font {
            family: Theme.fontIcons
            pixelSize: Theme.fontSize
            bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellUiState.toggleNotificationCenter()
    }
}
