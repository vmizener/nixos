# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  hostname = "baohaus";
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
  networking.hostName = "${hostname}"; # Define your hostname.

  shell.xonsh.enable = true;

  wm.sway.enable = true;
  wm.niri.enable = true;

  # core.ckb-next.enable = true;
  core.gaming.enable = true;
  core.thunar.enable = true;
  core.virtualization = {
    enable = true;
    users = [ "${username}" ];
  };

  core.firefox.enable = true;
  core.zen.enable = true;

  services.displayManager.ly.enable = true;

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

  # Enable early OOM killing
  services.earlyoom = {
    enable = true;

    freeMemThreshold = 10; # Start monitoring when free memory is below 10%
    freeMemKillThreshold = 5; # Kill processes when free memory is below 5%

    # Enable desktop notifications
    # Should only use on machines where all users are trusted
    enableNotifications = true;

    extraArgs = let
      plist = l: "^(" + (lib.strings.concatStringsSep "|" l) + ")$";
    in [
      "--prefer"
      (plist [
        ".zen-wrapped"
        "Web Content"
      ])
      "--avoid"
      (plist [
        "systemd" # Avoid killing systemd processes
      ])
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
