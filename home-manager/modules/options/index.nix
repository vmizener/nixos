{ config, inputs, lib, pkgs, ... }:
let
  cfg = config.opts.index;
in {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];
  options = {
    opts.index.enable = lib.mkEnableOption "index";
  };
  config = lib.mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
    };
    home.packages = [ pkgs.comma ];
  };
}
