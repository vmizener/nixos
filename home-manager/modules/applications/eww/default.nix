{ config, inputs, lib, pkgs, ... }:
let
  app = "eww";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
  ewwcfg = "${flakepath}/home-manager/modules/applications/eww/config";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.eww ];
    xdg.configFile = {
      "eww/run".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/scripts/run";
      "eww/eww.yuck".source = config.lib.file.mkOutOfStoreSymlink "${ewwcfg}/eww.yuck";
      "eww/eww.scss".source = config.lib.file.mkOutOfStoreSymlink "${ewwcfg}/eww.scss";
      "eww/modules".source = config.lib.file.mkOutOfStoreSymlink "${ewwcfg}/modules";
    };
    systemd.user.services.eww-daemon = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Unit = {
        Description = "Service daemon for EWW";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "forking";
        ExecStart = "${pkgs.eww}/bin/eww daemon";
        ExecStartPost = "${pkgs.eww}/bin/eww open topbar";
        ExecStop = "${pkgs.eww}/bin/eww kill";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
    systemd.user.services.eww-logger = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Unit = {
        Description = "Logger for EWW";
        Requires = [ "eww-daemon.service" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.eww}/bin/eww logs";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
