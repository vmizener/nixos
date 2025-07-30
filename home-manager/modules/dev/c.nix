{ config, lib, pkgs, ... }: {
  options = {
    dev.c.enable = lib.mkEnableOption "c";
  };
  config = lib.mkIf config.dev.c.enable {
    home.packages = with pkgs; [ libgcc ];
  };
}

