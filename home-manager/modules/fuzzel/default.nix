{ config, flakePath, lib, pkgs, ... }: {
  options = {
    modules.fuzzel.enable = lib.mkEnableOption "fuzzel";
  };
  config = lib.mkIf config.modules.fuzzel.enable {
    home.packages = [ pkgs.fuzzel ];
    xdg.configFile = {
      "fuzzel/fuzzel.ini".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/fuzzel/fuzzel.ini";
    };
  };
}
