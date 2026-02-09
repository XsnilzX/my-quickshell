import QtQuick

import "../../theme"

Rectangle {
    property alias text: label.text
    property alias textColor: label.color
    property int maxWidth: -1
    property bool truncateText: false

    height: Theme.itemHeight
    radius: Theme.itemRadius
    color: Theme.colMuted
    width: maxWidth >= 0 ? Math.min(label.implicitWidth + 24, maxWidth) : label.implicitWidth + 24

    Text {
        id: label
        anchors.centerIn: parent
        width: truncateText ? parent.width - 24 : implicitWidth
        horizontalAlignment: Text.AlignHCenter
        elide: truncateText ? Text.ElideRight : Text.ElideNone
        wrapMode: Text.NoWrap
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
            bold: true
        }
    }
}
