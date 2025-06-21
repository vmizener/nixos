{ config, flakePath, pkgs, ... }:
let
  # Out-of-store symlinks require absolute paths when using a flake config. This
  # is because relative paths are expanded after the flake source is copied to
  # a store path which would get us read-only store paths.
  dir = "${flakePath config}/home-manager/features/niri";
in {
  # Nix packages configure Chrome and Electron apps to run in native Wayland
  # mode if this environment variable is set.
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.packages = with pkgs; [
  ];

  xdg.configFile = {
    "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${dir}/niri-config.kdl";
  };
}
