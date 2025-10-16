{ pkgs, lib, config, inputs, ... }: {
  options = {
    wm.niri.enable = lib.mkEnableOption "enables niri wm";
  };
  config = lib.mkIf config.wm.niri.enable {
    programs.niri.enable = true;
    programs.uwsm.waylandCompositors = {
      enable = true;
      niri = {
        compositorPrettyName = "Niri";
        compositorComment = "Niri compositor managed by UWSM";
        compositorBinPath = "/run/current-system/sw/bin/niri-session";
      };
    };
    systemd.services.display-manager.environment = {
      XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";
    };
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };
}
