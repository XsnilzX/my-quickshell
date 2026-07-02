import QtQuick
import QtQuick.Layouts

import Quickshell

import "../../theme"
import "../../data"

Rectangle {
    id: root
    required property var entry

    readonly property var notification: entry.notification

    color: entry.unread ? Theme.colOverlayAlt : Theme.colOverlay
    radius: Theme.itemRadius
    border.width: 1
    border.color: entry.closed ? Theme.colOverlayAlt : Theme.colMuted

    implicitWidth: parent ? parent.width : Theme.popupWidth
    implicitHeight: itemColumn.implicitHeight + 20

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: NotificationsData.activateEntry(root.entry)
    }

    ColumnLayout {
        id: itemColumn
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Image {
                visible: iconSource.length > 0
                source: iconSource
                sourceSize: Qt.size(18, 18)
                Layout.preferredWidth: visible ? 18 : 0
                Layout.preferredHeight: visible ? 18 : 0
                fillMode: Image.PreserveAspectFit

                readonly property string iconSource: {
                    if (notification.appIcon)
                        return Quickshell.iconPath(notification.appIcon, true)
                    return ""
                }
            }

            Text {
                text: notification.summary || notification.appName || "Notification"
                color: Theme.colFg
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                Layout.fillWidth: true
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }

            Text {
                text: entry.unread ? "●" : ""
                visible: text.length > 0
                color: Theme.colCyan
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize - 1
                    bold: true
                }
            }
        }

        Text {
            text: notification.body || ""
            visible: text.length > 0
            color: Theme.colFg
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            Layout.fillWidth: true
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize - 1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: notification.appName || ""
                visible: text.length > 0
                color: Theme.colBlue
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize - 2
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                visible: !entry.closed && (notification.actions || []).length > 0
                radius: Theme.itemRadius
                color: Theme.colMuted
                implicitWidth: openText.implicitWidth + 16
                implicitHeight: openText.implicitHeight + 8

                Text {
                    id: openText
                    anchors.centerIn: parent
                    text: (notification.actions || [])[0].text
                    color: Theme.colFg
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize - 2
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: NotificationsData.activateEntry(root.entry)
                }
            }

            Rectangle {
                radius: Theme.itemRadius
                color: Theme.colMuted
                implicitWidth: dismissText.implicitWidth + 16
                implicitHeight: dismissText.implicitHeight + 8

                Text {
                    id: dismissText
                    anchors.centerIn: parent
                    text: "Dismiss"
                    color: Theme.colFg
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize - 2
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: NotificationsData.dismiss(root.entry)
                }
            }
        }
    }
}
