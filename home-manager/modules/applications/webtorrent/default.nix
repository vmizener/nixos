{ config, flakePath, inputs, lib, pkgs, ... }: {
  options = {
    apps.webtorrent.enable = lib.mkEnableOption "webtorrent";
  };
  config = lib.mkIf config.apps.webtorrent.enable {
    home.packages = [ pkgs.webtorrent_desktop ];
  };
}
