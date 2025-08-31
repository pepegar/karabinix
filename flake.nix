{
  description = "Karabinix - A Nix utility for generating Karabiner Elements configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        # Development shell for working on karabinix
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            alejandra
            nil
          ];
        };

        # Formatter for nix files
        formatter = pkgs.alejandra;

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
              deadnix.enable = true;
              stylua.enable = true;
            };
          };
        };
      }
    )
    // {
      # Library functions available to all systems
      lib = import ./lib {inherit (nixpkgs) lib;};

      # Home Manager modules
      homeManagerModules = {
        karabinix = import ./modules/home-manager.nix;
        default = import ./modules/home-manager.nix;
      };

      # Templates for getting started
      templates = {
        default = {
          path = ./templates/default;
          description = "Basic karabinix configuration template";
        };
        advanced = {
          path = ./templates/advanced;
          description = "Advanced karabinix configuration with complex modifications";
        };
      };
    };
}
