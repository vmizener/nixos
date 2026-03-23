{ config, inputs, lib, pkgs, ... }:
let
  app = "niri";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  imports = [ inputs.niri.homeModules.niri ];
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    home.packages = [ pkgs.xwayland-satellite ];
    targets.genericLinux.nixGL = {
      packages = inputs.nixgl.packages;
    };
    programs.niri = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.niri-unstable;
      settings = {
        input = {
          keyboard.numlock = true;
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
          # Focus windows and outputs automatically when moving the mouse into them.
          # Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
          focus-follows-mouse.max-scroll-amount = "0%";
        };
        environment = {
          DISPLAY = ":0";
          QT_QPA_PLATFORM = "wayland";
          WAYLAND_DISPLAY = "wayland-1";
        };
        layout = {
          gaps = 10;
          background-color = "transparent";
          center-focused-column = "never";
          always-center-single-column = true;

          preset-column-widths = [
            { proportion = 2. / 6.; }
            { proportion = 3. / 6.; }
            { proportion = 4. / 6.; }
            { proportion = 1.; }
          ];
          preset-window-heights = [
            { proportion = 1. / 2.; }
            { proportion = 1.; }
          ];
          default-column-width = { proportion = 1. / 2.; };

          focus-ring = {
            width = 4;
            active.color = "#7fc8ff44";
            inactive.color = "#50505055";
          };
          border = {
            enable = false;
          };
          shadow = {
            enable = true;
            softness = 30;
            spread = 5;
            offset = { x = 0; y = 5; };
            color = "#0007";
          };
          tab-indicator = {
            hide-when-single-tab = true;
            place-within-column = true;
            gap = 5;
            width = 4;
            length.total-proportion = 1.;
            position = "right";
            gaps-between-tabs = 2;
            corner-radius = 8;
            active.gradient = {
              from = "#80c8ff";
              to = "#bbddff";
              angle = 45;
            };
            inactive.gradient = {
              from = "#505050";
              to = "#808080";
              angle = 45;
              relative-to = "workspace-view";
            };
            urgent.gradient = {
              from = "#800";
              to = "#a33";
              angle = 45;
            };
          };
        };
        spawn-at-startup = [
          { argv = [ "dbus-update-activation-environment" "--systemd" "DISPLAY" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP=X-NIXOS-SYSTEMD-AWARE" ]; }
          { argv = [ "xwayland-satellite" ]; }
        ];
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        window-rules = [
          {
            matches = [ { app-id = "^(firefox|zen|zen-beta)$"; title = "^Picture-in-Picture$"; } ];
            default-floating-position = { x = 0; y = 0; relative-to = "top-right"; };
            default-column-width.proportion = 0.5;
            default-window-height.proportion = 0.5;
            open-floating = true;
          }
          {
            # Dim inactive floating windows
            matches = [ { is-focused = false; is-floating = true; } ];
            opacity = 0.6;
          }
          {
            # MPV
            matches = [ { app-id = "^mpv$"; } ];
            open-floating = true;
          }
          {
            # Chrome - Meet Pop-Up
            matches = [ { app-id = "^google-chrome$"; title = "^Meet -.*$"; } ];
            excludes = [ { app-id = "^google-chrome$"; title = "^Meet -.*- Google Chrome$"; } ];
            open-floating = true;
            opacity = 0.8;
            default-column-width.proportion = 0.5;
            default-window-height.proportion = 0.5;
            default-floating-position = { x = 10; y = 10; relative-to = "top-right"; };
          }

        ];

        layer-rules = [
          {
            matches = [ { namespace = "^awww-daemon$"; } ];
            place-within-backdrop = true;
          }
        ];
        overview.workspace-shadow.enable = false;

        binds = {
          "Mod+Shift+Slash".action.show-hotkey-overlay = [];
          "Mod+Shift+O".action.toggle-window-rule-opacity = [];

          "Mod+Return" = {
            hotkey-overlay.title = "Open a Terminal";
            action.spawn = (
              if config.apps.foot.enable
                then "foot"
              else if config.apps.kitty.enable
                then "kitty"
              else ""
            );
            repeat = false;
          };
          "Mod+D" = {
            hotkey-overlay.title = "Run an Application";
            repeat = false;
            action.spawn = (
              if config.shell.dms.enable
                then [ "dms" "ipc" "spotlight" "open" ]
              else if config.apps.fuzzel.enable
                then [ "fuzzel" ]
              else []
            );
          };
          "Mod+Shift+P" = {
            hotkey-overlay.title = "Toggle Power Menu";
            repeat = false;
            action.spawn = (
              if config.shell.dms.enable
                then [ "dms" "ipc" "powermenu" "toggle" ]
              else []
            );
          };
          # "Super+Alt+L" = {
          #   hotkey-overlay.title = "Lock the Screen: swaylock";
          #   repeat = false;
          #   action.spawn = "swaylock";
          # };
          # Utilities
          "Mod+E" = {
            hotkey-overlay.title = "Dismiss Notifications";
            action.spawn = (
              if config.shell.dms.enable
                then [ "dms" "ipc" "call" "notifications" "dismissAllPopups" ]
              else if config.apps.mako.enable
                then [ "makoctl" "dismiss" "-a" ]
              else []
            );
          };
          "Mod+Shift+E" = {
            hotkey-overlay.title = "Toggle Recent Notification(s)";
            action.spawn = (
              if config.shell.dms.enable
                then [ "dms" "ipc" "call" "notifications" "toggle" ]
              else if config.apps.mako.enable
                then [ "makoctl" "restore" ]
              else []
            );
          };
          "Mod+P" = {
            hotkey-overlay.title = "Show Clipboard";
            action.spawn = (
              if config.shell.dms.enable
                then [ "dms" "ipc" "call" "clipboard" "toggle" ]
              else if config.apps.cliphist.enable
                then [ "cliphist list | fuzzel -d | cliphist decode | wl-copy" ]
              else []
            );
          };

          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
          };

          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action.spawn = [ "brightnessctl" "set" "+5%" ];
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action.spawn = [ "brightnessctl" "set" "5%-" ];
          };
          "Shift+XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action.spawn = [ "brightnessctl" "set" "+1%" ];
          };
          "Shift+XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action.spawn = [ "brightnessctl" "set" "1%-" ];
          };

          # Open/close the Overview: a zoomed-out view of workspaces and windows.
          # You can also move the mouse into the top-left hot corner,
          # or do a four-finger swipe up on a touchpad.
          "Mod+O" = {
            repeat = false;
            action.toggle-overview = [];
          };

          "Mod+Shift+Q".action.close-window = [];
          "Mod+Ctrl+MouseRight".action.close-window = [];

          "Mod+Left".action.focus-column-or-monitor-left = [];
          "Mod+Down".action.focus-window-or-workspace-down = [];
          "Mod+Up".action.focus-window-or-workspace-up= [];
          "Mod+Right".action.focus-column-or-monitor-right = [];
          "Mod+H".action.focus-column-or-monitor-left = [];
          "Mod+J".action.focus-window-or-workspace-down = [];
          "Mod+K".action.focus-window-or-workspace-up= [];
          "Mod+L".action.focus-column-or-monitor-right = [];

          "Mod+Ctrl+Left".action.move-column-left-or-to-monitor-left = [];
          "Mod+Ctrl+Down".action.move-window-down-or-to-workspace-down = [];
          "Mod+Ctrl+Up".action.move-window-up-or-to-workspace-up = [];
          "Mod+Ctrl+Right".action.move-column-right-or-to-monitor-right = [];
          "Mod+Ctrl+H".action.move-column-left-or-to-monitor-left = [];
          "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = [];
          "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = [];
          "Mod+Ctrl+L".action.move-column-right-or-to-monitor-right = [];

          "Mod+Home".action.focus-column-first = [];
          "Mod+End".action.focus-column-last = [];
          "Mod+Ctrl+Home".action.move-column-to-first = [];
          "Mod+Ctrl+End".action.move-column-to-last = [];

          "Mod+Shift+Left".action.focus-monitor-left = [];
          "Mod+Shift+Down".action.focus-monitor-down = [];
          "Mod+Shift+Up".action.focus-monitor-up = [];
          "Mod+Shift+Right".action.focus-monitor-right = [];
          "Mod+Shift+H".action.focus-monitor-left = [];
          "Mod+Shift+J".action.focus-monitor-down = [];
          "Mod+Shift+K".action.focus-monitor-up = [];
          "Mod+Shift+L".action.focus-monitor-right = [];

          "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
          "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];
          "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];
          "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [];
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [];
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [];
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [];

          "Mod+Page_Down".action.focus-workspace-down = [];
          "Mod+Page_Up".action.focus-workspace-up = [];
          "Mod+U".action.focus-workspace-down = [];
          "Mod+I".action.focus-workspace-up = [];
          "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [];
          "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [];
          "Mod+Ctrl+U".action.move-column-to-workspace-down = [];
          "Mod+Ctrl+I".action.move-column-to-workspace-up = [];

          "Mod+Shift+Page_Down".action.move-workspace-down = [];
          "Mod+Shift+Page_Up".action.move-workspace-up = [];
          "Mod+Shift+U".action.move-workspace-down = [];
          "Mod+Shift+I".action.move-workspace-up = [];

          "Mod+WheelScrollDown" = { cooldown-ms = 100; action.focus-workspace-down = []; };
          "Mod+WheelScrollUp" = { cooldown-ms = 100; action.focus-workspace-up = []; };
          "Mod+Grave".action.focus-workspace-previous = [];
          "Mod+Backslash".action.focus-workspace-previous = [];

          "Mod+WheelScrollRight".action.focus-column-right = [];
          "Mod+WheelScrollLeft".action.focus-column-left = [];

          "Mod+Ctrl+WheelScrollDown".action.focus-column-right-or-first = [];
          "Mod+Ctrl+WheelScrollUp".action.focus-column-left-or-last = [];

          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+0".action.focus-workspace = 10;
          "Mod+Ctrl+1".action.move-column-to-workspace = 1;
          "Mod+Ctrl+2".action.move-column-to-workspace = 2;
          "Mod+Ctrl+3".action.move-column-to-workspace = 3;
          "Mod+Ctrl+4".action.move-column-to-workspace = 4;
          "Mod+Ctrl+5".action.move-column-to-workspace = 5;
          "Mod+Ctrl+6".action.move-column-to-workspace = 6;
          "Mod+Ctrl+7".action.move-column-to-workspace = 7;
          "Mod+Ctrl+8".action.move-column-to-workspace = 8;
          "Mod+Ctrl+9".action.move-column-to-workspace = 9;
          "Mod+Ctrl+0".action.move-column-to-workspace = 10;

          # Moves focus to adjacent workspaces.
          "Mod+Tab".action.focus-window-or-workspace-down = [];
          "Mod+Shift+Tab".action.focus-window-or-workspace-up = [];
          # Cycle focus to adjacent columns.
          "Mod+Ctrl+Tab".action.focus-column-right-or-first = [];
          "Mod+Ctrl+Shift+Tab".action.focus-column-left-or-last = [];

          # The following binds move the focused window in and out of a column.
          # If the window is alone, they will consume it into the nearby column to the side.
          # If the window is already in a column, they will expel it out.
          "Mod+BracketLeft".action.consume-or-expel-window-left = [];
          "Mod+BracketRight".action.consume-or-expel-window-right = [];

          # Consume one window from the right to the bottom of the focused column.
          "Mod+Comma".action.consume-window-into-column = [];
          # Expel the bottom window from the focused column to the right.
          "Mod+Period".action.expel-window-from-column = [];

          "Mod+R".action.switch-preset-column-width = [];
          "Mod+Shift+R".action.switch-preset-window-height = [];
          "Mod+Ctrl+R".action.reset-window-height = [];
          "Mod+F".action.maximize-window-to-edges = [];
          "Mod+Shift+F".action.fullscreen-window = [];

          # Expand the focused column to space not taken up by other fully visible columns.
          # Makes the column "fill the rest of the space".
          "Mod+Ctrl+F".action.expand-column-to-available-width = [];

          "Mod+C".action.center-column = [];

          # Center all fully visible columns on screen.
          "Mod+Ctrl+C".action.center-visible-columns = [];

          # Finer width adjustments.
          # This command can also:
          # * set width in pixels: "1000"
          # * adjust width in pixels: "-5" or "+5"
          # * set width as a percentage of screen width: "25%"
          # * adjust width as a percentage of screen width: "-10%" or "+10%"
          # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
          # set-column-width "100" will make the column occupy 200 physical screen pixels.
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";

          # Finer height adjustments when in column with other windows.
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          # Move the focused window between the floating and the tiling layout.
          "Mod+Space".action.toggle-window-floating = [];
          "Mod+Shift+Space".action.switch-focus-between-floating-and-tiling = [];

          # Toggle tabbed column display mode.
          # Windows in this column will appear as vertical tabs,
          # rather than stacked on top of each other.
          "Mod+W".action.toggle-column-tabbed-display = [];

          "Print".action.screenshot = [];
          "Ctrl+Print".action.screenshot-screen = [];
          "Alt+Print".action.screenshot-window = [];

          # Applications such as remote-desktop clients and software KVM switches may
          # request that niri stops processing the keyboard shortcuts defined here
          # so they may, for example, forward the key presses as-is to a remote machine.
          # It's a good idea to bind an escape hatch to toggle the inhibitor,
          # so a buggy application can't hold your session hostage.
          #
          # The allow-inhibiting=false property can be applied to other binds as well,
          # which ensures niri always processes them, even when an inhibitor is active.
          "Mod+Escape" = {
            allow-inhibiting = false;
            action.toggle-keyboard-shortcuts-inhibit = [];
          };

          # The quit action will show a confirmation dialog to avoid accidental exits.
          "Ctrl+Alt+Delete".action.quit = [];

          # Powers off the monitors. To turn them back on, do any input like
          # moving the mouse or pressing any other key.
          "Mod+Ctrl+Shift+P".action.power-off-monitors = [];
        };
      };
    };
    # xdg.configFile = {
    #   "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/niri/niri-config.kdl";
    # };
    # Nix packages configure Chrome and Electron apps to run in native Wayland
    # mode if this environment variable is set.
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
