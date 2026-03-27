{ config, lib, pkgs, ... }:
let
  pkg = "zsh";
  cfg = config.shell.${pkg};
  homeManagerSessionVars = "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh";
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
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
      initContent = lib.strings.concatStringsSep "\n" (
        [
          ''[[ -f "${homeManagerSessionVars}" ]] && source "${homeManagerSessionVars}"''
          "${builtins.readFile ./zshrc}"
        ] ++ (
          # ls aliases
          if builtins.elem pkgs.eza config.home.packages then [
            # substitute eza if installed
            "alias ls='eza'"
            "alias la='eza -a'"
            "alias ll='eza -al'"
            "alias lt='eza -lT'"
            "alias llt='eza -alT'"
          ] else [
            "export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx"
            "alias ls='ls -Fh'"
            "alias la='ls -Fha'"
            "alias ll='ls -Fhal'"
            "alias lt=\"tree -CpDh | sed -e 's/\(.*\)\[\([^]]*\)\]/\2 \1/'\""
            "alias llt=\"tree -aCpDh | sed -e 's/\(.*\)\[\([^]]*\)\]/\2 \1/'\""
          ]
        ) ++ (
          # vi aliases
          if config.apps.nvim.enable then [
            "alias vi='nvim'"
          ] else []
        ) ++ (
          # git aliases
          if builtins.elem pkgs.git config.home.packages then [
            "alias cdr='cd $(git rev-parse --show-toplevel)'"
          ] else []
        ) ++ (
          # nix aliases
          (
            if builtins.elem pkgs.nh config.home.packages then [
              "alias nhs='nh home switch ${flakepath} --show-trace'"
            ] else []
          ) ++ (
            if config.opts.index.enable then [
              "alias nl='nix-locate'"
              "alias ,,=', -as'"
            ] else []
          )
        )
      );
    };
    programs.fzf.enableZshIntegration = true;
  };
}

