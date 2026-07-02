pragma Singleton

import QtQuick
import Quickshell

import "."

Item {
    id: root

    readonly property bool notificationsEnabled: Quickshell.env("MYQS_ENABLE_NOTIFICATIONS") !== "0"
    readonly property bool quickSettingsEnabled: Quickshell.env("MYQS_ENABLE_QUICK_SETTINGS") !== "0"
    readonly property bool osdEnabled: Quickshell.env("MYQS_ENABLE_OSD") !== "0"

    property bool notificationCenterOpen: false
    property bool quickSettingsOpen: false

    property bool volumeOsdVisible: false
    property int volumeOsdValue: 0
    property bool volumeOsdMuted: false

    property bool brightnessOsdVisible: false
    property int brightnessOsdValue: 0

    property bool powerProfileOsdVisible: false
    property string powerProfileOsdValue: ""

    property bool hasSeenSinkState: false
    property bool hasSeenBrightnessState: false
    property bool hasSeenPowerProfileState: false

    function toggleNotificationCenter() {
        if (!notificationsEnabled)
            return

        notificationCenterOpen = !notificationCenterOpen
        if (notificationCenterOpen) {
            quickSettingsOpen = false
            NotificationsData.markAllRead()
        }
    }

    function toggleQuickSettings() {
        if (!quickSettingsEnabled)
            return

        quickSettingsOpen = !quickSettingsOpen
        if (quickSettingsOpen)
            notificationCenterOpen = false
    }

    function closeAllTransientUi() {
        notificationCenterOpen = false
        quickSettingsOpen = false
    }

    function showVolumeOsd(volume, muted) {
        if (!osdEnabled)
            return

        volumeOsdValue = volume
        volumeOsdMuted = muted
        volumeOsdVisible = true
        volumeOsdTimer.restart()
    }

    function showBrightnessOsd(value) {
        if (!osdEnabled)
            return

        brightnessOsdValue = value
        brightnessOsdVisible = true
        brightnessOsdTimer.restart()
    }

    function showPowerProfileOsd(profile) {
        if (!osdEnabled || !profile)
            return

        powerProfileOsdValue = profile
        powerProfileOsdVisible = true
        powerProfileTimer.restart()
    }

    Timer {
        id: volumeOsdTimer
        interval: 1500
        repeat: false
        onTriggered: root.volumeOsdVisible = false
    }

    Timer {
        id: brightnessOsdTimer
        interval: 1500
        repeat: false
        onTriggered: root.brightnessOsdVisible = false
    }

    Timer {
        id: powerProfileTimer
        interval: 1500
        repeat: false
        onTriggered: root.powerProfileOsdVisible = false
    }

    Connections {
        target: SystemData

        function onSinkVolumeChanged() {
            if (!root.hasSeenSinkState) {
                root.hasSeenSinkState = true
                return
            }

            root.showVolumeOsd(SystemData.sinkVolume, SystemData.sinkMuted)
        }

        function onSinkMutedChanged() {
            if (!root.hasSeenSinkState) {
                root.hasSeenSinkState = true
                return
            }

            root.showVolumeOsd(SystemData.sinkVolume, SystemData.sinkMuted)
        }

        function onBrightPercentChanged() {
            if (!root.hasSeenBrightnessState) {
                root.hasSeenBrightnessState = true
                return
            }

            root.showBrightnessOsd(SystemData.brightPercent)
        }

        function onPowerProfileChanged() {
            if (!root.hasSeenPowerProfileState) {
                root.hasSeenPowerProfileState = true
                return
            }

            root.showPowerProfileOsd(SystemData.powerProfile)
        }
    }
}
