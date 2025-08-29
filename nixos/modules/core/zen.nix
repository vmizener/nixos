# See https://github.com/linuxmobile/kaku/blob/niri/home/software/browsers/zen.nix
{ inputs, pkgs, lib, config, ... }:
let
  mod = "zen";
  cfg = config.core.${mod};
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
    core.${mod}.enable = lib.mkEnableOption "${mod}";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ zenWithWayland ];
  };
}
