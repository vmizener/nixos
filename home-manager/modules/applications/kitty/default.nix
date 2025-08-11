{ config, flakePath, lib, pkgs, ... }:
let
  cfg = config.apps.kitty;
in {
  options = {
    apps.kitty.enable = lib.mkEnableOption "kitty";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kitty ];
    xdg.configFile = {
      "kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/applications/kitty/kitty.conf";
      "kitty/toggle_zoom.py".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/applications/kitty/toggle_zoom.py";
    };
  };
}
