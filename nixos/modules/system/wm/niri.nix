{ pkgs, lib, config, inputs, ... }: {
  options = {
    wm.niri.enable = lib.mkEnableOption "enables niri wm";
  };
  config = lib.mkIf config.wm.niri.enable {
    programs.niri = {
      enable = true;
    };
    systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ] ++ [
      inputs.swww.packages.${pkgs.system}.swww
    ];
  };
}
