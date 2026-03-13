{ config, lib, pkgs, ... }:
let
  cfg = config.apps.foot;
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
in {
  options = {
    apps.foot.enable = lib.mkEnableOption "foot";
    apps.foot.font = lib.mkOption {
      type = lib.types.str;
      default = "monospace";
      description = "Font to use";
    };
    apps.foot.fontsize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 12;
      description = "Font size to use";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.foot.enable = true;
    programs.foot.settings = {
      main = {
        font = "${cfg.font}:size=${builtins.toString cfg.fontsize}";
      };
      colors = {
        alpha = "0.7";
      };
      key-bindings = {
        font-increase = "Control+Shift+plus Control+Shift+equal Control+KP_Add";
        font-decrease = "Control+Shift+minus Control+KP_Subtract";
        pipe-scrollback = [
          "[sh -c \"f=$(mktemp) && cat - > $f; foot nvim $f -u NONE -c 'set nonumber nolist showtabline=0 foldcolumn=0 virtualedit=block' -c 'autocmd VimEnter * normal G' -c 'map q :qa!<CR>' -c 'map i <NOP>' -c 'map I <NOP>' -c 'map a <NOP>' -c 'map A <NOP>' -c 'set clipboard+=unnamedplus'; rm $f\"] Control+Shift+f"
          "[sh -c \"cat - | foot fzf --no-sort --no-mouse -i --tac\"] Control+Shift+slash"
        ];
        show-urls-launch = "Control+Shift+o";
        show-urls-copy = "Control+Shift+y";
      };
    };
  };
}
