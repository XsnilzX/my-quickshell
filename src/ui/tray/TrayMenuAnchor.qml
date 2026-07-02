import QtQuick
import Quickshell

Item {
    id: root
    required property var panelWindow
    required property var trayItem
    property bool usePreparedAnchor: false

    property int anchorX: 0
    property int anchorY: 0

    function open() {
        if (!trayItem || !panelWindow)
            return

        if (usePreparedAnchor && trayItem.menu) {
            preparedMenuAnchor.open()
            return
        }

        if (trayItem.hasMenu)
            trayItem.display(panelWindow, anchorX, anchorY)
    }

    QsMenuAnchor {
        id: preparedMenuAnchor
        menu: root.trayItem ? root.trayItem.menu : null
        anchor.window: root.panelWindow
        anchor.rect.x: root.anchorX
        anchor.rect.y: root.anchorY
        anchor.rect.width: 1
        anchor.rect.height: 1
    }
}
