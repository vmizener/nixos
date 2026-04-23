{ config, ... }: {
  imports = [
    ./common.nix
    ../modules/applications
    ../modules/dev
    ../modules/options
    ../modules/shell
  ];
  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;
  home = {
    username = "rvonmizener";
    homeDirectory = "/home/rvonmizener";
    sessionVariables = {
      NH_FLAKE = "${config.home.homeDirectory}/.config/home-manager";
    };
  };

  apps.foot.enable = true;
  apps.fusuma.enable = true;
  apps.git = {
    enable = true;
    useremail = "rvonmizener@google.com";
  };
  apps.kanshi.enable = true;
  apps.niri = {
    enable = true;
    useFlake = true;
    localConfig = ''
      # Restart ssh-agent on startup
      spawn-at-startup "systemctl" "--user" "restart" "ssh-agent.socket"
    '';
  };
  apps.nvim.enable = true;
  apps.ranger.enable = true;
  apps.awww.enable = true;

  opts.fonts.enable = true;
  opts.i18n.enable = true;
  opts.index.enable = true;

  shell.dms.enable = true;
  shell.zsh.enable = true;
}

