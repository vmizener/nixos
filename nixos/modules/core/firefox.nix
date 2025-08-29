{ inputs, pkgs, lib, config, ... }:
let
  mod = "firefox";
  cfg = config.core.${mod};
in {
  options = {
    core.${mod}.enable = lib.mkEnableOption "${mod}";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.firefox ];
    programs.firefox.enable = true;
  };
}

