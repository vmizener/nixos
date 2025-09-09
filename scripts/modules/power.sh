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

