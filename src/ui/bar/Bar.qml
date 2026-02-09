import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../workspaces"
import "../clock"
import "../weather"
import "../system"
import "../audio"
import "../tray"
import "../common"

Item {
    id: bar
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing || 8
        anchors.rightMargin: Theme.spacing || 8
        spacing: 0

        WorkspaceSwitcher {
            Layout.preferredWidth: implicitWidth
            Layout.fillHeight: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Clock { }

                Weather { }
            }
        }

        Item {
            Layout.preferredWidth: statusBox.width
            Layout.fillHeight: true

            Rectangle {
                id: statusBox
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

                    AudioWidget { }

                    Tray {
                        window: bar
                    }

                    //Separator { }
                }
            }
        }
    }
}
