function theme::set_wallpaper() {
    utils::init
    if utils::exists awww; then
        awww img "$1"
    fi
}

function theme::reset() {
    utils::init
    if utils::exists awww; then
        echo "Reapplying theme" | utils::log
        awww restore -a 2>&1    | utils::log
        awww query 2>&1         | utils::log
    else
        echo "No utils found"   | utils::err
    fi
}

