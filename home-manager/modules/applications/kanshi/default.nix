{ config, flakePath, lib, pkgs, ... }: {
  options = {
    apps.kanshi.enable = lib.mkEnableOption "kanshi";
  };
  config = lib.mkIf config.apps.kanshi.enable {
    home.packages = [ pkgs.kanshi ];
    services.kanshi.enable = true;
    xdg.configFile = {
      "kanshi/config".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/applications/kanshi/config";
    };
  };
}
