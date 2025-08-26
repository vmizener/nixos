{ config, lib, pkgs, ... }:
let
  module = "sql";
  cfg = config.dev.${module};
in {
  options = {
    dev.${module}.enable = lib.mkEnableOption "${module}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sqlc
      sqlite-interactive
    ] ++ lib.optionals config.dev.golang.enable [
      pkgs.goose
    ];
  };
}
