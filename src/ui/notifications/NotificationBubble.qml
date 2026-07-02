import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Notifications

import "../../theme"
import "../../data"

Rectangle {
    id: root
    required property var entry

    readonly property var notification: entry.notification
    readonly property color accentColor: {
        switch (notification.urgency) {
        case NotificationUrgency.Low:
            return Theme.colBlue
        case NotificationUrgency.Critical:
            return Theme.colRed
        default:
            return Theme.colCyan
        }
    }

    readonly property int timeoutMs: {
        if (notification.urgency === NotificationUrgency.Critical)
            return 0

        if (notification.expireTimeout > 0)
            return Math.round(notification.expireTimeout * 1000)

        return notification.urgency === NotificationUrgency.Low ? 2500 : 5000
    }

    width: Theme.popupWidth
    implicitHeight: contentColumn.implicitHeight + (Theme.popupPadding * 2)
    radius: Theme.popupRadius
    color: Theme.colOverlay
    border.width: 1
    border.color: accentColor

    Timer {
        id: dismissTimer
        interval: root.timeoutMs
        running: root.timeoutMs > 0
        repeat: false
        onTriggered: NotificationsData.expireBubble(root.entry)
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: dismissTimer.stop()
        onExited: {
            if (root.timeoutMs > 0)
                dismissTimer.restart()
        }
        onClicked: NotificationsData.activateEntry(root.entry)
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 4
        radius: Theme.popupRadius
        color: accentColor
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        anchors.leftMargin: Theme.popupPadding + 6
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Image {
                visible: iconSource.length > 0
                source: iconSource
                sourceSize: Qt.size(20, 20)
                Layout.preferredWidth: visible ? 20 : 0
                Layout.preferredHeight: visible ? 20 : 0
                fillMode: Image.PreserveAspectFit

                readonly property string iconSource: {
                    if (notification.appIcon)
                        return Quickshell.iconPath(notification.appIcon, true)
                    return ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: notification.summary || notification.appName || "Notification"
                    color: Theme.colFg
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize
                        bold: true
                    }
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                    Layout.fillWidth: true
                }

                Text {
                    text: notification.appName || ""
                    visible: text.length > 0
                    color: Theme.colBlue
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize - 1
                    }
                    textFormat: Text.PlainText
                    Layout.fillWidth: true
                }
            }

            Text {
                text: ""
                color: Theme.colFg
                font {
                    family: Theme.fontIcons
                    pixelSize: Theme.fontSize - 1
                    bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: NotificationsData.dismiss(root.entry)
                }
            }
        }

        Text {
            text: notification.body || ""
            visible: text.length > 0
            color: Theme.colFg
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize - 1
            }
            Layout.fillWidth: true
        }

        RowLayout {
            visible: (notification.actions || []).length > 0
            spacing: 6

            Repeater {
                model: notification.actions || []

                delegate: Rectangle {
                    required property var modelData

                    radius: Theme.itemRadius
                    color: Theme.colOverlayAlt
                    implicitWidth: actionText.implicitWidth + 18
                    implicitHeight: actionText.implicitHeight + 10

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: modelData.text
                        color: Theme.colFg
                        textFormat: Text.PlainText
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.fontSize - 1
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.entry.unread = false
                            modelData.invoke()
                            NotificationsData.refreshActiveNotifications()
                        }
                    }
                }
            }
        }
    }
}
