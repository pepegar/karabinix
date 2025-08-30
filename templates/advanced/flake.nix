{
  description = "Advanced Karabiner Elements configuration using Karabinix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    karabinix.url = "github:pepegar/karabinix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, karabinix, home-manager }:
    let
      system = "x86_64-darwin"; # Change to your system
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Standalone configuration
      packages.${system}.default = pkgs.writeText "karabiner.json" 
        (import ./config.nix { inherit karabinix; });

      # Home Manager configuration
      homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          karabinix.homeManagerModules.karabinix
          ./home.nix
        ];
      };

      # Development shell with utilities
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          karabiner-elements
          yabai # For window management
          skhd  # Alternative hotkey daemon
        ];
        
        shellHook = ''
          echo "Advanced Karabinix development environment"
          echo ""
          echo "Available commands:"
          echo "  nix build                    - Generate standalone karabiner.json"
          echo "  home-manager switch --flake . - Apply home-manager configuration"
          echo ""
          echo "The configuration includes:"
          echo "  - Hyper key mappings"
          echo "  - Window management (requires yabai)"
          echo "  - Application launchers"
          echo "  - Vim-style navigation"
          echo "  - Custom text snippets"
        '';
      };
    };
}
