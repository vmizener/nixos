# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }: {
  imports = [
    ../common.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/applications/browsers
    ../../modules/applications/gaming.nix
    ../../modules/applications/utilities
    ../../modules/system/wm
  ];
  networking.hostName = "baohaus"; # Define your hostname.

  browsers.firefox.enable = true;
  browsers.zen.enable = true;
  gaming.enable = true;
  wm.sway.enable = true;
  wm.niri.enable = true;
  utilities.ckb-next.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bao = {
    isNormalUser = true;
    description = "bao";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "bao";

  fonts.packages = with pkgs; [
    font-awesome
    inconsolata
    noto-fonts
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    findutils
    mlocate

    lua
    luajit

    ani-cli
    bc
    delta
    eww
    fd
    fzf
    home-manager
    jq
    # kanshi
    killall
    kitty
    git
    grim
    ripgrep
    slurp
    tree
    wl-clipboard
    mako
    mpv
    neovim
    pavucontrol
    usbutils
    vim
    yadm
    zsh
    wdisplays
    wev
    wget
    wofi
  ];

  programs.zsh = {
    enable = true;
    # history.size = 10000;

    # enableCompletions = true;
    # autosuggestions.enable = true;
    # syntaxHighlighting.enable = true;

    shellAliases = {
      update = "sudo nixos-rebuild switch";

      ll = "ls -l";
      la = "ls -la";
    };
  };

  services.displayManager.ly.enable = true;
}
