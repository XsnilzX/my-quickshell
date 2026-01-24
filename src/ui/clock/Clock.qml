import QtQuick
import QtQuick.Layouts

import "../common"
import "../../theme"

Item {
    Layout.preferredWidth: clockItem.implicitWidth
    Layout.fillHeight: true

    BarItem {
        id: clockItem
        anchors.centerIn: parent
        text: Qt.formatTime(new Date(), "HH:mm")
        textColor: Theme.colFg
    }
}
