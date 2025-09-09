{ config, lib, pkgs, ... }:
let
  app = "fusuma";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fusuma ];
    xdg.configFile = {
      "fusuma/config.yml".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/fusuma/config.yml";
    };
    systemd.user.services.fusuma = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Unit = {
        Description = "Fusuma multitouch gesture support daemon";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.fusuma}/bin/fusuma";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
