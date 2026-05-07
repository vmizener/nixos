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
        let
          ifPkg = p: lines: (if builtins.elem p config.home.packages then lines else []);
          ifElsePkg = p: tLines: fLines: (if builtins.elem p config.home.packages then tLines else fLines);
          ifOpt = o: lines: (if o then lines else []);
        in
        [
          ''[[ -f "${homeManagerSessionVars}" ]] && source "${homeManagerSessionVars}"''
          "${builtins.readFile ./zshrc}"
        ] ++ (
          ifElsePkg pkgs.eza [
            # substitute eza if installed
            "alias ls='eza'"
            "alias la='eza -a'"
            "alias ll='eza -al'"
            "alias lt='eza -T'"
            "alias lT='eza -lT'"
          ] [
            "export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx"
            "alias ls='ls -Fh'"
            "alias la='ls -Fha'"
            "alias ll='ls -Fhal'"
            "alias lt='tree'"
            "alias lT=\"tree -CpDh | sed -e 's/\(.*\)\[\([^]]*\)\]/\2 \1/'\""
          ]
        ) ++ (
          ifOpt config.apps.nvim.enable [
            "alias vi='nvim'"
          ]
        ) ++ (
          ifPkg pkgs.bat [
            "alias cat='bat'"
          ]
        ) ++ (
          ifPkg pkgs.git [
            "alias cdr='cd $(git rev-parse --show-toplevel)'"
          ]
        ) ++ (
          ifPkg pkgs.nh [
            "alias nhs='nh home switch ${flakepath} --show-trace'"
            "alias nf='nh search'"
          ]
        ) ++ (
          ifOpt config.opts.index.enable [
            "alias nl='nix-locate'"
            "alias ,,=', -as'"
          ]
        )
      );
    };
    programs.fzf.enableZshIntegration = true;
  };
}

