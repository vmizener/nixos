{ inputs, pkgs, lib, config, ... }: {
  options = {
    browsers.firefox.enable = lib.mkEnableOption "firefox browser";
  };
  config = lib.mkIf config.browsers.firefox.enable {
    environment.systemPackages = [pkgs.firefox];
    programs.firefox.enable = true;
  };
}

