{ config, flakePath, lib, inputs, pkgs, ... }: {
  imports = [
    ./common.nix
    ../modules
  ];
  modules.kanshi.enable = true;
  modules.maestral.enable = true;
  modules.niri.enable = true;
  modules.fuzzel.enable = true;
  modules.quickshell.enable = true;
  modules.swww.enable = true;

  services.mako.enable = true;
}
