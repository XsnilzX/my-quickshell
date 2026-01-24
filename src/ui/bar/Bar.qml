import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../workspaces"
import "../clock"
import "../system"
import "../audio"
import "../common"

Item {
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
                    spacing: 16

                    SystemStats { }

                    AudioWidget { }

                    Separator { }
                }
            }
        }
    }
}
