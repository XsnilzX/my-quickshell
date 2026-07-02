pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    readonly property bool enabled: Quickshell.env("MYQS_ENABLE_NOTIFICATIONS") !== "0"
    readonly property int historyLimit: {
        var rawValue = Quickshell.env("MYQS_NOTIFICATION_HISTORY_LIMIT")
        var parsedValue = parseInt(rawValue || "100")
        return isNaN(parsedValue) ? 100 : Math.max(1, parsedValue)
    }

    property var activeNotifications: []
    property var historyNotifications: []
    property int unreadCount: 0
    property int visibleHistoryCount: 0

    function normalizeNotification(notification) {
        return {
            id: notification.id,
            notification: notification,
            unread: !notification.lastGeneration,
            bubbleVisible: !notification.lastGeneration,
            closed: false,
            isTransient: notification.transient,
            createdAt: Date.now(),
            lock: retainableLockComponent.createObject(root, {
                object: notification,
                locked: true
            }),
            connection: notificationConnectionComponent.createObject(root, {
                entry: null
            })
        }
    }

    function notificationIndexById(notificationId) {
        for (var i = 0; i < historyNotifications.length; i++) {
            if (historyNotifications[i].id === notificationId)
                return i
        }

        return -1
    }

    function refreshActiveNotifications() {
        var nextActive = []

        for (var i = 0; i < historyNotifications.length; i++) {
            var entry = historyNotifications[i]
            if (entry.bubbleVisible && !entry.closed)
                nextActive.push(entry)
        }

        activeNotifications = nextActive
        updateUnreadCount()
    }

    function updateUnreadCount() {
        var total = 0
        var historyTotal = 0

        for (var i = 0; i < historyNotifications.length; i++) {
            if (!historyNotifications[i].isTransient)
                historyTotal++

            if (historyNotifications[i].unread && !historyNotifications[i].isTransient)
                total++
        }

        visibleHistoryCount = historyTotal
        unreadCount = total
    }

    function trimHistory() {
        if (historyNotifications.length <= historyLimit)
            return

        var nextHistory = historyNotifications.slice()

        while (nextHistory.length > historyLimit) {
            var removedEntry = nextHistory.pop()
            cleanupEntry(removedEntry)
        }

        historyNotifications = nextHistory
        refreshActiveNotifications()
    }

    function addNotification(notification) {
        var currentIndex = notificationIndexById(notification.id)
        if (currentIndex !== -1) {
            var replacedEntry = historyNotifications[currentIndex]
            cleanupEntry(replacedEntry)

            var withoutOldEntry = historyNotifications.slice()
            withoutOldEntry.splice(currentIndex, 1)
            historyNotifications = withoutOldEntry
        }

        notification.tracked = true

        var entry = normalizeNotification(notification)
        entry.connection.entry = entry

        var nextHistory = historyNotifications.slice()
        nextHistory.unshift(entry)

        historyNotifications = nextHistory
        refreshActiveNotifications()
        trimHistory()
    }

    function cleanupEntry(entry) {
        if (!entry)
            return

        if (entry.connection) {
            entry.connection.destroy()
            entry.connection = null
        }

        if (entry.lock) {
            entry.lock.destroy()
            entry.lock = null
        }
    }

    function expireBubble(entry) {
        if (!entry || entry.closed || !entry.bubbleVisible)
            return

        entry.bubbleVisible = false
        refreshActiveNotifications()
    }

    function handleClosed(entry) {
        if (!entry)
            return

        entry.closed = true
        entry.bubbleVisible = false
        refreshActiveNotifications()
    }

    function invokePrimaryAction(entry) {
        if (!entry || entry.closed)
            return false

        var actions = entry.notification.actions || []
        if (actions.length === 0)
            return false

        entry.unread = false
        actions[0].invoke()
        refreshActiveNotifications()
        return true
    }

    function dismiss(entry) {
        if (!entry)
            return

        var nextHistory = []
        for (var i = 0; i < historyNotifications.length; i++) {
            if (historyNotifications[i] !== entry)
                nextHistory.push(historyNotifications[i])
        }
        historyNotifications = nextHistory
        refreshActiveNotifications()

        if (!entry.closed && entry.notification)
            entry.notification.dismiss()

        cleanupEntry(entry)
    }

    function dismissAll() {
        var existingEntries = historyNotifications.slice()
        historyNotifications = []
        activeNotifications = []
        unreadCount = 0

        for (var i = 0; i < existingEntries.length; i++) {
            var entry = existingEntries[i]
            if (!entry.closed && entry.notification)
                entry.notification.dismiss()
            cleanupEntry(entry)
        }
    }

    function markAllRead() {
        for (var i = 0; i < historyNotifications.length; i++)
            historyNotifications[i].unread = false

        refreshActiveNotifications()
    }

    function activateEntry(entry) {
        if (!entry)
            return

        entry.unread = false

        if (!invokePrimaryAction(entry))
            dismiss(entry)
        else
            refreshActiveNotifications()
    }

    Component {
        id: retainableLockComponent

        RetainableLock {
            locked: true
        }
    }

    Component {
        id: notificationConnectionComponent

        Connections {
            required property var entry
            target: entry ? entry.notification : null

            function onClosed() {
                root.handleClosed(entry)
            }
        }
    }

    NotificationServer {
        id: notificationServer
        bodySupported: true
        actionsSupported: true
        persistenceSupported: true
        keepOnReload: true
        inlineReplySupported: false
        bodyMarkupSupported: false
        bodyImagesSupported: false
        bodyHyperlinksSupported: false
        actionIconsSupported: false
        imageSupported: false

        function shouldTrack(notification) {
            if (!root.enabled)
                return false

            if (notification.lastGeneration)
                notification.tracked = true

            return true
        }

        onNotification: notification => {
            if (!shouldTrack(notification))
                return

            root.addNotification(notification)
        }
    }
}
