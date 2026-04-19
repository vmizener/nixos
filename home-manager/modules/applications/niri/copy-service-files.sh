#!/usr/bin/env bash
set -uo pipefail

function error() {
  echo -e "Encountered error: " + $1
  exit 1
}

function sudo_symlink() {
  src="$1"
  dst="$2"
  sudo rm "${dst}"
  sudo ln -s "${src}" "${dst}"
  if [[ $? != 0 ]]; then
    error "failed to create symlink target ${src} at ${dst}"
  fi
}

if [[ -d "${XDG_STATE_HOME}"/nix/profiles/profile ]]; then
    NIX_PROFILE="${XDG_STATE_HOME}/nix/profiles/profile"
else
    NIX_PROFILE="${HOME}/.nix-profile}"
fi
sudo_symlink \
    "${NIX_PROFILE}/share/systemd/user/niri-shutdown.target" \
    /etc/systemd/user/niri-shutdown.target
sudo_symlink \
    "${NIX_PROFILE}/share/systemd/user/niri.service" \
    /etc/systemd/user/niri.service
sudo_symlink \
    "${NIX_PROFILE}/share/xdg-desktop-portal/niri-portals.conf" \
    /usr/share/xdg-desktop-portal/niri-portals.conf
sudo_symlink \
    "${NIX_PROFILE}/share/wayland-sessions/niri.desktop" \
    /usr/share/wayland-sessions/niri.desktop
sudo_symlink \
    "${NIX_PROFILE}/bin/niri-session" \
    /usr/bin/niri-session
sudo_symlink \
    "${NIX_PROFILE}/bin/niri" \
    /usr/bin/niri

echo -e "Okay"
