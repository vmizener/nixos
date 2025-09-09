{ config, lib, pkgs, ... }:
let
  app = "kanshi";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf config.apps.kanshi.enable {
    home.packages = [ pkgs.kanshi ];
    services.kanshi.enable = true;
    xdg.configFile = {
      "kanshi/config".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/kanshi/config";
    };
  };
}
