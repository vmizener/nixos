{ lib, config, ... }: {
  options = {
    wm.sway.enable = lib.mkEnableOption "enables sway wm";
  };
  config = lib.mkIf config.wm.sway.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
}
