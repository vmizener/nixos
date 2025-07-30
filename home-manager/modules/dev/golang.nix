{ config, lib, pkgs, ... }: {
  options = {
    dev.golang.enable = lib.mkEnableOption "golang";
  };
  config = lib.mkIf config.dev.golang.enable {
    home.packages = with pkgs; [ go delve ];
  };
}

