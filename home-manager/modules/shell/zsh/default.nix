{ config, lib, pkgs, ... }:
let
  pkg = "zsh";
  cfg = config.shell.${pkg};
in {
  options = {
    shell.${pkg}.enable = lib.mkEnableOption "${pkg} shell";
  };
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      initContent = lib.mkOrder 550 "${builtins.readFile ./zshrc}";
      # initExtra = my_zsh_config;
    };
    programs.fzf.enableZshIntegration = true;
  };
}

