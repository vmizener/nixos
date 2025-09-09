# See: https://nixos.wiki/wiki/Flakes#Flake_schema
{
  # ====
  # `description` is a string describing the flake.
  description = "A very basic flake";

  # ====
  # `inputs` is an attribute set of all the dependencies of the flake.
  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flakes
    ignis = {
      url = "github:ignis-sh/ignis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ignisctl-rs = {
      url = "github:linkfrg/ignisctl-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    swww.url = "github:LGFae/swww";
    zen-browser = {
      url = "github:pfaj/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ====
  # `outputs` is a function of one argument that takes an attribute set of all the realized inputs, and outputs another attribute set.
  # All inputs resolved above are passed in as arguments to the outputs function, along with `self`, which is the directory of this flake in the store.
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
    unstable-pkgs = import nixpkgs-unstable {
      inherit system;
      config = { allowUnfree = true; };
    };
    extraSpecialArgs = { inherit self inputs unstable-pkgs; };
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      baohaus = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system unstable-pkgs; };
        modules = [
          ./nixos/hosts/baohaus/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              inherit extraSpecialArgs;
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              users.bao = import ./home-manager/profiles/bao.nix;
            };
          }
        ];
      };
    };
    # Home-Manager configuration entrypoint
    # Available through 'home-manager switch --flake .#your-hostname'
    homeConfigurations = {
      "rvonmizener@rvonmizener-glaptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [ ./home-manager/profiles/rvonmizener.nix ];
      };
    };
  };
}
