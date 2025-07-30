{ config, lib, pkgs, ... }: {
  options = {
    shell.xonsh.enable = lib.mkEnableOption "xonsh shell";
  };
  config = lib.mkIf config.shell.xonsh.enable {
    environment.systemPackages = [ pkgs.starship ];
    programs.xonsh = {
      enable = true;
      config = (builtins.readFile ./xonshrc);
      extraPackages = ps: with ps; [
        # standard library packages
        numpy
        requests

        # nix packaged xontribs
        xonsh.xontribs.xontrib-abbrevs
        xonsh.xontribs.xontrib-jedi
        xonsh.xontribs.xontrib-vox

        # remote xontribs
        (buildPythonPackage {
          pname = "xontrib-prompt-vi-mode";
          version = "1.0";
          src = pkgs.fetchFromGitHub {
            owner = "t184256";
            repo = "xontrib-prompt-vi-mode";
            rev = "ed31f520fe4a62f6992e8d9181fc2ed018161015";
            hash = "sha256-9xCCfM1Rt0ESa8Bsq+CnImpGoS0zCFtVesJfB91+/7Q=";
          };
        })
        (buildPythonPackage rec {
          pname = "xontrib-fzf-widgets";
          version = "0.0.4";
          src = pkgs.fetchFromGitHub {
            owner = "laloch";
            repo = "xontrib-fzf-widgets";
            tag = "v"+version;
            hash = "sha256-lz0oiQSLCIQbnoQUi+NJwX82SbUvXJ+3dEsSbOb20q4=";
          };
        })
        (buildPythonPackage rec {
          pname = "xontrib-sh";
          version = "0.3.1";
          src = pkgs.fetchFromGitHub {
            owner = "anki-code";
            repo = "xontrib-sh";
            tag = version;
            hash = "sha256-KL/AxcsvjxqxvjDlf1axitgME3T+iyuW6OFb1foRzN8=";
          };
        })
      ];
    };
  };
}

