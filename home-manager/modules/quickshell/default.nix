{ config, flakePath, inputs, lib, pkgs, ... }: {
  options = {
    modules.quickshell.enable = lib.mkEnableOption "quickshell";
  };
  config = lib.mkIf config.modules.quickshell.enable {
    home.packages = [ inputs.quickshell.packages.${pkgs.system}.default ];
    xdg.configFile = {
      "quickshell/shell.qml".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/quickshell/shell.qml";
    };
  };
}
