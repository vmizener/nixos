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

