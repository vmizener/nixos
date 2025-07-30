{ config, flakePath, inputs, lib, pkgs, ... }: {
  options = {
    apps.swww.enable = lib.mkEnableOption "swww";
  };
  config = lib.mkIf config.apps.swww.enable {
    home.packages = [ inputs.swww.packages.${pkgs.system}.swww ];
    systemd.user.services.swww = {
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${inputs.swww.packages.${pkgs.system}.swww}/bin/swww-daemon";
        RestartSec = "1";
      };
    };
  };
}
