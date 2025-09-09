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
