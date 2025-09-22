{lib}: let
  types = import ./types.nix {inherit lib;};
  rules = import ./rules.nix {inherit lib;};
  utils = import ./utils.nix {inherit lib;};
in {
  inherit types;

  # Core configuration generation
  mkConfiguration = import ./config.nix {inherit lib;};

  # Rule creation functions
  inherit
    (rules)
    mkComplexModification
    mkProfile
    mkToEvent
    ;

  # Utility functions
  inherit
    (utils)
    # High-level functions
    layerKey
    appLayerKey
    vimNavigation
    raycastWindow
    homeRowModsWithCombinations
    # Shared helper functions
    mapModifier
    parseTrigger
    mkLayerManipulators
    mkLayerToggleEvents
    ;

  # Key code constants
  keyCodes = import ./keycodes.nix;

  # Common modifier combinations
  modifiers = {
    cmd = ["left_command"];
    shift = ["left_shift"];
    alt = ["left_option"];
    ctrl = ["left_control"];
    hyper = ["left_command" "left_control" "left_option" "left_shift"];
    meh = ["left_control" "left_option" "left_shift"];
  };
}
