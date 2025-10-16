{ inputs, pkgs, lib, config, ... }:
let
  mod = "virtualization";
  cfg = config.core.${mod};
in {
  options = {
    core.virtualization.enable = lib.mkEnableOption "${mod}";
    core.virtualization.users = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      description = "VM users";
    };
  };
  config = lib.mkIf cfg.enable {
    # Docker
    virtualisation.docker = {
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      autoPrune = {
        enable = true;
        dates = "weekly"; # Prune weekly
        flags = [ "--all" "--volumes" ]; # Prune all unused images, containers, networks, and volumes
        persistent = true;
        randomizedDelaySec = "1hr"; # Random delay up to 1 hour
      };
    };

    # Virt-Manager
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = cfg.users;
    users.users = lib.attrsets.genAttrs cfg.users (user: {
      extraGroups = [ "libvirtd" ];
    });
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}

