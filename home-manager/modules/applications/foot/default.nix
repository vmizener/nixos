{ config, lib, pkgs, ... }:
let
  app = "foot";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.foot ];
    xdg.configFile = {
      "foot/foot.ini".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/foot/foot.ini";
    };
  };
}
