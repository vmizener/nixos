# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }: {
  imports = [
    ../common.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/browsers
  ];
  networking.hostName = "baohaus"; # Define your hostname.

  browsers.firefox.enable = true;
  browsers.zen.enable = true;

  hardware.ckb-next.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bao = {
    isNormalUser = true;
    description = "bao";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "bao";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ani-cli
    bc
    ckb-next
    delta
    discord
    eww
    home-manager
    jq
    kanshi
    killall
    kitty
    git
    grim
    slurp
    tree
    wl-clipboard
    mako
    mpv
    neovim
    pavucontrol
    streamlink
    streamlink-twitch-gui-bin
    vim
    yadm
    zsh
    wdisplays
    wget
    wofi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.gnome.gnome-keyring.enable = true;

  programs.steam = {
    enable = true;
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

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
}
