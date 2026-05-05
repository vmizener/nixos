{ config, pkgs, ... }:
let
  flakepath = "${config.home.homeDirectory}/config";
in {
  imports = [
    ./common.nix
    ../modules/applications
    ../modules/dev
    ../modules/options
    ../modules/shell
  ];

  apps.eww.enable = true;
  apps.foot = {
    enable = true;
    font = "HackNerdFont";
  };
  apps.fuzzel.enable = true;
  apps.helium.enable = true;
  apps.kanshi.enable = true;
  apps.kitty.enable = true;
  apps.maestral.enable = true;
  apps.nvim.enable = true;
  apps.niri = {
    enable = true;
    setNixOS = true;
  };
  apps.ranger.enable = true;
  apps.awww = {
    enable = true;
    img = builtins.toPath "${flakepath}/assets/media/girls_outside_door.jpg";
  };
  # apps.webtorrent.enable = true;

  dev.c.enable = true;
  dev.golang.enable = true;
  dev.python.enable = true;
  dev.sql.enable = true;

  opts.index.enable = true;
  opts.fonts.enable = true;

  shell.zsh.enable = true;

  services.cliphist.enable = true;
  services.mako.enable = true;

  home.packages = let
    patched-ani-cli = pkgs.ani-cli.overrideAttrs (oldAttrs: rec {
      version = "4.14";
      src = pkgs.fetchFromGitHub {
        owner = "pystardust";
        repo = "ani-cli";
        tag = "v${version}";
        hash = "sha256-OyCKDN89sBz59+3JncMDyNOq8UMqqjara+A0Owo3oko=";
      };
      runtimeInputs = oldAttrs.runtimeInputs ++ [pkgs.openssl];
    });
  in with pkgs; [
    patched-ani-cli

    animdl
    cava
    mako
    spotify
    spotify-player
    spotify-tray

    evince
    (texlive.combine {
      inherit (texlive)
      scheme-basic
      dvisvgm
      dvipng # for preview and export as html
      wrapfig
      amsmath
      ulem
      hyperref
      capt-of;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
    })
  ];
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      NH_FLAKE = "${flakepath}";
    };
  };
}
