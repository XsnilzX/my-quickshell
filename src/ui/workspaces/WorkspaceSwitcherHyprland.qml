import QtQuick
import QtQuick.Layouts

import Quickshell.Hyprland

import "../../theme"

Item {
    implicitWidth: wsBox.width
    implicitHeight: Theme.itemHeight

    Layout.preferredWidth: implicitWidth
    Layout.fillHeight: true

    Rectangle {
        id: wsBox
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.colMuted
        radius: Theme.itemRadius
        height: Theme.itemHeight
        width: wsRow.implicitWidth + 24

        RowLayout {
            id: wsRow
            anchors.centerIn: parent
            spacing: 12

            Repeater {
                model: 10

                Text {
                    readonly property int workspaceId: index + 1
                    property var workspace: Hyprland.workspaces.values.find(
                        w => w.id === workspaceId
                    )
                    property bool isActive: Hyprland.focusedWorkspace?.id === workspaceId

                    visible: isActive || workspace !== undefined

                    Layout.preferredWidth: visible ? implicitWidth : 0
                    Layout.preferredHeight: visible ? implicitHeight : 0

                    text: workspaceId
                    color: isActive ? Theme.colBlue : Theme.colFg

                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize
                        bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        onClicked: Hyprland.dispatch("workspace " + workspaceId)
                    }
                }
            }
        }
    }
}
