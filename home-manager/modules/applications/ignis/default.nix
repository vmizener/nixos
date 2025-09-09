{ config, inputs, lib, pkgs, ... }:
let
  app = "ignis";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  # See: https://ignis-sh.github.io/ignis/latest/user/nix.html
  imports = [ inputs.ignis.homeManagerModules.default ];
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable (
    let
      pkg = (inputs.ignis.packages.${pkgs.system}.default.override {
        enableBluetoothService = true;
        enableRecorderService = true;
        enableAudioService = true;
        enableNetworkService = true;
        useDartSass = true;
        extraPackages = with pkgs.python313Packages; [
          jinja2
          materialyoucolor
          pillow
        ];
      });
    in {
      home.packages = [
        inputs.ignisctl-rs.packages.${pkgs.system}.ignisctl-rs
        pkg
        # (pkgs.python3.withPackages (_: [pkg]))
      ] ++ (with pkgs; [
        dart-sass
      ]);
      xdg.configFile = {
        "ignis".source = config.lib.file.mkOutOfStoreSymlink "${flakepath}/home-manager/modules/applications/${app}/config";
      };
    }
  );
}
    # programs.ignis = {
    #   enable = true;
    #
    #   # Add Ignis to the Python environment (useful for LSP support)
    #   addToPythonEnv = true;
    #
    #   # Put a config directory from your flake into ~/.config/ignis
    #   # NOTE: Home Manager will copy this directory to /nix/store
    #   # and create a symbolic link to the copy.
    #   configDir = ./config;
    #
    #   # Enable dependencies required by certain services.
    #   # NOTE: This won't affect your NixOS system configuration.
    #   # For example, to use NetworkService, you must also enable
    #   # NetworkManager in your NixOS configuration:
    #   #   networking.networkmanager.enable = true;
    #   services = {
    #     bluetooth.enable = true;
    #     recorder.enable = true;
    #     audio.enable = true;
    #     network.enable = true;
    #   };
    #
    #   # Enable Sass support
    #   sass = {
    #     enable = true;
    #     useDartSass = true;
    #   };
    #
    #   # Extra packages available at runtime
    #   # These can be regular packages or Python packages
    #   extraPackages = with pkgs.python313Packages; [
    #     jinja2
    #     materialyoucolor
    #     pillow
    #   ];
    # };
