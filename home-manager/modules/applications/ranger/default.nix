{ config, lib, pkgs, ... }:
let
  app = "ranger";
  cfg = config.apps.${app};
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ imagemagick ];
    programs.ranger = {
      enable = true;
      package = pkgs.ranger.overrideAttrs (old: {
        src = fetchGit {
          url = "https://github.com/ranger/ranger";
          rev = "b31db0f638118c103a35be5a57d1a0f3609838d6";  #changed depending on HEAD
        };
      });
      extraConfig = ''
        set preview_images true
        set preview_images_method sixel
      '';
    };
  };
}
