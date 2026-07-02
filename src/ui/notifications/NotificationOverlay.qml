import Quickshell

import "../../theme"
import "../../data"

PopupWindow {
    id: root
    required property var panelWindow

    anchor.window: panelWindow
    anchor.rect.x: panelWindow.width - width - Theme.spacing
    anchor.rect.y: panelWindow.height + Theme.spacing
    implicitWidth: Theme.popupWidth
    implicitHeight: notificationStack.implicitHeight
    visible: NotificationsData.enabled && NotificationsData.activeNotifications.length > 0
    color: "transparent"

    NotificationStack {
        id: notificationStack
    }
}
