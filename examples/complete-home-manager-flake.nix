# Complete Home Manager Flake Example
# This shows the complete setup for using karabinix with home-manager

{
  description = "Home Manager configuration with Karabinix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    karabinix.url = "github:pepegar/karabinix";
  };

  outputs = { nixpkgs, home-manager, karabinix, ... }:
    let
      system = "x86_64-darwin"; # or "aarch64-darwin" for Apple Silicon
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        modules = [
          # Import the karabinix home-manager module
          karabinix.homeManagerModules.karabinix
          
          # Your home configuration
          {
            # Basic home-manager settings
            home.username = "your-username";
            home.homeDirectory = "/Users/your-username";
            home.stateVersion = "23.11";

            # Enable and configure karabinix
            services.karabinix = {
              enable = true;
              
              configuration = with karabinix.lib; {
                profiles = [
                  (mkProfile {
                    name = "Default Profile";
                    selected = true;

                    simple_modifications = [
                      # Map Caps Lock to Control
                      (mapKey keyCodes.caps_lock keyCodes.left_control)
                    ];

                    complex_modifications = mkComplexModification {
                      rules = [
                        # Vim navigation layer
                        (vimNavigation {
                          layer_key = keyCodes.caps_lock;
                        })

                        # Hyper key for window management
                        (hyperKey {
                          key = keyCodes.spacebar;
                          alone_key = keyCodes.spacebar;
                          mappings = {
                            # Application shortcuts
                            t = mkToEvent { shell_command = "open -a 'Terminal'"; };
                            c = mkToEvent { shell_command = "open -a 'Visual Studio Code'"; };
                            f = mkToEvent { shell_command = "open -a 'Finder'"; };
                            s = mkToEvent { shell_command = "open -a 'Safari'"; };
                            
                            # Window management (requires yabai)
                            h = mkToEvent { shell_command = "yabai -m window --focus west"; };
                            j = mkToEvent { shell_command = "yabai -m window --focus south"; };
                            k = mkToEvent { shell_command = "yabai -m window --focus north"; };
                            l = mkToEvent { shell_command = "yabai -m window --focus east"; };
                          };
                        })
                      ];
                    };
                  })
                ];
              };
            };

            # Let Home Manager install and manage itself
            programs.home-manager.enable = true;
          }
        ];
      };
    };
}
