{ config, lib, pkgs, inputs, ... }:
let
  app = "nvim";
  cfg = config.apps.${app};
  flakepath = "${config.home.sessionVariables.NH_FLAKE}";
  nvimcfg = "${flakepath}/home-manager/modules/applications/nvim/config";
  treesitterWithGrammars = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  # treesitterParsers = pkgs.symlinkJoin {
  #   name = "treesitter-parsers";
  #   paths = treesitterWithGrammars.dependencies;
  # };
in {
  options = {
    apps.${app}.enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # home.packages = with pkgs; [
    #   nixd
    #   nixfmt
    # ];
    programs.neovim = {
      enable = true;
      # package = pkgs.neovim;
      plugins = [treesitterWithGrammars];
      extraPackages = with pkgs; [
        # Tree-sitter CLI (grammars provided by withAllGrammars plugin)
        tree-sitter

        fd
        ripgrep

        black
        pyright

        lua-language-server

        # nil
        nixd
        nixfmt
      ];

      withNodeJs = true;
      withPython3 = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    xdg.configFile = {
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${nvimcfg}";
    };
    xdg.dataFile."nvim/nix/nvim-treesitter" = {
      source = treesitterWithGrammars;
    };
  };
}
