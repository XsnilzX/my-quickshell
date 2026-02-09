import QtQuick
import QtQuick.Layouts

import Quickshell

Item {
    readonly property string backend: (Quickshell.env("MYQS_WORKSPACE_BACKEND") || "hyprland").toLowerCase()

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight: loader.item ? loader.item.implicitHeight : 0

    Layout.preferredWidth: implicitWidth
    Layout.fillHeight: true

    Loader {
        id: loader
        anchors.fill: parent
        source: backend === "niri"
            ? "WorkspaceSwitcherNiri.qml"
            : "WorkspaceSwitcherHyprland.qml"
    }
}
