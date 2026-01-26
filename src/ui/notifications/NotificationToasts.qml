import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import "../../data"

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    color: "transparent"
    exclusiveZone: 0
    visible: NotificationsData.toastModel.count > 0

    WlrLayershell.layer: WlrLayer.Overlay

    implicitWidth: toastColumn.implicitWidth
    implicitHeight: toastColumn.implicitHeight


    ColumnLayout {
        id: toastColumn
        spacing: 8
        anchors.margins: 10

        Repeater {
            model: NotificationsData.toastModel

            NotificationToast {
                entry: model.entry
            }
        }
    }
}
