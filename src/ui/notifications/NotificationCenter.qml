import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../data"

Rectangle {
    id: root
    width: Theme.popupWidth + (Theme.popupPadding * 2)
    height: 420
    radius: Theme.popupRadius
    color: Theme.colBg
    border.width: 1
    border.color: Theme.colOverlayAlt

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: Theme.spacing

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Notifications"
                color: Theme.colFg
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                    bold: true
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                radius: Theme.itemRadius
                color: Theme.colOverlayAlt
                implicitWidth: readText.implicitWidth + 16
                implicitHeight: readText.implicitHeight + 8

                Text {
                    id: readText
                    anchors.centerIn: parent
                    text: "Read all"
                    color: Theme.colFg
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize - 2
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: NotificationsData.markAllRead()
                }
            }

            Rectangle {
                radius: Theme.itemRadius
                color: Theme.colOverlayAlt
                implicitWidth: clearText.implicitWidth + 16
                implicitHeight: clearText.implicitHeight + 8

                Text {
                    id: clearText
                    anchors.centerIn: parent
                    text: "Clear all"
                    color: Theme.colFg
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize - 2
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: NotificationsData.dismissAll()
                }
            }
        }

        Text {
            text: NotificationsData.visibleHistoryCount === 0
                ? "No notifications yet."
                : NotificationsData.visibleHistoryCount + " notifications"
            color: Theme.colBlue
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize - 1
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: historyColumn.implicitHeight

            ColumnLayout {
                id: historyColumn
                width: parent.width
                spacing: Theme.spacing

                Repeater {
                    model: NotificationsData.historyNotifications

                    delegate: NotificationListItem {
                        required property var modelData
                        visible: !modelData.isTransient
                        Layout.fillWidth: true
                        entry: modelData
                        width: historyColumn.width
                    }
                }
            }
        }
    }
}
