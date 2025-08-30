{
  description = "My Karabiner Elements configuration using Karabinix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    karabinix.url = "github:pepegar/karabinix";
  };

  outputs = { self, nixpkgs, karabinix }:
    let
      system = "x86_64-darwin"; # Change to your system
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Generate karabiner.json
      packages.${system}.default = pkgs.writeText "karabiner.json" 
        (import ./config.nix { inherit karabinix; });

      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          karabiner-elements
        ];
        
        shellHook = ''
          echo "Karabinix development environment"
          echo "Run 'nix build' to generate karabiner.json"
          echo "Copy result to ~/.config/karabiner/karabiner.json"
        '';
      };
    };
}
