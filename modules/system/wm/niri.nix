{ lib, config, ... }: {
  options = {
    wm.niri.enable = lib.mkEnableOption "enables niri wm";
  };
  config = lib.mkIf config.wm.niri.enable {
    programs.niri = {
      enable = true;
    };
  };
}
