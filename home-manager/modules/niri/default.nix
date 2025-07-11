{ config, flakePath, lib, pkgs, ... }: {
  options = {
    modules.niri.enable = lib.mkEnableOption "niri";
  };
  config = lib.mkIf config.modules.niri.enable {
    home.packages = with pkgs; [ ];
    xdg.configFile = {
      "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${flakePath config}/home-manager/modules/niri/niri-config.kdl";
    };
    # Nix packages configure Chrome and Electron apps to run in native Wayland
    # mode if this environment variable is set.
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
