import QtQuick
import QtQuick.Layouts

import Quickshell.Io

import "../../theme"

Item {
    id: root

    property var workspaceIndices: []
    property int activeIndex: -1

    implicitWidth: wsBox.visible ? wsBox.width : 0
    implicitHeight: Theme.itemHeight

    Layout.preferredWidth: implicitWidth
    Layout.fillHeight: true

    function extractWorkspaceList(payload) {
        if (Array.isArray(payload))
            return payload

        if (payload && Array.isArray(payload.workspaces))
            return payload.workspaces

        if (payload && payload.Ok) {
            if (Array.isArray(payload.Ok))
                return payload.Ok
            if (Array.isArray(payload.Ok.workspaces))
                return payload.Ok.workspaces
            if (Array.isArray(payload.Ok.Workspaces))
                return payload.Ok.Workspaces
        }

        if (payload && Array.isArray(payload.Workspaces))
            return payload.Workspaces

        return []
    }

    function workspaceOutputName(workspace) {
        if (!workspace)
            return ""

        return workspace.output
            || workspace.output_name
            || workspace.outputName
            || workspace.monitor
            || ""
    }

    function workspaceSortValue(workspace) {
        if (!workspace)
            return Number.MAX_SAFE_INTEGER

        if (!isNaN(workspace.idx))
            return parseInt(workspace.idx)
        if (!isNaN(workspace.index))
            return parseInt(workspace.index)
        if (!isNaN(workspace.id))
            return parseInt(workspace.id)

        return Number.MAX_SAFE_INTEGER
    }

    function workspaceIsFocused(workspace) {
        if (!workspace)
            return false

        return workspace.is_focused === true
            || workspace.isFocused === true
            || workspace.focused === true
    }

    function updateState(output) {
        if (!output)
            return

        var payload
        try {
            payload = JSON.parse(output)
        } catch (error) {
            return
        }

        var allWorkspaces = extractWorkspaceList(payload)
        if (!allWorkspaces || allWorkspaces.length === 0)
            return

        var focusedWorkspace = allWorkspaces.find(workspace => workspaceIsFocused(workspace))
        var focusedOutput = workspaceOutputName(focusedWorkspace)

        var scopedWorkspaces = allWorkspaces
        if (focusedOutput.length > 0) {
            scopedWorkspaces = allWorkspaces.filter(
                workspace => workspaceOutputName(workspace) === focusedOutput
            )
        }

        var sortedWorkspaces = scopedWorkspaces.slice().sort(
            (left, right) => workspaceSortValue(left) - workspaceSortValue(right)
        )

        workspaceIndices = sortedWorkspaces.map((workspace, idx) => idx + 1)

        activeIndex = sortedWorkspaces.findIndex(workspace => workspaceIsFocused(workspace)) + 1
    }

    Rectangle {
        id: wsBox
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.colMuted
        radius: Theme.itemRadius
        height: Theme.itemHeight
        width: wsRow.implicitWidth + 24

        visible: root.workspaceIndices.length > 0

        RowLayout {
            id: wsRow
            anchors.centerIn: parent
            spacing: 12

            Repeater {
                model: root.workspaceIndices.length

                Text {
                    readonly property int workspaceId: root.workspaceIndices[index]
                    readonly property bool isActive: root.activeIndex === workspaceId

                    text: workspaceId
                    color: isActive ? Theme.colBlue : Theme.colFg

                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize
                        bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        onClicked: {
                            focusProc.targetIndex = workspaceId
                            focusProc.running = true
                        }
                    }
                }
            }
        }
    }

    Process {
        id: workspacesProc
        command: ["niri", "msg", "--json", "workspaces"]

        stdout: StdioCollector {
            onStreamFinished: root.updateState(this.text.trim())
        }
    }

    Process {
        id: focusProc
        property int targetIndex: -1

        command: [
            "niri",
            "msg",
            "action",
            "focus-workspace",
            targetIndex.toString()
        ]

        onExited: workspacesProc.running = true
    }

    Timer {
        interval: 700
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: workspacesProc.running = true
    }
}
