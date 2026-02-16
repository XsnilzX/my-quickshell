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
    required property var window

    anchors.fill: parent

    readonly property int barMargin: Theme.spacing || 8
    readonly property int blockGap: 8

    readonly property int leftBlockRightEdge: leftBlock.x + leftBlock.width
    readonly property int rightBlockLeftEdge: rightBlock.x
    readonly property int centerAvailableWidth: Math.max(
        0,
        rightBlockLeftEdge - leftBlockRightEdge - (blockGap * 2)
    )
    readonly property int weatherAvailableWidth: Math.max(
        0,
        centerAvailableWidth - centerClock.implicitWidth - centerRow.spacing
    )

    WorkspaceSwitcher {
        id: leftBlock
        anchors.left: parent.left
        anchors.leftMargin: bar.barMargin
        anchors.verticalCenter: parent.verticalCenter
    }

    Item {
        id: rightBlock
        anchors.right: parent.right
        anchors.rightMargin: bar.barMargin
        anchors.verticalCenter: parent.verticalCenter
        width: statusBox.width
        height: statusBox.height

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
                    window: bar.window
                }

                //Separator { }
            }
        }
    }

    Item {
        id: centerBlock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(
            centerClock.implicitWidth,
            Math.min(centerRow.implicitWidth, bar.centerAvailableWidth)
        )
        height: Theme.itemHeight

        RowLayout {
            id: centerRow
            anchors.centerIn: parent
            spacing: 0

            Clock {
                id: centerClock
            }

            Item {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 1
            }

            Weather {
                maxItemWidth: bar.weatherAvailableWidth
                visible: maxItemWidth > 0
            }
        }
    }
}
