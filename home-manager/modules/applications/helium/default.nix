{ config, lib, inputs, system, ... }:
let
  cfg = config.apps.helium;
in {
  options = {
    apps.helium.enable = lib.mkEnableOption "helium";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.helium.packages.${system}.default
    ];
  };
}
