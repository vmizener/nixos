{ config, lib, pkgs, ... }:
let
  app = "niri";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ ];
    xdg.configFile = {
      "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/niri/niri-config.kdl";
    };
    # Nix packages configure Chrome and Electron apps to run in native Wayland
    # mode if this environment variable is set.
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
