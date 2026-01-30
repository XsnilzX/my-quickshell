import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.SystemTray

import "../../theme"
import "../../data"

Item {
    id: root
    required property var window
    
    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    Component.onCompleted: TrayProcesses 

    RowLayout {
        id: trayRow
        spacing: Theme.spacing || 8

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItemWrapper
                required property var modelData

                readonly property int iconSize: Theme.itemHeight - 12
                readonly property var trayItem: modelData

                readonly property string tooltipText: {
                    var title = trayItem.tooltipTitle || trayItem.title || ""
                    var desc = trayItem.tooltipDescription || ""
                    return title && desc ? `${title}\n${desc}` : (title || desc)
                }

                Layout.preferredWidth: iconSize
                Layout.preferredHeight: iconSize
                Layout.alignment: Qt.AlignVCenter

                Image {
                    id: trayIcon
                    anchors.fill: parent
                    source: trayItem.icon
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width, height)
                    smooth: true
                    antialiasing: true
                    cache: false
                }

                HoverHandler {
                    id: hover
                }

                ToolTip.visible: hover.hovered && tooltipText.length > 0
                ToolTip.text: tooltipText

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        if (trayItem.onlyMenu && trayItem.hasMenu) {
                            trayItem.display(root.window, point.position.x, point.position.y)
                        } else {
                            trayItem.activate()
                        }
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: {
                        if (trayItem.hasMenu) {
                            trayItem.display(root.window, point.position.x, point.position.y)
                        }
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.MiddleButton
                    onTapped: trayItem.secondaryActivate()
                }

                WheelHandler {
                    onWheel: event => {
                        trayItem.scroll(event.angleDelta.y, false)
                    }
                }
            }
        }
    }
}
