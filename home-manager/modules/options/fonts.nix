{ config, lib, pkgs, ... }:
let
  cfg = config.opts.fonts;
in {
  options = {
    opts.fonts.enable = lib.mkEnableOption "fonts";
  };
  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.inconsolata
    ];
  };
}
