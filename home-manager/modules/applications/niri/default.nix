{ config, inputs, lib, pkgs, ... }:
let
  app = "niri";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  imports = [ inputs.niri.homeModules.niri ];
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    home.packages = [ pkgs.xwayland-satellite ];
    targets.genericLinux.nixGL = {
      packages = inputs.nixgl.packages;
    };
    programs.niri = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.niri-unstable;
    };
    xdg.configFile = {
      "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/niri/niri-config.kdl";
    };
    # Nix packages configure Chrome and Electron apps to run in native Wayland
    # mode if this environment variable is set.
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
