{ config, inputs, lib, pkgs, ... }:
let
  app = "awww";
  cfg = config.apps.${app};
in {
  options = {
    apps.awww.enable = lib.mkEnableOption "${app}";
    apps.awww.pkg = lib.mkOption {
      type = lib.types.package;
      default = inputs.awww.packages.${pkgs.system}.awww;
      description = "awww package to use";
    };
    apps.awww.img = lib.mkOption {
      type = lib.types.path;
      default = ../../../../assets/media/waneela_pixel_city_art.gif;
      description = "Image to display";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.pkg ];
    systemd.user.services.awww = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Unit = {
        Description = "AWWW daemon";
        After = [ "graphical-session.target" ];
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${cfg.pkg}/bin/awww-daemon";
        ExecStartPost = "${cfg.pkg}/bin/awww img ${cfg.img}";
        ExecStop = "${cfg.pkg}/bin/awww kill";
        Restart = "on-failure";
        RestartSec = "3";
      };
    };
  };
}
