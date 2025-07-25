{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    font-awesome
    inconsolata
    noto-fonts
  ];
  environment.systemPackages = with pkgs; [
    bat
    delta
    fd
    fzf
    jq
    libnotify
    ripgrep
    zsh

    home-manager
  ];
}
