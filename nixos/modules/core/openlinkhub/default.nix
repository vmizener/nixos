{ inputs, flakePath, pkgs, lib, config, ... }:
let
  cfg = config.modules.core.openlinkhub-docker;
in {
  options = {
    modules.core.openlinkhub-docker = {
      enable = lib.mkEnableOption "Docker-based OpenLinkHub service";
      autoStart = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to start OpenLinkHub container automatically";
      };
      debug = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable debug logging";
      };
      dataDir = lib.mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.local/share/openlinkhub";
        description = "Where to create and manage data files";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    # Setup directories and config
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0770 988 984 -"
      "d ${cfg.dataDir}/data 0770 988 984 -"
      "d ${cfg.dataDir}/database 0770 988 984 -"
      "d ${cfg.dataDir}/database/led 0770 988 984 -"
      "d ${cfg.dataDir}/database/rgb 0770 988 984 -"
      "d ${cfg.dataDir}/database/lcd 0770 988 984 -"
      "d ${cfg.dataDir}/database/temperatures 0770 988 984 -"
      "d ${cfg.dataDir}/database/keyboard 0770 988 984 -"
      "d ${cfg.dataDir}/database/profiles 0770 988 984 -"
    ];
    # Create container
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        openlinkhub = {
          image = "openlinkhub:latest";
          autoStart = cfg.autoStart;
        };
      };
    };
    # Create user and group
    users.groups.openlinkhub.gid = 984;
    users.users.openlinkhub = {
      uid = 988;
      group = "openlinkhub";
      isSystemUser = true;
    };
    # Open firewall port
    networking.firewall.allowedTCPPorts = [ 27003 ];
    # Required packages
    environment.systemPackages = with pkgs; [
      docker
      pciutils
      usbutils
      lshw
      hwinfo
      hidapi
      libusb1
      systemd.dev  # For libudev
    ];
  };
}
    # nixpkgs.overlays = [
    #   (final: prev: {
    #     openlinkhub = prev.openlinkhub.overrideAttrs (oldAttrs: rec {
    #       version = "0.6.1";
    #       src = prev.fetchFromGitHub {
    #         owner = "jurkovic-nikola";
    #         repo = "OpenLinkHub";
    #         tag = version;
    #         hash = "sha256-kEbJwCAs2gTNs0z8A3kOl1O4HQ4L5+urTo+hLh6vOPM=";
    #       };
    #       vendorHash = "sha256-xpIaQzl2jrWRIUe/1woODKLlwxQrdlCLkIk0qmWs7m0=";
    #     });
    #   })
    # ];
    # environment.systemPackages = [
    #   pkgs.openlinkhub
    # ];
