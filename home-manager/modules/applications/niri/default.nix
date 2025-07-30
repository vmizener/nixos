{ config, flakePath, lib, pkgs, ... }: {
  options = {
    apps.niri.enable = lib.mkEnableOption "niri";
  };
  config = lib.mkIf config.apps.niri.enable {
    home.packages = with pkgs; [ ];
    xdg.configFile = {
      "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/applications/niri/niri-config.kdl";
    };
    # Nix packages configure Chrome and Electron apps to run in native Wayland
    # mode if this environment variable is set.
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
