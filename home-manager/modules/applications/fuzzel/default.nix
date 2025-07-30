{ config, flakePath, lib, pkgs, ... }: {
  options = {
    apps.fuzzel.enable = lib.mkEnableOption "fuzzel";
  };
  config = lib.mkIf config.apps.fuzzel.enable {
    home.packages = [ pkgs.fuzzel ];
    xdg.configFile = {
      "fuzzel/fuzzel.ini".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/applications/fuzzel/fuzzel.ini";
    };
  };
}
