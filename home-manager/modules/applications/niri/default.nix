{ config, inputs, lib, pkgs, ... }:
let
  app = "niri";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  imports = [ inputs.niri.homeModules.niri ];
  options = {
    apps.niri.enable = lib.mkEnableOption "${app}";
    apps.niri.useFlake = lib.mkEnableOption "use flake-defined niri bin";
    apps.niri.setNixOS = lib.mkEnableOption "set nixos relevant flags";
  };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.setNixOS {
      # Nix packages configure Chrome and Electron apps to run in native Wayland
      # mode if this environment variable is set.
      home.sessionVariables.NIXOS_OZONE_WL = "1";
    })

    {
      xdg.configFile = {
        "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/niri/niri-config.kdl";
        "niri/binds.kdl".source = pkgs.writeText "binds.kdl" (lib.strings.concatStringsSep "\n" (let
          bind = key: desc: flags: cmd: (
            if ("${cmd}" == "")
              then ""
            else (lib.strings.concatStringsSep " " [
              "${key}"
              "hotkey-overlay-title=\"${desc}\""
              (lib.strings.concatStringsSep " " flags)
              "{ ${cmd}; }"
            ])
          );
        in [
          "binds {"
          (
            bind "Mod+Return" "Open Terminal" [ "repeat=false" ] (
              if config.apps.foot.enable
                then ''spawn "foot"''
              else  if config.apps.kitty.enable
                then ''spawn "kitty"''
              else lib.warn "Niri: No Terminal" ""
            )
          )
          (
            bind "Mod+D" "Application Launcher" [ "repeat=false" ] (
              if config.shell.dms.enable
                then ''spawn "dms" "ipc" "spotlight" "open"''
              else if config.apps.fuzzel.enable
                then ''spawn "fuzzel"''
              else lib.warn "Niri: No Application Launcher" ""
            )
          )
          (
            bind "Mod+Shift+P" "Toggle Power Menu" [ "repeat=false" ] (
              if config.shell.dms.enable
                then ''spawn "dms" "ipc" "powermenu" "toggle"''
              else lib.warn "Niri: No Power Menu" ""
            )
          )
          (
            bind "Mod+E" "Dismiss Notifications" [] (
              if config.shell.dms.enable
                then ''spawn "dms" "ipc" "call" "notifications" "toggle"''
              else if config.services.mako.enable
                then ''spawn "makoctl" "dismiss" "-a"''
              else lib.warn "Niri: No Notification Manager" ""
            )
          )
          (
            bind "Mod+Shift+E" "Toggle Recent Notification(s)" [] (
              if config.shell.dms.enable
                then ''spawn "dms" "ipc" "call" "notifications" "toggle"''
              else if config.services.mako.enable
                then ''spawn "makoctl" "restore"''
              else lib.warn "Niri: No Notification Manager" ""
            )
          )
          (
            bind "Mod+P" "Show Clipboard" [ "repeat=false" ] (
              if config.shell.dms.enable
                then ''spawn "dms" "ipc" "call" "clipboard" "toggle"''
              else if config.services.cliphist.enable
                then ''spawn-sh "cliphist list | fuzzel -d | cliphist decode | wl-copy"''
              else lib.warn "Niri: No Clipboard Manager" ""
            )
          )
          "}"
        ]));
      };
    }

    (lib.mkIf cfg.useFlake {
      nixpkgs.overlays = [ inputs.niri.overlays.niri ];
      home.packages = [ pkgs.xwayland-satellite ];
      targets.genericLinux.nixGL = {
        packages = inputs.nixgl.packages;
      };
      programs.niri = {
        enable = true;
        package = config.lib.nixGL.wrap pkgs.niri-unstable;
      };
    })
  ]);
}
