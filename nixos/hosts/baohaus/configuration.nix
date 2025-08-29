# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  username = "bao";
in {
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    ./packages.nix

    ../../modules/core
    ../../modules/shell/xonsh
    ../../modules/wm
  ];
  networking.hostName = "baohaus"; # Define your hostname.

  shell.xonsh.enable = true;

  wm.sway.enable = true;
  wm.niri.enable = true;

  core.ckb-next.enable = true;
  core.gaming.enable = true;
  core.thunar.enable = true;

  core.firefox.enable = true;
  core.zen.enable = true;

  services.displayManager.ly.enable = true;

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.xonsh;
  };
  # Enable automatic login for the user.
  services.getty.autologinUser = "${username}";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
