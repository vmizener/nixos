{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    btop
    dex
    fastfetch
    grim
    htop
    mpv
    nh
    pavucontrol
    slurp
    unzip
    wl-clipboard
    wdisplays
    wev
    wofi
    zip
  ];

  home = {
    stateVersion = "23.05"; # Please read the comment before changing.
    enableNixpkgsReleaseCheck = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
