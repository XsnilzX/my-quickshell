import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../common"
import "../../data"
import "../../theme"

Item {
    id: weatherRoot

    readonly property bool hasTooltip: GoatherData.tooltip.length > 0

    Layout.preferredWidth: weatherItem.implicitWidth
    Layout.fillHeight: true

    BarItem {
        id: weatherItem
        anchors.centerIn: parent
        text: GoatherData.display
        textColor: Theme.colFg
    }

    HoverHandler {
        id: hover
    }

    ToolTip.visible: hover.hovered && weatherRoot.hasTooltip
    ToolTip.text: GoatherData.tooltip
}
