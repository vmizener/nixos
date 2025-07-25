{ config, flakePath, inputs, lib, pkgs, ... }: {
  options = {
    modules.webtorrent.enable = lib.mkEnableOption "webtorrent";
  };
  config = lib.mkIf config.modules.webtorrent.enable {
    home.packages = [ pkgs.webtorrent_desktop ];
  };
}
