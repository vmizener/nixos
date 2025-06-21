{ lib, config, inputs, system, ... }: {
  options = {
    shell.ui.astal.enable = lib.mkEnableOption "astal gtk shell";
  };
  config = lib.mkIf config.shell.ui.astal.enable {
    environment.systemPackages = [
      inputs.astal.packages.${system}.default  # CLI util
    ];
  };
}
