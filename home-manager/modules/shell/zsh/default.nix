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
    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      initContent = lib.mkOrder 550 "${builtins.readFile ./zshrc}";
      initExtra = ''
        [[ -f "${homeManagerSessionVars}" ]] && source "${homeManagerSessionVars}"
      '';
    };
    programs.fzf.enableZshIntegration = true;
  };
}

