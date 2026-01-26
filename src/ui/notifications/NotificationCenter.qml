import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

import "../../theme"
import "../../data"

PopupWindow {
    id: root

    property Item anchorItem
    property QtObject anchorWindow

    implicitWidth: 360
    implicitHeight: 480
    visible: false

    anchor.window: anchorWindow

    function updateAnchor() {
        if (!anchorItem || !anchorWindow || !anchorWindow.contentItem)
            return

        var point = anchorItem.mapToItem(anchorWindow.contentItem, 0, 0)
        anchor.rect.x = point.x
        anchor.rect.y = point.y + anchorItem.height
        anchor.rect.width = anchorItem.width
        anchor.rect.height = anchorItem.height

        updateCenterRect()
    }

    function updateCenterRect() {
        if (!visible)
            return

        NotificationsData.setCenterRect(anchor.rect.x, anchor.rect.y, width, height)
    }

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

    onVisibleChanged: {
        if (visible) {
            updateAnchor()
            NotificationsData.markAllSeen()
        }
    }

    onWidthChanged: updateCenterRect()
    onHeightChanged: updateCenterRect()
    onWindowConnected: updateCenterRect()

    Rectangle {
        anchors.fill: parent
        color: Theme.colMuted
        radius: Theme.itemRadius
        focus: true

        Keys.onEscapePressed: root.visible = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Notifications"
                    color: Theme.colFg
                    font.pixelSize: Theme.fontSize + 1
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    radius: 4
                    color: NotificationsData.doNotDisturb ? Theme.colRed : Theme.colBg
                    border.color: Theme.colBlue
                    border.width: 1
                    height: 24
                    Layout.preferredWidth: 60

                    Text {
                        anchors.centerIn: parent
                        text: "DND"
                        color: Theme.colFg
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: NotificationsData.toggleDnd()
                    }
                }

                Rectangle {
                    radius: 4
                    color: Theme.colBg
                    border.color: Theme.colBlue
                    border.width: 1
                    height: 24
                    Layout.preferredWidth: 72

                    Text {
                        anchors.centerIn: parent
                        text: "Clear All"
                        color: Theme.colFg
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: NotificationsData.clearAll()
                    }
                }
            }

            Rectangle {
                color: Theme.colBg
                radius: 2
                height: 1
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: historyList
                    anchors.fill: parent
                    spacing: 8
                    clip: true
                    model: NotificationsData.historyModel

                    delegate: Rectangle {
                        color: Theme.colBg
                        radius: Theme.itemRadius
                        width: historyList.width
                        implicitHeight: contentColumn.implicitHeight + 16

                        ColumnLayout {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    color: urgencyColor(urgency)
                                    width: 4
                                    radius: 2
                                    Layout.fillHeight: true
                                }

                                IconImage {
                                    visible: icon && icon.length > 0
                                    source: icon
                                    implicitSize: 24
                                    Layout.alignment: Qt.AlignTop
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: summary
                                        color: Theme.colFg
                                        font.pixelSize: Theme.fontSize
                                        font.bold: true
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: appName
                                        color: Theme.colFg
                                        font.pixelSize: Theme.fontSize - 2
                                        opacity: 0.7
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Rectangle {
                                    visible: !isSeen
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: Theme.colRed
                                    Layout.alignment: Qt.AlignVCenter
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
                                text: NotificationsData.sanitizeRichText(body)
                                textFormat: Text.RichText
                                wrapMode: Text.WordWrap
                                color: Theme.colFg
                                font.pixelSize: Theme.fontSize - 1
                                onLinkActivated: link => Qt.openUrlExternally(link)
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                visible: actions && actions.length > 0
                                spacing: 6
                                Layout.fillWidth: true

                                Repeater {
                                    model: notification ? notification.actions : actions

                                    Rectangle {
                                        height: 22
                                        radius: 4
                                        color: Theme.colMuted
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

                Text {
                    anchors.centerIn: parent
                    text: "No notifications"
                    color: Theme.colFg
                    font.pixelSize: Theme.fontSize
                    visible: NotificationsData.historyModel.count === 0
                }
            }
        }
    }
}
