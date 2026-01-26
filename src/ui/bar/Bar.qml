import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../data"
import "../workspaces"
import "../clock"
import "../system"
import "../audio"
import "../notifications"
import "../common"

Item {
    id: root

    property QtObject panelWindow

    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 0

        WorkspaceSwitcher { }

        Clock { }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.colMuted
                radius: Theme.itemRadius
                height: Theme.itemHeight
                width: statusRow.implicitWidth + 24

                RowLayout {
                    id: statusRow
                    anchors.centerIn: parent
                    spacing: 8

                    SystemStats { }

                    NotificationIcon {
                        panelWindow: root.panelWindow
                    }

                    AudioWidget { }

                    //Separator { }
                }
            }
        }
    }
}
