{ config, lib, pkgs, ... }:
let
  cfg = config.apps.git;
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.git.enable = lib.mkEnableOption "git";
    apps.git.username = lib.mkOption {
      type = lib.types.str;
      default = config.home.username;
      description = "Username to set default config to";
    };
    apps.git.useremail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Email to set default config to";
    };
    apps.git.enableGh = lib.mkOption {
      type = lib.types.bool;
      default = true; 
      description = "Enable GH CLI tool";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = cfg.username;
          email = cfg.useremail;
        };
        alias = {
          # `git changes FILE`
          # Show the change history for FILE
          changes = "log -p -M --follow --stat --";

          # `git squash N`
          # Squash the last N commits together into one commit
          squash = "!f(){ git reset --soft HEAD~\${1} && git commit --edit -m\"\$(git log --format=%B --reverse HEAD.HEAD@{1})\"; };f";

          # `git tree`
          # Show the commit tree for the current branch
          tree = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";

          # `git tree-detail`
          # Show the detailed commit tree for the current branch
          tree-detail = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
        };
        branch = {
          autosetupmerge = "always";
        };
        credential = {
          helper = "store";
        };
        color = {
          ui = "always";
        };
        core = {
          excludesfile = "${config.home.homeDirectory}/.gitignore";
          pager = "${pkgs.delta}/bin/delta -sn";
        };
        merge = {
          tool = "vimdiff";
          conflictstyle = "diff3";
        };
        mergetool = {
          prompt = false;
        };
        pull = {
          rebase = false;
        };
        push = {
          default = "current";
        };
        stash = {
          showPatch = true;
        };
      };
    };
    programs.gh = {
      enable = cfg.enableGh;
      gitCredentialHelper = {
        enable = cfg.enableGh;
      };
    };
  };
}
