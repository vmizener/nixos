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


