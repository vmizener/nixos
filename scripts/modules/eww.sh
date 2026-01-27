function eww::clear_cache() {
    # Usage:
    #   eww::clear_cache
    #
    # Clears the user cache of any temp files relevant to EWW

    local cache="${XDG_CACHE_HOME:-$HOME/.cache}"
    if [[ -d "${cache}" ]]; then
        rm ${cache}/eww*.{lock,counter} 2>&1 | utils::err
    fi
}

function eww::keep_window_open() {
    # Usage:
    #   eww::keep_window_open WINDOW
    #
    # Continuously polls EWW's active windows to ensure WINDOW is open.
    # If not, opens it.

    utils::init
    local WINDOW="$1"
    local DELAY=1
    while true; do
        eww active-windows | grep "${WINDOW}" >/dev/null
        if [[ $? != 0 ]]; then
            utils::log "Re-opening window \"${WINDOW}\""
            eww::clear_cache >/dev/null
            eww open "${WINDOW}"
        fi
        sleep "${DELAY}"
    done
}

function eww::jq_update() {
    # Usage:
    #   eww::jq_update VAR JQ_CMD
    #
    # Update an EWW variable by passing it through a JQ command
    # E.g.
    #   eww update "var={}"
    #   eww get var                             # Prints '{}'
    #   ./run eww::jq_update var ".a = true"
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
        return 1
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

