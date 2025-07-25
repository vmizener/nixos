{ config, flakePath, lib, pkgs, ... }: {
  options = {
    modules.maestral.enable = lib.mkEnableOption "maestral";
  };
  config = lib.mkIf config.modules.maestral.enable {
    home.packages = with pkgs; [ maestral maestral-gui ];
    xdg.configFile = {
      "maestral/maestral.ini".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/maestral/maestral.ini";
    };
    systemd.user.services.maestral = {
      Unit = {
        Description = "Maestral daemon";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Type = "notify";
        NotifyAccess = "exec";
        PermissionsStartOnly = true;
        ExecStart = "${pkgs.maestral}/bin/maestral start --foreground";
        ExecStop = "${pkgs.maestral}/bin/maestral stop";
        ExecStopPost = "${pkgs.writeShellScript "maestral-stop-post.sh" ''
          if [ $SERVICE_RESULT != success ]; then ${pkgs.libnotify}/bin/notify-send 'Maestral daemon failed'; fi
        ''}";
        WatchdogSec = "30s";
        Environment = "PYTHONOPTIMIZE=2 LC_CTYPE=UTF-8";
      };
    };
    systemd.user.services.maestral-gui= {
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.maestral-gui}/bin/maestral_qt";
        RestartSec = "5";
      };
    };
  };
}
