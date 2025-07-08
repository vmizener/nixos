# See https://github.com/linuxmobile/kaku/blob/niri/home/software/browsers/zen.nix
{ inputs, pkgs, lib, config, ... }:
let
  # Create a wrapper script for zen-browser with Wayland enabled
  zenWithWayland = pkgs.symlinkJoin {
    name = "zen-browser-wayland";
    paths = [inputs.zen-browser.packages."${pkgs.system}".default];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/zen \
        --set MOZ_ENABLE_WAYLAND 1
    '';
  };
in {
  options = {
    browsers.zen.enable = lib.mkEnableOption "zen browser";
  };
  config = lib.mkIf config.browsers.zen.enable {
    environment.systemPackages = [zenWithWayland];
  };
}
