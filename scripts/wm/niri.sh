#!/usr/bin/env bash

function workspace::focus() {
    local ACTIVE_OUTPUT="$(workspace::list_by_output | jq -r 'add | .[] | select(.focused) | .output')"
    local NEW_OUTPUT="$(echo $1 | cut -d: -f1)"
    if [[ "${ACTIVE_OUTPUT}" != "${NEW_OUTPUT}" ]]; then
        # Only call `focus-monitor` if it's a new monitor (avoids centering the mouse)
        niri msg action focus-monitor "${NEW_OUTPUT}" >/dev/null
    fi
    local IDX="$(echo $1 | cut -d: -f2)"
    niri msg action focus-workspace "$IDX" >/dev/null
}

function workspace::list_by_output() {
    # Returns a JSON list of workspaces, grouped by output:
    # E.g.
    # [
    #   [
    #     {
    #       "visible": false,   -- Whether the workspace is visible
    #       "focused": false,   -- Whether the workspace has focus
    #       "output": "DP-1",   -- Name of the output this workspace is on
    #       "name": 1,          -- Name to display for this workspace
    #       "key": "DP-1:1"     -- Input key to focus this workspace (see `workspace::focus`)
    #     },
    #     {
    #       "visible": false,
    #       "focused": false,
    #       "output": "DP-1",
    #       "name": 2,
    #       "key": "DP-1:2"
    #     }
    #   ],
    #   [
    #     {
    #       "visible": false,
    #       "focused": false,
    #       "output": "HDMI-A-1",
    #       "name": 1,
    #       "key": "HDMI-A-1:1"
    #     }
    #   ]
    # ]
    #
    # Uses ".output:.idx" as the workspace key (note ":" as delimiter)
    echo $(niri msg -j workspaces |
        jq 'sort_by(.idx) | .[] | {visible:.is_active, focused:.is_focused, output:.output, name:.idx, key:"\(.output):\(.idx)"}' |
        jq -jcs 'group_by(.output)'
    )
}

function workspace::focus_subscriber() {
    workspace::list_by_output
    niri msg -j event-stream |
        grep --line-buffered "WorkspaceActivated" |
        while read -r event; do workspace::list_by_output; done
}
