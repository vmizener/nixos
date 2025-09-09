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


