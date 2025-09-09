function audio::get_status() {
    sink="$(pactl get-default-sink)"
    # Detect mute
    [[ $(pactl get-sink-mute @DEFAULT_SINK@ | cut -f2 -d' ') == 'yes' ]]
    is_muted=$?
    if (( $is_muted == 0 )); then
        vol="0"
    else
        vol="$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%')"
    fi
    sink_json="$(pactl --format=json list sinks | jq '.[] | select(.name=="'$sink'")')"
    desc=$(echo "$sink_json" | jq -r '.description')
    form_factor=$(echo "$sink_json" | jq -r '.properties."device.form_factor"')
    [[ "$form_factor" =~ "null" ]] && form_factor="default"
    echo '{
        "vol": '$vol',
        "desc": "'$desc'",
        "type": "'$form_factor'",
        "sink": "'$sink'"
    }' | jq -c
}

function audio::set_mute() {
    case "$1" in
        toggle|yes|no)
            utils::log "[$FUNCNAME]" "toggled mute"
            pactl set-sink-mute @DEFAULT_SINK@ "$1"
        ;;
        *)
            >&2 echo "[ERR] audio::set_mute"
            >&2 echo "Invalid option: got '$1', expected 'yes', 'no', or 'toggle'"
            return 1
        ;;
    esac
}

function audio::set_volume() {
    # Updates the volume of the default sink by the given relative value
    delta="$1"
    echo "$delta" | grep -E '(\+|\-)[[:digit:]]+%'
    OK=$?
    if (( $OK != 0 )); then
        >&2 echo "[ERR] audio::set_volume"
        >&2 echo "Argument must be in delta percent change format (e.g. \"+5%\" or \"-2%\")"
        return 1
    fi
    pactl set-sink-volume @DEFAULT_SINK@ "${delta}"
}

function audio::subscribe() {
    # Emit initial status
    audio::get_status

    # Subscribe to changes
    pactl subscribe |
        grep --line-buffered "sink" |
        while read -r _; do
            audio::get_status
        done
}

function audio::get_sinks() {
    # Outputs all audio sinks in JSON, indicating which is the default sink
    # E.g.
    # [
    #   {
    #     "id": 0,
    #     "name": "Navi 21/23 HDMI/DP Audio Controller Digital Stereo (HDMI)",
    #     "is-default": "false",
    #     "type": null
    #   },
    #   {
    #     "id": 1,
    #     "name": "SteelSeries Arctis 7 Chat",
    #     "is-default": "false",
    #     "type": "headset"
    #   },
    #   {
    #     "id": 2,
    #     "name": "SteelSeries Arctis 7 Game",
    #     "is-default": "false",
    #     "type": "headset"
    #   },
    #   {
    #     "id": 3,
    #     "name": "Starship/Matisse HD Audio Controller Analog Stereo",
    #     "is-default": "true",
    #     "type": null
    #   }
    # ]

    DEFAULT_SINK=$(pactl get-default-sink)
    pactl --format=json list sinks | jq '
        .[] | {
            "id": .index,
            "name": .description,
            "is_default": (if .name == "'$DEFAULT_SINK'" then "true" else "false" end),
            "type": .properties."device.form_factor"
        }' | jq -jcs 'sort_by(.name)'
}

function audio::set_default_sink() {
    # Set default sink and move all existing inputs to it
    SINK_ID="$1"
    INPUTS=( $(pactl list short sink-inputs | cut -f1) )
    pactl set-default-sink "$SINK_ID"
    for input in "${INPUTS[@]}"; do
        pactl move-sink-input "$input" "$SINK_ID"
    done
}

function audio::scroll_sinks() {
    SINK_IDS=( $(audio::get_sinks | jq '.[] | .id') )
    SINK_COUNT=$(audio::get_sinks | jq 'length')
    [[ "$SINK_COUNT" -le 0 ]] && return 0
    CURRENT_SINK_ID=$(audio::get_sinks | jq '.[] | select(.is_default == "true").id')
    CURRENT_SINK_IDX=$(( $(printf "%s\n" "${SINK_IDS[@]}" | grep -n "^${CURRENT_SINK_ID}$" | cut -f1 -d:)-1 ))
    if [[ "$1" == "up" ]]; then
        NEW_SINK_IDX=$(( ($CURRENT_SINK_IDX-1)%$SINK_COUNT ))
    else
        NEW_SINK_IDX=$(( ($CURRENT_SINK_IDX+1)%$SINK_COUNT ))
    fi
    audio::set_default_sink "${SINK_IDS[$NEW_SINK_IDX]}"
}


