import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../data"

Item {
    id: root

    property QtObject panelWindow
    property bool useEmojiFallback: false

    readonly property string bellOutlineGlyph: "\uf0f3"
    readonly property string bellBadgeGlyph: "\uf0f2"
    readonly property string bellOffGlyph: "\uf0f4"
    readonly property string bellEmoji: "🔔"
    readonly property string bellOffEmoji: "🔕"

    readonly property string iconFontPrimary: "Symbols Nerd Font"
    readonly property string iconFontFallback: "Hack Nerd Font Mono"

    implicitHeight: Theme.itemHeight
    implicitWidth: iconRow.implicitWidth

    function iconText() {
        if (useEmojiFallback) {
            return NotificationsData.doNotDisturb ? bellOffEmoji : bellEmoji
        }
        if (NotificationsData.doNotDisturb)
            return bellOffGlyph
        if (NotificationsData.counter > 0)
            return bellBadgeGlyph
        return bellOutlineGlyph
    }

    RowLayout {
        id: iconRow
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: iconTextItem
            text: iconText()
            color: Theme.colFg
            font.family: iconFontPrimary
            font.pixelSize: Theme.fontSize

            Component.onCompleted: {
                if (font.family !== iconFontPrimary)
                    font.family = iconFontFallback
            }
        }

        Rectangle {
            id: badge
            visible: NotificationsData.counter > 0
            color: Theme.colRed
            radius: 8
            height: 16
            Layout.preferredWidth: Math.max(16, badgeText.implicitWidth + 8)

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: NotificationsData.counter
                color: Theme.colFg
                font.pixelSize: Theme.fontSize - 3
                font.bold: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                NotificationsData.toggleDnd()
            } else {
                NotificationsData.centerVisible = true
            }
        }
    }

    NotificationCenterOverlay {
        id: centerOverlay
        visible: NotificationsData.centerVisible
        onDismissRequested: NotificationsData.centerVisible = false
    }

    NotificationCenter {
        id: center
        anchorItem: root
        anchorWindow: panelWindow
        visible: NotificationsData.centerVisible
    }
}
