{ config, flakePath, pkgs, ... }: {
  home.packages = with pkgs; [
    kanshi
  ];

  services.kanshi = {
      enable = true;
  };
  systemd.user.services.kanshi = {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanshi}/bin/kanshi";
      RestartSec = "1";
    };
  };
}
