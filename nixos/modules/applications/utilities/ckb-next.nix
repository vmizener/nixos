{ inputs, pkgs, lib, config, ... }: {
  options = {
    utilities.ckb-next.enable = lib.mkEnableOption "ckb-next";
  };
  config = lib.mkIf config.utilities.ckb-next.enable {
    environment.systemPackages = [pkgs.ckb-next];
    hardware.ckb-next.enable = true;
    systemd.user.services.ckb-next = {
      enable = true;
      description = "Corsair keyboard next service";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.ckb-next}/bin/ckb-next -b";
        Restart = "on-failure";
        RestartSec = "3";
      };
      wantedBy = [ "default.target" ];
    };
  };
}

