import QtQuick

import "../../theme"

Rectangle {
    property alias text: label.text
    property alias textColor: label.color
    property int maxWidth: -1

    height: Theme.itemHeight
    radius: Theme.itemRadius
    color: Theme.colMuted
    width: maxWidth > 0 ? Math.min(label.implicitWidth + 24, maxWidth) : label.implicitWidth + 24

    Text {
        id: label
        anchors.centerIn: parent
        width: parent.width - 24
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
            bold: true
        }
    }
}
