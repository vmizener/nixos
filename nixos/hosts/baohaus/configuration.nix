# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }: {
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    ./packages.nix

    ../../modules/applications/browsers
    ../../modules/applications/gaming.nix
    ../../modules/applications/utilities
    ../../modules/shell/xonsh
    ../../modules/wm
  ];
  networking.hostName = "baohaus"; # Define your hostname.

  browsers.firefox.enable = true;
  browsers.zen.enable = true;
  gaming.enable = true;
  shell.xonsh.enable = true;
  wm.sway.enable = true;
  wm.niri.enable = true;
  utilities.ckb-next.enable = true;

  services.displayManager.ly.enable = true;

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bao = {
    isNormalUser = true;
    description = "bao";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.xonsh;
  };
  # Enable automatic login for the user.
  services.getty.autologinUser = "bao";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # programs.zsh = {
  #   enable = true;
  #   # history.size = 10000;
  #
  #   # enableCompletions = true;
  #   # autosuggestions.enable = true;
  #   # syntaxHighlighting.enable = true;
  #
  #   shellAliases = {
  #     update = "sudo nixos-rebuild switch";
  #
  #     ll = "ls -l";
  #     la = "ls -la";
  #   };
  # };
}
