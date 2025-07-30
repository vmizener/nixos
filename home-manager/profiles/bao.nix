{ config, flakePath, lib, inputs, pkgs, ... }: {
  imports = [
    ./common.nix
    ../modules/applications
    ../modules/dev
  ];

  apps.kanshi.enable = true;
  apps.maestral.enable = true;
  apps.niri.enable = true;
  apps.fuzzel.enable = true;
  apps.quickshell.enable = true;
  apps.swww.enable = true;
  apps.webtorrent.enable = true;

  dev.c.enable = true;
  dev.golang.enable = true;

  services.clipman.enable = true;
  services.mako.enable = true;

  home.packages = with pkgs; [
    ani-cli
    animdl
    eww
    kitty
    mako
    neovim
  ];
}
