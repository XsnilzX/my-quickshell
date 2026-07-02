import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../data"

Item {
    implicitWidth: stackColumn.implicitWidth
    implicitHeight: stackColumn.implicitHeight

    ColumnLayout {
        id: stackColumn
        spacing: Theme.spacing

        Repeater {
            model: NotificationsData.activeNotifications

            delegate: NotificationBubble {
                required property var modelData
                entry: modelData
            }
        }
    }
}
