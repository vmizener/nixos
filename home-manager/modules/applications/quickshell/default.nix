{ config, flakePath, inputs, lib, pkgs, ... }: {
  options = {
    apps.quickshell.enable = lib.mkEnableOption "quickshell";
  };
  config = lib.mkIf config.apps.quickshell.enable {
    home.packages = [ inputs.quickshell.packages.${pkgs.system}.default ];
    xdg.configFile = {
      "quickshell/shell.qml".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/apps/quickshell/shell.qml";
    };
  };
}
