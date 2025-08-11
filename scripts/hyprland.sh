#!/usr/bin/env bash

function hypr::event_subscriber() {
    # Reads output from the Hyprland event socket, and outputs in JSON format
    # Only emit events matching the input regex (if provided)
    EVENT_SOCKET="UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    socat -U - "$EVENT_SOCKET" |
        while read -r line; do
            jsonevent="$(echo "$line" | sed -E 's/([a-z1-9]+)>>(.*)/{"event":"\1","data":"\2"}/g')"
            if [[ -n "$1" ]]; then
                echo "$jsonevent" | jq -c "select(.event|test(\"^"$1"\$\"))"
            else
                echo "$jsonevent"
            fi
        done
}

function mode::mode_subscriber() {
    hypr::event_subscriber "submap" | jq -rc --unbuffered .data | sed -u 's/^$/default/g'
}

function workspace::focus() {
    hyprctl dispatch workspace "$1" >/dev/null
}

function workspace::list_by_output() {
    VISIBLE_WORKSPACES="$(hyprctl monitors -j | jq -c '[.[] | .activeWorkspace.id]')"
    hyprctl workspaces -j | jq " sort_by(.id) | .[] | {
        "visible": (.id as \$id | "${VISIBLE_WORKSPACES}" | map(.==\$id) | any),
        "focused": (.id == "$(hyprctl activewindow -j | jq '.workspace.id')"),
        "output": .monitor,
        "name" : .name,
    }" | jq -cs 'group_by(.output)'
}

function workspace::focus_subscriber() {
    workspace::list_by_output
    hypr::event_subscriber "activewindow" |
        while read -r event; do
            workspace::list_by_output
        done
}
#
# function window::get_attributes() {
#     # Usage:
#     #     window::get_attributes [property|property=val ...]
#     #
#     # Returns the specified details of all open windows in json format.
#     # E.g. `window::get_attributes id app_id` will return:
#     #   [
#     #       {"id":7,"app_id":null},
#     #       {"id":12,"app_id":"kitty"},
#     #       {"id":17,"app_id":null}
#     #   ]
#     #
#     # If an equality is given, the detail is treated as a filter.
#     # E.g.  `window::get_attributes id app_id=kitty` will return:
#     #   [
#     #       {"id":12,"app_id":"kitty"}
#     #   ]
#     #
#     # Available properties can be listed by running without arguments
# 
#     # `sed` converts 'a' to '"a":.a', used for jq dict output
#     args=($(
#         echo "$@" | tr ' ' $'\n' |
#         sed -E 's/([a-zA-Z_.]+)=?.*/"\1":.\1/g'
#     ))
#     if [ ${#args} -eq 0 ]; then
#         # Return valid properties if no args are given
#         >&2 echo "Valid Properties:"
#         swaymsg -t get_tree | jq -r '[
#                 recurse(.nodes[]?) | recurse(.floating_nodes[]?) |
#                 select(.type=="con" or .type=="floating_con")
#             ][0] | keys | .[]' | >&2 column
#         return 0
#     fi
#     arg_str="{$(echo "${args[@]}" | tr ' ' ',')}"
# 
#     # 1st `sed` converts 'a=b' to 'select(.a=="b")', used for jq filter
#     # 2nd `sed` removes quotes around numbers and bools
#     filters=($(
#         echo "$@" | tr ' ' $'\n' | grep '=' |
#         sed -E 's/([a-zA-Z_.]+)=([-a-zA-Z0-9_"]+)/select(.\1=="\2")/g' |
#         sed -E 's/="([0-9]+|true|false|True|False)"/=\1/g'
#     ))
#     filter_str=''
#     [ ${#filters} -gt 0 ] && filter_str="$(echo "${filters[@]}" | tr ' ' ',') |"
# 
#     out=$(swaymsg -t get_tree | jq -rc "[
#         recurse(.nodes[]?) |
#         recurse(.floating_nodes[]?) |
#         select(.type==\"con\" or .type==\"floating_con\") |
#         select(.app_id != null or .name != null) |
#         ${filter_str}${arg_str}
#     ]")
# 
#     # Repeat for scratch workspace
#     scratch=$(swaymsg -t get_tree | jq -rc "[
#         recurse(.nodes[]?) | select(.name==\"__i3_scratch\") |
#         recurse(.nodes[]?) | recurse(.floating_nodes[]?) |
#         select(.type==\"con\" or .type==\"floating_con\") |
#         select(.app_id != null or .name != null) |
#         ${filter_str}${arg_str}
#     ]")
# 
#     echo "$out $scratch" | jq -rcs '{"display": .[0], "scratch": .[1]}'
# }
# 
# EWW_SNAPSHOT_DIR="${HOME}/.cache/eww-snapshots"
# function container::snapshot_subscriber() {
#     mkdir -p "$EWW_SNAPSHOT_DIR"
#     rm -f "$EWW_SNAPSHOT_DIR"/*.jpg
#     swaymsg -t subscribe -m '["window"]' |
#         jq --unbuffered -rc '[
#             .change,
#             .container.id,
#             .container.pid,
#             .container.rect.x,
#             .container.rect.y,
#             .container.rect.width,
#             .container.rect.height
#         ] | @tsv' |
#         while read -r line; do
#             line=( $(echo "$line") )
#             event="${line[1]}"
#             if [ "$event" = "focus" ] || [ "$event" = "new" ]; then
#                 window="window-${line[2]}-${line[3]}.jpg"
#                 rect_x="${line[4]}"
#                 rect_y="${line[5]}"
#                 rect_w="${line[6]}"
#                 rect_h="${line[7]}"
#                 grim -g "${rect_x},${rect_y} ${rect_w}x${rect_h}" "$EWW_SNAPSHOT_DIR/$window"
#             elif [ "$event" = "close" ]; then
#                 rm -f "$EWW_SNAPSHOT_DIR/$window"
#             fi
#     done
# }
# 
# function container::list_container_snapshots() {
#     echo $(ls "${EWW_SNAPSHOT_DIR}"/*.jpg | jq -R | jq -cs)
# }
