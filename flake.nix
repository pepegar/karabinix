{
  description = "Karabinix - A Nix utility for generating Karabiner Elements configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Development shell for working on karabinix
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            nil
          ];
        };

        # Formatter for nix files
        formatter = pkgs.nixpkgs-fmt;
      }
    ) // {
      # Library functions available to all systems
      lib = import ./lib { inherit (nixpkgs) lib; };

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
