{ config, inputs, lib, pkgs, ... }:
let
  app = "eww";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.eww ];
    xdg.configFile = {
      "eww".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/eww/config";
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
