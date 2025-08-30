# Home Manager Integration Example
# This shows how to use karabinix with home-manager
# 
# This file should be used as part of a flake that includes karabinix as an input.
# See the flake.nix example below for the complete setup.

{ config, pkgs, karabinix, ... }:

{
  # Import the karabinix home-manager module
  imports = [
    karabinix.homeManagerModules.karabinix
  ];

  # Enable and configure karabinix
  services.karabinix = {
    enable = true;
    
    # Optional: Install Karabiner Elements via Nix (default: false)
    # installPackage = true;
    # package = pkgs.karabiner-elements;
    
    configuration = with karabinix.lib; {
      profiles = [
        (mkProfile {
          name = "Home Manager Profile";
          selected = true;

          simple_modifications = [
            # Basic remappings
            modifierRemaps.caps_to_ctrl
            modifierRemaps.right_opt_to_ctrl
          ];

          complex_modifications = mkComplexModification {
            rules = [
              # Vim navigation layer
              (vimNavigation {
                layer_key = keyCodes.caps_lock;
              })

              # Window management with hyper key
              (windowManagement {
                hyper_key = keyCodes.spacebar;
              })

              # Application launcher
              (appLauncher {
                hyper_key = keyCodes.spacebar;
                apps = {
                  t = "Terminal";
                  c = "Visual Studio Code";
                  f = "Finder";
                  s = "Safari";
                  m = "Mail";
                  n = "Notes";
                };
              })
            ];
          };
        })
      ];
    };
  };

  # Note: Karabiner Elements package installation is now controlled by the
  # services.karabinix.installPackage option above. You can also install it
  # separately via Homebrew: `brew install --cask karabiner-elements`
}
