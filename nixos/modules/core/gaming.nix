{ inputs, pkgs, lib, config, ... }:
let
  mod = "gaming";
  cfg = config.core.${mod};
in {
  options = {
    core.${mod}.enable = lib.mkEnableOption "${mod}";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      discord
      vesktop
      mpv
      streamlink
      streamlink-twitch-gui-bin
    ];
    programs.steam = {
      enable = true;
    };
  };
}

