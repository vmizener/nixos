{ config, lib, pkgs, ... }:
let
  pkg = "zsh";
  cfg = config.shell.${pkg};
  homeManagerSessionVars = "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh";
in {
  options = {
    shell.${pkg}.enable = lib.mkEnableOption "${pkg} shell";
  };
  config = lib.mkIf cfg.enable {
    home.file.".p10k.zsh" = {
      source = ./p10k.zsh;
    };
    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      initContent = lib.strings.concatStringsSep "\n" [
        ''[[ -f "${homeManagerSessionVars}" ]] && source "${homeManagerSessionVars}"''
        "${builtins.readFile ./zshrc}"
      ];
    };
    programs.fzf.enableZshIntegration = true;
  };
}

