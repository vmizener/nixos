{ config, lib, pkgs, ... }:
let
  app = "kanshi";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
  execThemeReset = (builtins.toString (pkgs.writeShellScript "kanshi-theme-reset" ''
    ${flakepath}/scripts/run theme::reset
  ''));
in {
  options = {
    apps.kanshi.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kanshi ];
    services.kanshi = {
      enable = true;
      settings = [
        # Outputs
        {
          output = {
            alias = "laptop";
            criteria = "eDP-1";
            scale = 1.7;
            position = "0,0";
          };
        }
        # Profiles
        {
          profile.name = "nomad";
          profile.outputs = [
            { criteria = "$laptop"; status = "enable"; }
          ];
          profile.exec = execThemeReset;
        }
        {
          profile.name = "baohaus";
          profile.outputs = [
            { criteria = "Dell Inc. DELL U2415 CFV9N7CN28NL"; status = "enable"; position = "0,0"; }
            { criteria = "Dell Inc. DELL U2415 CFV9N7CN202L"; status = "enable"; position = "1920,0"; }
          ];
          profile.exec = execThemeReset;
        }
        {
          profile.name = "tony";
          profile.outputs = [
            { criteria = "Dell Inc. DELL P3223QE GC68F34"; status = "enable"; position = "0,0"; }
            { criteria = "$laptop"; status = "enable"; position = "740,2160"; }
          ];
          profile.exec = execThemeReset;
        }
      ];
    };
  };
}
