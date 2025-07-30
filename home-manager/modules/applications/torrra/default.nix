{ config, flakePath, lib, pkgs, unstable-pkgs, ... }: {
  options = {
    apps.torrra.enable = lib.mkEnableOption "torrra";
  };
  config = lib.mkIf config.apps.torrra.enable {
    home.packages = with pkgs; [
      # python3Packages.torrra
      # (python3Packages.buildPythonApplication rec {
      #   pname = "torrra";
      #   version = "1.2.0";
      #   pyproject = true;
      #   src = fetchFromGitHub {
      #     owner = "stabldev";
      #     repo = "torrra";
      #     tag = "v"+version;
      #     hash = "sha256-jJApmYHdo/uolTzgp8wHOsjq8TzhnxA6jtzJ/oHA6RA=";
      #   };
      #   build-system = with python3Packages; [
      #     hatchling
      #   ];
      #   dependencies = with python3Packages; [
      #     click
      #     diskcache
      #     httpx
      #     libtorrent
      #     platformdirs
      #     textual
      #     tomli-w
      #   ];
      # })
    ];
  };
}
