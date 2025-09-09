{ config, inputs, lib, pkgs, ... }:
let
  app = "swww";
  cfg = config.apps.${app};
in {
  options = {
    apps.swww.enable = lib.mkEnableOption "${app}";
    apps.swww.pkg = lib.mkOption {
      type = lib.types.package;
      default = inputs.swww.packages.${pkgs.system}.swww;
      description = "SWWW package to use";
    };
    apps.swww.img = lib.mkOption {
      type = lib.types.path;
      default = ../../../../assets/media/waneela_pixel_city_art.gif;
      description = "Image to display";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.pkg ];
    systemd.user.services.swww = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Unit = {
        Description = "SWWW daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${cfg.pkg}/bin/swww-daemon";
        ExecStartPost = "${cfg.pkg}/bin/swww img ${cfg.img}";
        ExecStop = "${cfg.pkg}/bin/swww kill";
        RestartSec = "3";
      };
    };
  };
}
