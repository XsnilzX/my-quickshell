import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
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

                readonly property bool hasMenuHandle: trayItem.hasMenu && !!trayItem.menu

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

                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.menu

                    anchor {
                        item: trayItemWrapper
                        edges: Edges.Bottom | Edges.Left
                        gravity: Edges.Bottom | Edges.Right
                    }
                }

                ToolTip.visible: hover.hovered && tooltipText.length > 0
                ToolTip.text: tooltipText

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    function menuPosition(mouse) {
                        if (!root.window || !root.window.contentItem)
                            return Qt.point(Math.round(mouse.x), Math.round(mouse.y))

                        const pos = trayItemWrapper.mapToItem(root.window.contentItem, mouse.x, mouse.y)
                        return Qt.point(Math.round(pos.x), Math.round(pos.y))
                    }

                    function showMenu(mouse) {
                        if (!trayItem.hasMenu && !trayItem.onlyMenu)
                            return

                        if (trayItemWrapper.hasMenuHandle) {
                            if (mouse && mouse.button === Qt.LeftButton && menuAnchor.visible) {
                                menuAnchor.close()
                            } else {
                                menuAnchor.open()
                            }
                            return
                        }

                        if (!root.window)
                            return

                        const pos = menuPosition(mouse)
                        trayItem.display(root.window, pos.x, pos.y)
                    }

                    onPressed: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            if (trayItem.hasMenu || trayItem.onlyMenu) {
                                showMenu(mouse)
                            } else if (trayItem.activate) {
                                trayItem.activate()
                            }
                        } else if (mouse.button === Qt.RightButton) {
                            showMenu(mouse)
                        } else if (mouse.button === Qt.MiddleButton && trayItem.secondaryActivate) {
                            trayItem.secondaryActivate()
                        }
                    }
                }

                WheelHandler {
                    onWheel: event => {
                        if (trayItem.scroll)
                            trayItem.scroll(event.angleDelta.y, false)
                    }
                }
            }
        }
    }
}
