{ config, lib, pkgs, ... }:
let
  cfg = config.opts.i18n;
in {
  options = {
    opts.i18n.enable = lib.mkEnableOption "i18n";
  };
  config = lib.mkIf cfg.enable {
    i18n.inputMethod.enable = true;
    i18n.inputMethod.type = "fcitx5";
    i18n.inputMethod.fcitx5.waylandFrontend = true;
    i18n.inputMethod.fcitx5.addons = with pkgs; [
      # UI Toolkit
      fcitx5-gtk
      # Japanese
      fcitx5-mozc
      # Traditional Chinese
      fcitx5-rime
      # Simplified Chinese
      qt6Packages.fcitx5-chinese-addons
      fcitx5-pinyin-zhwiki
    ];

    home.sessionVariables = {
      # GTK_IM_MDOULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      GLFW_IM_MODULE = "ibus"; # IME support in kitty
    };
  };
}
