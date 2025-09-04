{ config, flakePath, lib, inputs, pkgs, ... }: {
  imports = [
    ./common.nix
    ../modules/applications
    ../modules/dev
  ];
  home.username = "rvonmizener";
  home.homeDirectory = "/home/rvonmizener";

  # apps.eww.enable = true;
  # apps.fuzzel.enable = true;
  # apps.kanshi.enable = true;
  # apps.kitty.enable = true;
  # apps.maestral.enable = true;
  # apps.niri.enable = true;
  # apps.quickshell.enable = true;
  # apps.swww.enable = true;
  # apps.webtorrent.enable = true;
  #
  # dev.c.enable = true;
  # dev.golang.enable = true;
  # dev.python.enable = true;
  # dev.sql.enable = true;
  #
  # services.clipman.enable = true;
  # services.mako.enable = true;
  #
  # home.packages = with pkgs; [
  #   ani-cli
  #   animdl
  #   cava
  #   eww
  #   mako
  #   neovim
  #   spotify
  #   spotify-player
  #   spotify-tray
  # ];
}

