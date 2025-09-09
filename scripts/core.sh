#!/usr/bin/env bash

#
#   Utilities
#

function utils::lib_init() {
    USERLOGPATH="/tmp/${USER}-scripts.log"
    case $1 in
        --reset)
            rm "${USERLOGPATH}"
            shift
        ;;
        -*|--*)
            echo "Unknown option $i"
            return 1
        ;;
        *)
            shift
        ;;
    esac

    PATH=.
    PATH=$PATH:${HOME}/.local/bin
    PATH=$PATH:${HOME}/.cargo/bin
    PATH=$PATH:${HOME}/go/bin
    PATH=$PATH:/usr/local/sbin
    PATH=$PATH:/usr/local/bin
    PATH=$PATH:/usr/sbin
    PATH=$PATH:/usr/bin
    PATH=$PATH:/sbin
    PATH=$PATH:/bin
}

function utils::log() {
    [ -z "$USERLOGPATH" ] && utils::lib_init
    echo "[$(date '+%B %d %H:%M')] $1" >> $USERLOGPATH
}

function utils::exists() {
    # Usage:
    #     lib::exists [cmd ...]
    #
    # Returns whether all the given commands are in PATH.
    # E.g.
    #   `lib::exists bash zsh` -> RC 0
    #   `lib::exists not-bash` -> RC 1

    for arg in "$@"; do
        if ! command -v "$arg" >/dev/null 2>&1; then
            return 1
        fi
    done
}

#
#   System
#

function sys::suspend () {
    systemctl suspend
    notify-send "Suspending now!"
}

function sys::lock() {
    swaylock --grace 0 --grace-no-mouse
}

function sys::shutdown() {
    shutdown now
    notify-send "Shutting down now!"
}

function sys::logout() {
    loginctl session-status | head -n1 | awk '{print $1}' | xargs -I{} loginctl kill-session {}
}

#
#   Network
#

function network::get_active_connections() {
    default_interface=$(ip -o route get 8.8.8.8 | rg 'dev ([^ ]*)' -or '$1')
    declare -a ret
    while IFS= read -r entry; do
        IFS=':' read -a arr <<< "$entry"
        c_type="${arr[0]}"
        c_device="${arr[1]}"
        c_state="${arr[2]}"
        c_conn="${arr[3]}"
        is_default=$([[ "${c_device}" == "${default_interface}" ]] && echo 'true' || echo 'false')
        [[ ! "${c_state}" = "connected" ]] && continue
        strength=100
        if [[ "${c_type}" == "wifi" ]]; then
            strength=$(network::list_wifi | jq -r ".[] | select(.ssid == \"${c_conn}\") | .best_signal")
        fi
        ret+=("{\"name\": \"${c_conn}\", \"device\": \"${c_device}\", \"type\": \"${c_type}\", \"is_default\": \"${is_default}\", \"strength\": \"${strength}\"}")
    done < <(nmcli -t -f TYPE,DEVICE,STATE,CONNECTION device | grep -v '^loopback:')
    echo "${ret[@]}" | jq -cs
}

function network::is_wifi_enabled() {
    # Returns whether wifi is enabled
    #
    # If `-p` is provided as argument, echos "true" or "false"
    # Otherwise, an exit code is emitted
    [[ $(nmcli radio wifi) = 'enabled' ]]; rc=$?
    if [[ $1 == '-p' ]]; then
        [[ $rc == 0 ]] && echo "true" || echo "false"
    else
        return $rc
    fi
}

function network::list_wifi() {
    declare -a ret
    while IFS= read -r entry; do
        IFS=':' read -a arr <<< "$entry"
        c_in_use=$([[ "${arr[0]}" = " " ]] && echo 'false' || echo 'true')
        c_bssid="${arr[1]}"
        c_ssid="${arr[2]}"
        c_mode="${arr[3]}"
        c_chan="${arr[4]}"
        c_rate="${arr[5]}"
        c_signal="${arr[6]}"
        c_bars="${arr[7]}"
        c_security=$([[ "${arr[8]}" = "" ]] && echo 'None' || echo "${arr[8]}")
        ret+=( """{
            \"in_use\": ${c_in_use},
            \"bssid\": \"${c_bssid}\",
            \"ssid\": \"${c_ssid}\",
            \"mode\": \"${c_mode}\",
            \"chan\": \"${c_chan}\",
            \"rate\": \"${c_rate}\",
            \"signal\": \"${c_signal}\",
            \"bars\": \"${c_bars}\",
            \"security\": \"${c_security}\"
        }""")
    done < <(nmcli -t device wifi list)
    echo "${ret[@]}" | jq 'select(.ssid != "")' | jq -s "[
        group_by(.ssid)[] | sort_by(.signal) | reverse | {
            ssid: .[0].ssid,
            in_use: ([.[] | .in_use] | any),
            mode: .[0].mode,
            security: .[0].security,
            best_signal: ([.[] | .signal] | max),
            best_bars: ([.[] | [.signal, .bars]] | max | .[1]),
            details: [.[] | {
                bssid: .bssid,
                chan: .chan,
                rate: .rate,
                signal: .signal,
                bars: .bars
            }]
        }
    ]"
}

#
#   Power
#

function power::on_bat() {
    # Returns whether a battery is present
    #
    # If `-p` is provided as argument, echos "true" or "false"
    # Otherwise, an exit code is emitted
    [ -d /sys/class/power_supply/BAT0 ]; rc=$?
    if [[ $1 == '-p' ]]; then
        [[ $rc == 0 ]] && echo "true" || echo "false"
    else
        return $rc
    fi
}

function power::get_status() {
    if power::on_bat; then
        # Values:  "unknown", "charging", "discharging", "not charging", "full"
        echo $(cat /sys/class/power_supply/BAT0/status | tr '[:upper:]' '[:lower:]')
    else
        echo "n/a"
    fi
}

function power::get_capacity() {
    if power::on_bat; then 
        # Values: 0 - 100 (percent)
        echo $(cat /sys/class/power_supply/BAT0/capacity)
    else
        echo "0"
    fi
}

function power::get_capacity_level() {
    # Values: "unknown", "critical", "low", "normal", "high", "full"
    if power::on_bat; then
        echo $(cat /sys/class/power_supply/BAT0/capacity_level | tr '[:upper:]' '[:lower:]')
    else
        echo "n/a"
    fi
}

#
#   Audio
#

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
            pactl set-sink-mute @DEFAULT_SINK@ "$1"
        ;;
        *)
            >&2 echo "[ERR] audio::set_mute\nInvalid option: got '$1', expected 'yes', 'no', or 'toggle'; "
        ;;
    esac
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

#
# IME
#

function ime::open_config() {
    fcitx5-configtool
}

function ime::toggle_active() {
    fcitx5-remote -t
}

function ime::mode_subscriber() {
    # Escape if fctix5 isn't available
    pgrep fcitx5 >/dev/null || return

    local SLEEP_STEP=0.1  # 100ms
    local LAST_MODE="N/A"
    while true; do
        CUR_MODE=$(fcitx5-remote -n)
        if [[ "${LAST_MODE}" != "${CUR_MODE}" ]]; then
            echo "${CUR_MODE}"
            LAST_MODE="${CUR_MODE}"
        fi
        sleep "${SLEEP_STEP}"
    done
}

#
# Locale Info
#

function locale::location() {
    # Usage:
    #   locale::location
    #
    # Returns location info based on IP
    # Uses ipinfo.io free token (login with github)

    local TOKEN="4c132caf0e6b7a"
    local URL="ipinfo.io?token=${TOKEN}"
    ERR_FILE="$HOME/.cache/eww-location.out"
    o=$(curl -m 10 ${URL} 2>${ERR_FILE})
    OK=$?
    ERR=$(<${ERR_FILE})
    rm ${ERR_FILE}
    if (( $OK != 0 )); then
        >&2 echo "[ERR] locale::location"
        >&2 echo "$ERR"
        >&2 echo "$o"
        echo "{}"
        return 1
    fi
    echo "$o" | jq -c
}

function locale::weather() {
    # Usage:
    #   locale::weather
    #
    # Returns local weather information

    local SYMBOLS='{
        "Unknown":             "✨",
        "Clear":               "☀️",
        "Cloudy":              "☁️",
        "VeryCloudy":          "☁️",
        "Fog":                 "🌫",
        "Mist":                "🌫",
        "HeavyRain":           "🌧",
        "HeavyShowers":        "🌧",
        "HeavySnow":           "❄️",
        "HeavySnowShowers":    "❄️",
        "LightRain":           "🌦",
        "LightShowers":        "🌦",
        "LightSleet":          "🌧",
        "LightSleetShowers":   "🌧",
        "LightSnow":           "🌨",
        "LightSnowShowers":    "🌨",
        "Overcast":            "☁️",
        "PartlyCloudy":        "⛅️",
        "Sunny":               "☀️",
        "ThunderyHeavyRain":   "🌩",
        "ThunderyShowers":     "⛈",
        "ThunderySnowShowers": "⛈"
    }'

    ERR_FILE="$HOME/.cache/eww-weather.out"
    local location=$(locale::location 2>${ERR_FILE} | jq '[.city, .region] | join("+") | gsub(" "; "+")')
    local URL="v2d.wttr.in/${location}?format=j2"
    o=$(curl -m 10 ${URL} 2>${ERR_FILE})
    OK=$?
    ERR=$(<${ERR_FILE})
    rm ${ERR_FILE}
    # Handle when the service is down
    if (( $OK != 0 )) || [[ "$o" =~ "Unknown location" ]]; then
        >&2 echo "[ERR] locale::weather"
        >&2 echo "$ERR"
        >&2 echo "$o"
        echo "{}"
        return 1
    fi
    o_FeelsLikeC=$(echo "$o" | jq -r '.current_condition[0].FeelsLikeC')
    o_FeelsLikeF=$(echo "$o" | jq -r '.current_condition[0].FeelsLikeF')
    o_TempC=$(echo "$o" | jq -r '.current_condition[0].temp_C')
    o_TempF=$(echo "$o" | jq -r '.current_condition[0].temp_F')
    o_Loc="$(echo "$o" | jq -r '.nearest_area[0].areaName[0].value'), $(echo "$o" | jq -r '.nearest_area[0].region[0].value')"
    o_weatherDesc="$(echo "$o" | jq -r '.current_condition[0].weatherDesc[0].value' | sed 's/\([[:blank:]][[:lower:]]\)/\U\1/g')"
    o_weatherIco=$(echo "$SYMBOLS" | jq -r ".$(echo "$o_weatherDesc" | sed 's/[[:blank:]]\(.\)/\1/g')")
    echo '{
        "FeelsLikeC": "'$o_FeelsLikeC'",
        "FeelsLikeF": "'$o_FeelsLikeF'",
        "TempC": "'$o_TempC'",
        "TempF": "'$o_TempF'",
        "Loc": "'$o_Loc'",
        "Desc": "'$o_weatherDesc'",
        "Icon": "'$o_weatherIco'"
    }' | jq -c
}

#
# EWW
#

function eww::jq-update() {
    # Usage:
    #   eww::jq-update VAR JQ_CMD
    #
    # Update an EWW variable by passing it through a JQ command
    # E.g.
    #   eww update "var={}"
    #   eww get var                             # Prints '{}'
    #   ./run eww::jq-update var ".a = true"
    #   eww get var                             # Prints '{"a": true}'
    #
    # If JQ returns an error, the variable is not updated

    VAR="$1"
    CMD="$2"

    CUR_VAL="$(eww get ${VAR})"
    NEW_VAL="$(echo "${CUR_VAL}" | jq -c "${CMD}" 2>/dev/null)"
    if [[ $? != 0 ]]; then
        >&2 echo "JQ command failure!"
        echo "${CUR_VAL}" | jq -c "${CMD}"
    else
        eww update "${VAR}=${NEW_VAL}"
    fi
}

function eww::counter() {
    # Usage:
    #   eww::counter VAR init INTERVAL [TICKRATE]
    #   eww::counter VAR start
    #   eww::counter VAR pause
    #   eww::counter VAR reset
    #
    # Declare an automatically incrementing counter that increments from 0 to 100 over INTERVAL seconds
    # The counter can then be started/paused/resumed/reset via corresponding commands
    #
    # TICKRATE determines the update frequency, in seconds (default: 0.1)
    # 
    # Use deflisten to track the counter's progress in EWW
    # E.g.
    #   deflisten int_mycounter :initial 0 `./run eww:counter mycounter init 3`
    # Then use
    #   `./run eww:counter mycounter start`
    # somewhere else to start it

    VAR="$1"
    CMD="$2"
    COUNTER_FILE="$HOME/.cache/eww-$VAR.counter"

    function read_counter () {
        read -a inputs -d EOF < "$COUNTER_FILE"
        CUR_VAL="${inputs[0]}"
        STEP="${inputs[1]}"
        TICKRATE="${inputs[2]}"
        STATE="${inputs[3]}"
    }
    function write_counter () {
        printf "$1\n$2\n$3\n$4" > "$COUNTER_FILE"
    }

    function loop () {
        while true; do
            if [[ ! -f "$COUNTER_FILE" ]]; then
                break
            fi

            read_counter
            if [[ "${STATE}" != "active" ]]; then
                sleep "$TICKRATE"
                continue
            fi

            NEXT=$(bc <<< "scale=3; ${CUR_VAL}+${STEP}")
            if (( $(echo "$NEXT >= 100" | bc -l) )); then
                write_counter "100.000" "${STEP}" "${TICKRATE}" "inactive"
                echo "100.000"
            else
                write_counter "${NEXT}" "${STEP}" "${TICKRATE}" "${STATE}"
                echo "$NEXT"
            fi

            sleep "$TICKRATE"

        done
    }

    case "$2" in
        init)
            INTERVAL="$3"
            TICKRATE="$4"
            STATE="inactive"
            if ! [ -n "$TICKRATE" ]; then
                TICKRATE="0.1"
            fi
            STEP=$(bc <<< "scale=3; (100*${TICKRATE})/${INTERVAL}")
            printf "0.000\n${STEP}\n${TICKRATE}\n${STATE}" > "${COUNTER_FILE}"
            echo "0.000"
            loop
        ;;
        start)
            read_counter
            write_counter "${CUR_VAL}" "${STEP}" "${TICKRATE}" "active"
        ;;
        pause)
            read_counter
            write_counter "${CUR_VAL}" "${STEP}" "${TICKRATE}" "inactive"
        ;;
        reset)
            read_counter
            write_counter "0" "${STEP}" "${TICKRATE}" "inactive"
        ;;
    esac
}

function eww::popup() {
    # Usage:
    #   eww::popup ("open"|"close") WINDOW [DELAY]
    #
    # Open or close an EWW window, after a specified delay
    # Window should have an associated variable "bool_$WINDOW-visible" indicating if it should be visible

    function window () {
        [[ $1 == 'open' ]]
        OPEN=$?
        WINDOW=$2
        DELAY=$3
        LOCK_FILE="$HOME/.cache/eww-$WINDOW.lock"
        VIS_BOOL="bool_$WINDOW-visible"

        # Update VIS_BOOL before delay on CLOSE, but after on OPEN to let transitions draw
        if (( $OPEN != 0 )); then
            eww update "$VIS_BOOL=false"
        fi
        # Parse and run delay if provided
        if [ -n "$DELAY" ]; then
            DELAY=$(echo "$DELAY" | tr -d '[:alpha:]')
            DELAY=$(echo "scale=2 ; ${DELAY}/1000" | bc)
            sleep "$DELAY"
        fi
        if (( $OPEN == 0 )) && [[ ! -f "$LOCK_FILE" ]]; then
            touch "$LOCK_FILE"
            eww open $WINDOW
        elif (( $OPEN != 0 )) && [[ -f "$LOCK_FILE" ]] && [[ $(eww get $VIS_BOOL) = "false" ]]; then
            # Only close if VIS_BOOL is still false
            rm "$LOCK_FILE"
            eww close $WINDOW
        fi
        if (( $OPEN == 0 )); then
            eww update "$VIS_BOOL=true"
        fi
    }
    if [[ ! $(timeout 1s pidof eww) ]]; then
        eww daemon
        sleep 1
    fi
    window $1 $2 $3 &
}

function eww::set_locked_var() {
    # Usage:
    #   eww::set_locked_var VAR
    #   eww::unset_locked_var VAR [GRACE]
    #
    # Sets <VAR> with an associated lock file.
    # When unset, will only trigger after <GRACE> seconds if the lock is still present.
    #
    # <GRACE> is set to 0 if not provided.
    #
    # E.g. to detect hover, but only unset if not hovering for 0.5 seconds:
    #
    #       :onhover     "./run eww::set_locked_var   bool_topbar-right-hover"
    #       :onhoverlost "./run eww::unset_locked_var bool_topbar-right-hover 0.5"

    VAR=$1
    LOCK_FILE="$HOME/.cache/eww-grace-$VAR.lock"
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
    fi
    eww update "${VAR}=true"
}

function eww::unset_locked_var() {
    # See `eww::set_locked_var` for usage

    VAR=$1
    shift
    GRACE=$1
    [[ -z "$GRACE" ]] && GRACE=0
    shift
    LOCK_FILE="$HOME/.cache/eww-grace-$VAR.lock"
    (
        touch "$LOCK_FILE"
        sleep "$GRACE"
        if [[ -f "$LOCK_FILE" ]]; then
            rm -f "$LOCK_FILE"
            while (( "$#" > 0 )); do
                /usr/bin/env bash -c "$0"
                shift
            done
            eww update "${VAR}=false"
        fi
    ) &
}
