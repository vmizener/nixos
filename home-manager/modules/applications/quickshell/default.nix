{ config, inputs, lib, pkgs, ... }:
let
  app = "quickshell";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ inputs.quickshell.packages.${pkgs.system}.default ];
    xdg.configFile = {
      "quickshell/shell.qml".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/apps/quickshell/shell.qml";
    };
  };
}
