{ config, lib, pkgs, inputs, ... }:
let
  pkg = "dms";
  cfg = config.shell.${pkg};
  sys = pkgs.stdenv.hostPlatform.system;
in {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.danksearch.homeModules.default
  ];
  options = {
    shell.${pkg}.enable = lib.mkEnableOption "${pkg} shell";
  };
  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      dgop.package = inputs.dgop.packages.${sys}.default;

      systemd = {
        enable = true;             # Systemd service for auto-start
        restartIfChanged = true;   # Auto-restart dms.service when dank-material-shell changes
      };

      enableSystemMonitoring = true;     # System monitoring widgets (dgop)
      enableVPN = true;                  # VPN management widget
      enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
      enableAudioWavelength = true;      # Audio visualizer (cava)
      enableCalendarEvents = true;       # Calendar integration (khal)
      enableClipboardPaste = true;       # Pasting items from the clipboard (wtype)
    };
    programs.dsearch.enable = true;
  };
}

