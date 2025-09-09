{ config, lib, pkgs, ... }:
let
  app = "kitty";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kitty ];
    xdg.configFile = {
      "kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/kitty/kitty.conf";
      "kitty/toggle_zoom.py".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/kitty/toggle_zoom.py";
    };
  };
}
