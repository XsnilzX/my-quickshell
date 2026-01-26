import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../../theme"
import "../../data"

Item {
    id: root

    property var entry
    property var notification: entry ? entry.notification : null
    property int notificationId: entry ? entry.notificationId : 0
    property var actionList: notification ? notification.actions : (entry ? entry.actions : [])
    property bool hasActions: actionList && actionList.length > 0

    implicitWidth: toastContainer.implicitWidth
    implicitHeight: toastContainer.implicitHeight

    function urgencyColor(urgency) {
        switch (urgency) {
        case NotificationUrgency.Low:
            return Theme.colBlue
        case NotificationUrgency.Critical:
            return Theme.colRed
        default:
            return Theme.colYellow
        }
    }

    Timer {
        interval: entry ? entry.timeoutMs : 0
        running: notification && entry && entry.timeoutMs > 0
        repeat: false
        onTriggered: notification.expire()
    }

    Rectangle {
        id: toastContainer
        color: Theme.colMuted
        radius: Theme.itemRadius
        implicitWidth: 320
        implicitHeight: contentColumn.implicitHeight + 16

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Rectangle {
                color: urgencyColor(entry ? entry.urgency : NotificationUrgency.Normal)
                width: 4
                radius: 2
                Layout.fillHeight: true
            }

            IconImage {
                visible: entry && entry.icon && entry.icon.length > 0
                source: entry ? entry.icon : ""
                implicitSize: 24
                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                id: contentColumn
                spacing: 6
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: entry ? entry.summary : ""
                        color: Theme.colFg
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "×"
                        color: Theme.colFg
                        font.pixelSize: Theme.fontSize + 2

                        MouseArea {
                            anchors.fill: parent
                            onClicked: NotificationsData.dismissById(notificationId)
                        }
                    }
                }

                Text {
                    text: NotificationsData.sanitizeRichText(entry ? entry.body : "")
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    color: Theme.colFg
                    font.pixelSize: Theme.fontSize - 1
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }

                RowLayout {
                    visible: hasActions
                    spacing: 6
                    Layout.fillWidth: true

                    Repeater {
                        model: actionList

                        Rectangle {
                            height: 22
                            radius: 4
                            color: Theme.colBg
                            border.color: Theme.colBlue
                            border.width: 1
                            Layout.fillWidth: true

                            Text {
                                anchors.centerIn: parent
                                text: modelData.text
                                color: Theme.colFg
                                font.pixelSize: Theme.fontSize - 2
                                elide: Text.ElideRight
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData.invoke) {
                                        modelData.invoke()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
