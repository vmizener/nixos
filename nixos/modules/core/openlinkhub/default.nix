{ inputs, pkgs, unstable-pkgs, lib, config, ... }:
let
  cfg = config.modules.core.openlinkhub;
  version = "0.6.0";
  remoteSource = pkgs.fetchFromGitHub {
    owner = "jurkovic-nikola";
    repo = "OpenLinkHub";
    tag = version;
    hash = "sha256-pCMdljBgqxfI9mVperzjAiuq5UUsqmmR+xvuywudv9o=";
  };
in {
  options = {
    modules.core.openlinkhub = with lib; {
      enable = mkEnableOption "OpenLinkHub service";
      autoStart = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to start OpenLinkHub automatically";
      };
      debug = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable debug logging";
      };
      user = mkOption {
        type = types.str;
        description = "User to add to required groups";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    # Required packages
    environment.systemPackages = [ unstable-pkgs.openlinkhub ] ++ (with pkgs; [
      pciutils
      curl
      rsync
      rocmPackages.rocm-smi
      radeontop
      (pkgs.writeShellScriptBin "amd-smi" ''
          exec ${pkgs.rocmPackages.rocm-smi}/bin/rocm-smi "$@"
      '')
    ]);

    # Create openlinkhub user and group
    users.groups.openlinkhub = {};
    users.users.openlinkhub = {
      group = "openlinkhub";
      isSystemUser = true;
      extraGroups = [ "input" ];
    };

    # Add user to required groups
    users.users.${cfg.user}.extraGroups = [ "openlinkhub" "plugdev" ];

    # Add udev rules for Corsair devices
    services.udev.extraRules = (builtins.readFile "${remoteSource}/99-openlinkhub.rules");

    # Open required port
    networking.firewall.allowedTCPPorts = [ 27003 ];

    # Setup directories and config
    systemd.tmpfiles.rules = [
      "d /opt/openlinkhub 0771 988 984 -"
      "d /opt/openlinkhub/data 0771 988 984 -"
      "d /opt/openlinkhub/database 0771 988 984 -"
      "d /opt/openlinkhub/database/led 0771 988 984 -"
      "d /opt/openlinkhub/database/rgb 0771 988 984 -"
      "d /opt/openlinkhub/database/lcd 0771 988 984 -"
      "d /opt/openlinkhub/database/temperatures 0771 988 984 -"
      "d /opt/openlinkhub/database/keyboard 0771 988 984 -"
      "d /opt/openlinkhub/database/profiles 0771 988 984 -"
      "L /opt/openlinkhub/config.json - - - - ${pkgs.writeTextFile {
        name = "config.json";
        text = ''
        {
          "debug": ${if cfg.debug then "true" else "false"},
          "listenPort": 27003,
          "listenAddress": "0.0.0.0",
          "logLevel": ${if cfg.debug then "\"debug\"" else "\"info\""},
          "checkDevicePermission": false
        }
        '';
      }}"
      "L /opt/openlinkhub/static/ - - - - ${remoteSource}/static/"
      "L /opt/openlinkhub/web/ - - - - ${remoteSource}/web/"
    ];

    # Service configuration
    systemd.user.services.openlinkhub = {
      description = "OpenLinkHub Service";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = lib.mkIf cfg.autoStart [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        # ExecStartPre = [
        #   (pkgs.writeShellScript "openlinkhub-setup" ''
        #     chown -R ${cfg.user}:users /opt/openlinkhub
        #   '');
        # ];
        ExecStart = builtins.toString (pkgs.writeShellScript "openlinkhub-wrapper" ''
          # Include pciutils in PATH to fix "lspci not found" error
          # Include pciutils in PATH to fix "lspci not found" error
          export PATH=${lib.makeBinPath [ unstable-pkgs.openlinkhub pkgs.pciutils ]}:$PATH
          cd /opt/openlinkhub
          # Run with debug output
          exec ${unstable-pkgs.openlinkhub}/bin/OpenLinkHub
        '');
        Restart = "on-failure";
        RestartSec = 5;
      };
        # ExecStartPre = [
#           # First ExecStartPre: create directories and set up files
#           (pkgs.writeShellScript "openlinkhub-setup" ''
#
#             # Set up rgb.json if needed
#             if [ ! -f /home/tim/.local/share/openlinkhub/database/rgb.json ]; then
#               cat > /home/tim/.local/share/openlinkhub/database/rgb.json << EOF
# {
#   "defaultColor": {
#     "red": 255,
#     "green": 255,
#     "blue": 255,
#     "brightness": 1
#   },
#   "device": "iCUE LINK System Hub",
#   "profiles": {
#     "static": {
#       "speed": 4,
#       "brightness": 1,
#       "startColor": {
#         "red": 0,
#         "green": 255,
#         "blue": 255,
#         "brightness": 1
#       },
#       "endColor": {
#         "red": 0,
#         "green": 255,
#         "blue": 255,
#         "brightness": 1
#       }
#     }
#   }
# }
# EOF
#             fi

          #   # Ensure correct permissions
          #   chown -R tim:users /home/tim/.local/share/openlinkhub
          # '')
    };
  };
}
