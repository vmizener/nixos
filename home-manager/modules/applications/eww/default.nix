{ config, flakePath, inputs, lib, pkgs, ... }:
let
  cfg = config.apps.eww;
in {
  options = {
    apps.eww.enable = lib.mkEnableOption "eww";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.eww ];
    xdg.configFile = {
      "eww".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/applications/eww/config";
    };
    systemd.user.services.eww = {
      Install = {
        WantedBy = [ "default.target" ];
      };
      Unit = {
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = builtins.toString (pkgs.writeShellScript "eww-setup " ''
          ${pkgs.eww}/bin/eww daemon
          ${pkgs.eww}/bin/eww open topbar
          ${pkgs.eww}/bin/eww logs
        '');
        ExecStop = "${pkgs.eww}/bin/eww kill";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
