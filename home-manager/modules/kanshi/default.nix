{ config, flakePath, lib, pkgs, ... }: {
  options = {
    modules.kanshi.enable = lib.mkEnableOption "kanshi";
  };
  config = lib.mkIf config.modules.kanshi.enable {
    home.packages = [ pkgs.kanshi ];
    services.kanshi.enable = true;
    xdg.configFile = {
      "kanshi/config".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/kanshi/config";
    };
  };
}
