{ config, inputs, lib, pkgs, ... }:
let
  app = "torrra";
  version = "1.2.8";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable (
    let
      src = pkgs.fetchFromGitHub {
        owner = "stabldev";
        repo = "torrra";
        tag = "v"+version;
        hash = "sha256-Fs1G5pznLbonu/kripXfsgQf5ezP9RhtIiM3V3LxM8o=";
      };
      project = inputs.pyproject-nix.lib.project.loadPyproject {
        # pyproject = lib.importTOML builtins.toPath "${src}/pyproject.toml";
        projectRoot = "${src}";
      };
      python = pkgs.python313;
      # python =  pkgs.python313.withPackages (pp: [ pp.libtorrent ]);
      attrs = project.renderers.buildPythonPackage { inherit python; };
    in {
      home.packages = [
        pkgs.libtorrent
        (python.pkgs.buildPythonPackage (attrs))
      ];
    }
  );
}
