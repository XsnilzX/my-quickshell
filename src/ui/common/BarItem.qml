import QtQuick

import "../../theme"

Rectangle {
    property alias text: label.text
    property alias textColor: label.color

    height: Theme.itemHeight
    radius: Theme.itemRadius
    color: Theme.colMuted
    width: label.implicitWidth + 24

    Text {
        id: label
        anchors.centerIn: parent
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
            bold: true
        }
    }
}
