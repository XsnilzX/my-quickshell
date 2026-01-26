pragma Singleton

import QtCore
import QtQuick

import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: root

    property bool doNotDisturb: false
    property bool centerVisible: false
    property int counter: 0
    property int maxToasts: 5
    property int centerX: 0
    property int centerY: 0
    property int centerWidth: 0
    property int centerHeight: 0

    readonly property string cacheDir: StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + "/my-quickshell"
    readonly property string cachePath: cacheDir + "/notifications.json"

    readonly property alias historyModel: historyModel
    readonly property alias toastModel: toastModel

    property var cachedNotifications: []

    function toggleDnd() {
        doNotDisturb = !doNotDisturb
    }

    function markAllSeen() {
        for (var index = 0; index < historyModel.count; index++) {
            var entry = historyModel.get(index)
            if (entry.origin === "runtime" && !entry.isSeen) {
                historyModel.setProperty(index, "isSeen", true)
            }
        }
        saveCache()
    }

    function setCenterRect(x, y, width, height) {
        centerX = Math.round(x)
        centerY = Math.round(y)
        centerWidth = Math.round(width)
        centerHeight = Math.round(height)
    }

    function clearAll() {
        var runtimeNotifications = []
        for (var index = 0; index < historyModel.count; index++) {
            var entry = historyModel.get(index)
            if (entry.origin === "runtime" && entry.notification) {
                runtimeNotifications.push(entry.notification)
            }
        }

        for (var notifyIndex = 0; notifyIndex < runtimeNotifications.length; notifyIndex++) {
            runtimeNotifications[notifyIndex].dismiss()
        }

        historyModel.clear()
        toastModel.clear()
        counter = 0
        saveCache()
    }

    function dismissById(notificationId) {
        var historyIndex = findHistoryIndex(notificationId)
        if (historyIndex < 0)
            return

        var entry = historyModel.get(historyIndex)
        if (entry.notification) {
            entry.notification.dismiss()
        } else {
            historyModel.remove(historyIndex)
            saveCache()
        }
    }

    function sanitizeRichText(body) {
        if (!body)
            return ""

        return body.replace(/<\s*(\/?)\s*([a-zA-Z0-9]+)([^>]*)>/g, function(match, closing, tagName, attributes) {
            var tag = tagName.toLowerCase()
            if (tag === "b" || tag === "i" || tag === "u") {
                return "<" + (closing ? "/" : "") + tag + ">"
            }
            if (tag === "br")
                return "<br>"
            if (tag === "a") {
                if (closing)
                    return "</a>"

                var hrefMatch = attributes.match(/href\s*=\s*(\"([^\"]*)\"|'([^']*)'|([^\s>]+))/i)
                if (!hrefMatch)
                    return ""

                var href = hrefMatch[2] || hrefMatch[3] || hrefMatch[4] || ""
                var trimmedHref = href.trim()
                var lowerHref = trimmedHref.toLowerCase()
                if (!trimmedHref || lowerHref.startsWith("javascript:") || lowerHref.startsWith("data:") || lowerHref.startsWith("vbscript:"))
                    return ""

                return "<a href=\"" + trimmedHref.replace(/\"/g, "&quot;") + "\">"
            }
            return ""
        })
    }

    function addNotification(notification) {
        notification.tracked = true

        var entry = buildRuntimeEntry(notification)
        historyModel.insert(0, entry)
        counter += 1

        if (!doNotDisturb || notification.urgency === NotificationUrgency.Critical) {
            addToast(notification, entry)
        }

        notification.closed.connect(function(reason) {
            handleClosed(notification, reason)
        })

        saveCache()
    }

    function addToast(notification, entry) {
        if (toastModel.count >= maxToasts) {
            var oldestToast = toastModel.get(0)
            if (oldestToast.notification) {
                oldestToast.notification.expire()
            }
            toastModel.remove(0)
        }

        toastModel.insert(0, {
            notificationId: entry.notificationId,
            notification: notification,
            entry: entry
        })
    }

    function handleClosed(notification, reason) {
        removeToastById(notification.id)

        var historyIndex = findHistoryIndex(notification.id)
        if (historyIndex < 0) {
            saveCache()
            return
        }

        var entry = historyModel.get(historyIndex)
        if (reason === NotificationCloseReason.Expired) {
            historyModel.setProperty(historyIndex, "isSeen", true)
            saveCache()
            return
        }

        if (entry.origin === "runtime" && counter > 0)
            counter -= 1

        historyModel.remove(historyIndex)
        saveCache()
    }

    function removeToastById(notificationId) {
        for (var index = 0; index < toastModel.count; index++) {
            if (toastModel.get(index).notificationId === notificationId) {
                toastModel.remove(index)
                return
            }
        }
    }

    function findHistoryIndex(notificationId) {
        for (var index = 0; index < historyModel.count; index++) {
            if (historyModel.get(index).notificationId === notificationId)
                return index
        }
        return -1
    }

    function buildRuntimeEntry(notification) {
        return {
            notificationId: notification.id,
            appName: notification.appName,
            summary: notification.summary,
            body: notification.body,
            icon: resolveIcon(notification),
            urgency: notification.urgency,
            actions: serializeActions(notification.actions),
            timestamp: Date.now(),
            timeoutMs: resolveTimeout(notification),
            isPersistent: notification.resident || notification.urgency === NotificationUrgency.Critical,
            isSeen: false,
            origin: "runtime",
            notification: notification
        }
    }

    function resolveIcon(notification) {
        if (notification.image && notification.image.length > 0)
            return notification.image
        if (notification.appIcon && notification.appIcon.length > 0)
            return notification.appIcon
        return ""
    }

    function resolveTimeout(notification) {
        if (notification.urgency === NotificationUrgency.Critical || notification.resident)
            return 0
        if (notification.expireTimeout > 0)
            return Math.round(notification.expireTimeout * 1000)
        if (notification.urgency === NotificationUrgency.Low)
            return 4000
        return 8000
    }

    function serializeActions(actions) {
        var serialized = []
        if (!actions)
            return serialized

        for (var index = 0; index < actions.length; index++) {
            var action = actions[index]
            serialized.push({
                identifier: action.identifier,
                text: action.text
            })
        }
        return serialized
    }

    function urgencyFromString(value) {
        switch (value) {
        case "Low":
            return NotificationUrgency.Low
        case "Critical":
            return NotificationUrgency.Critical
        default:
            return NotificationUrgency.Normal
        }
    }

    function saveCache() {
        var entries = []
        for (var index = 0; index < historyModel.count; index++) {
            var entry = historyModel.get(index)
            entries.push({
                notificationId: entry.notificationId,
                appName: entry.appName,
                summary: entry.summary,
                body: entry.body,
                icon: entry.icon,
                urgency: NotificationUrgency.toString(entry.urgency),
                actions: entry.actions || [],
                timestamp: entry.timestamp,
                timeoutMs: entry.timeoutMs,
                isPersistent: entry.isPersistent,
                isSeen: entry.isSeen,
                isDismissed: true
            })
        }

        cacheAdapter.notifications = entries.slice(0, 150)
        cacheFile.writeAdapter()
    }

    function loadCache() {
        var entries = cacheAdapter.notifications || []
        if (!Array.isArray(entries))
            return

        historyModel.clear()
        for (var index = 0; index < entries.length; index++) {
            var entry = entries[index]
            historyModel.append({
                notificationId: entry.notificationId,
                appName: entry.appName || "",
                summary: entry.summary || "",
                body: entry.body || "",
                icon: entry.icon || "",
                urgency: urgencyFromString(entry.urgency),
                actions: entry.actions || [],
                timestamp: entry.timestamp || 0,
                timeoutMs: 0,
                isPersistent: entry.isPersistent === true,
                isSeen: entry.isSeen === true,
                origin: "disk",
                notification: null
            })
        }
    }

    Component.onCompleted: ensureCacheDir.running = true

    Process {
        id: ensureCacheDir
        command: ["sh", "-c", "mkdir -p \"" + cacheDir + "\""]
    }

    FileView {
        id: cacheFile
        path: cachePath
        preload: true
        printErrors: false

        JsonAdapter {
            id: cacheAdapter
            property var notifications: []
        }

        onLoaded: loadCache()
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: false

        onNotification: notification => {
            addNotification(notification)
        }
    }

    ListModel {
        id: historyModel
    }

    ListModel {
        id: toastModel
    }
}
