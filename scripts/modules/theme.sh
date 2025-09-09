function theme::set_wallpaper() {
    utils::init
    if utils::exists swww; then
        swww img "$1"
    fi
}

function theme::reset() {
    utils::init
    if utils::exists swww; then
        echo "Reapplying theme" | utils::log
        swww restore -a 2>&1    | utils::log
        swww query 2>&1         | utils::log
    else
        echo "No utils found"   | utils::err
    fi
}

