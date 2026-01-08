{ inputs, pkgs, lib, config, ... }:
let
  mod = "ckb-next";
  cfg = config.core.${mod};
in {
  options = {
    core.${mod}.enable = lib.mkEnableOption "${mod}";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.ckb-next ];
    hardware.ckb-next = {
      enable = true;
      #TODO: remove override after https://github.com/nixos/nixpkgs/issues/444209 is resolved
      package = pkgs.ckb-next.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DUSE_DBUS_MENU=0" ];
      });
    };
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

