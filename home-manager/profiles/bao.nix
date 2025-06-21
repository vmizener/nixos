{ config, flakePath, lib, inputs, pkgs, ... }: {
  imports = [
    ../features/fuzzel
    ../features/niri
    # ../services/dropbox
    ../services/kanshi
  ];

  home.packages = with pkgs; [
    gparted
  ];

  home = {
    sessionVariables = {
      NH_FLAKE = flakePath config;
    };
    stateVersion = "23.05"; # Please read the comment before changing.
    enableNixpkgsReleaseCheck = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
  services.dropbox.enable = true;
  services.mako.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
