{ inputs, pkgs, lib, config, ... }:
let
  mod = "thunar";
  cfg = config.core.${mod};
in {
  options = {
    core.${mod}.enable = lib.mkEnableOption "${mod}";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xfce.thunar
      xfce.thunar-vcs-plugin
    ];
  };
}

