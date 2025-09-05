{ config, lib, pkgs, ... }:
let
  module = "python";
  cfg = config.dev.${module};
in {
  options = {
    dev.${module}.enable = lib.mkEnableOption "${module}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      black
      pyright
      # python3
    ];
  };
}

