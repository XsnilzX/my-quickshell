import QtQuick
import Quickshell

import "data"
import "theme"
import "ui/bar"
import "ui/notifications"
import "ui/osd"
import "ui/quicksettings"

Scope {
    id: root

    PanelWindow {
        id: panelWindow

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: Theme.barHeight
        color: "transparent"
        exclusiveZone: Theme.barHeight + 2

        Bar {
            anchors.fill: parent
            panelWindow: panelWindow
        }
    }

    NotificationOverlay {
        panelWindow: panelWindow
    }

    PopupWindow {
        anchor.window: panelWindow
        anchor.rect.x: panelWindow.width - width - Theme.spacing
        anchor.rect.y: panelWindow.height + Theme.spacing
        implicitWidth: notificationCenter.width
        implicitHeight: notificationCenter.height
        visible: ShellUiState.notificationCenterOpen
        color: "transparent"
        grabFocus: true
        onVisibleChanged: {
            if (!visible)
                ShellUiState.notificationCenterOpen = false
        }

        NotificationCenter {
            id: notificationCenter
        }
    }

    PopupWindow {
        anchor.window: panelWindow
        anchor.rect.x: panelWindow.width - width - Theme.spacing
        anchor.rect.y: panelWindow.height + Theme.spacing
        implicitWidth: quickSettings.width
        implicitHeight: quickSettings.implicitHeight
        visible: ShellUiState.quickSettingsOpen
        color: "transparent"
        grabFocus: true
        onVisibleChanged: {
            if (!visible)
                ShellUiState.quickSettingsOpen = false
        }

        QuickSettingsPopup {
            id: quickSettings
        }
    }

    PopupWindow {
        anchor.window: panelWindow
        anchor.rect.x: Math.round((panelWindow.width - width) / 2)
        anchor.rect.y: panelWindow.height + 20
        implicitWidth: Theme.osdWidth
        implicitHeight: volumeOsd.implicitHeight
        visible: ShellUiState.volumeOsdVisible
        color: "transparent"

        VolumeOsd {
            id: volumeOsd
        }
    }

    PopupWindow {
        anchor.window: panelWindow
        anchor.rect.x: Math.round((panelWindow.width - width) / 2)
        anchor.rect.y: panelWindow.height + 20
        implicitWidth: Theme.osdWidth
        implicitHeight: brightnessOsd.implicitHeight
        visible: ShellUiState.brightnessOsdVisible
        color: "transparent"

        BrightnessOsd {
            id: brightnessOsd
        }
    }

    PopupWindow {
        anchor.window: panelWindow
        anchor.rect.x: Math.round((panelWindow.width - width) / 2)
        anchor.rect.y: panelWindow.height + 20
        implicitWidth: Theme.osdWidth
        implicitHeight: powerOsd.implicitHeight
        visible: ShellUiState.powerProfileOsdVisible
        color: "transparent"

        PowerProfileOsd {
            id: powerOsd
        }
    }
}
