{ inputs, pkgs, lib, config, ... }: {
  options = {
    gaming.enable = lib.mkEnableOption "gaming mode";
  };
  config = lib.mkIf config.gaming.enable {
    environment.systemPackages = with pkgs; [
      discord
      mpv
      streamlink
      streamlink-twitch-gui-bin
    ];
    programs.steam = {
        enable = true;
        # gamescopeSession.enable = true;
    };
  };
}

