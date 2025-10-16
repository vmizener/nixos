{ config, lib, inputs, pkgs, ... }:
let
  flakepath = "${config.home.homeDirectory}/config/";
in {
  imports = [
    ./common.nix
    ../modules/applications
    ../modules/dev
    ../modules/shell
  ];

  apps.eww.enable = true;
  apps.foot.enable = true;
  apps.fuzzel.enable = true;
  apps.ignis.enable = true;
  apps.kanshi.enable = true;
  apps.kitty.enable = true;
  apps.maestral.enable = true;
  apps.niri.enable = true;
  apps.quickshell.enable = true;
  apps.ranger.enable = true;
  apps.swww = {
    enable = true;
    img = builtins.toPath "${flakepath}/assets/media/girls_outside_door.jpg";
  };
  apps.webtorrent.enable = true;

  dev.c.enable = true;
  dev.golang.enable = true;
  dev.python.enable = true;
  dev.sql.enable = true;

  shell.zsh.enable = true;

  services.clipman.enable = true;
  services.mako.enable = true;

  home.packages = with pkgs; [
    ani-cli
    animdl
    cava
    mako
    neovim
    spotify
    spotify-player
    spotify-tray
  ];
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      NH_FLAKE = "${flakepath}";
    };
  };
}
