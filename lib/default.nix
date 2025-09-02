{lib}: let
  types = import ./types.nix {inherit lib;};
  rules = import ./rules.nix {inherit lib types;};
  utils = import ./utils.nix {inherit lib types;};
in {
  inherit types;

  # Core configuration generation
  mkConfiguration = import ./config.nix {inherit lib types rules utils;};

  # Rule creation functions
  inherit
    (rules)
    mkSimpleModification
    mkComplexModification
    mkRule
    mkManipulator
    mkProfile
    mkFromEvent
    mkToEvent
    mkModifiers
    mkCondition
    ;

  # Utility functions
  inherit
    (utils)
    mapKey
    hyperKey
    simultaneousKeys
    layerKey
    appLayerKey
    sublayerKey
    appCondition
    deviceCondition
    keyboardTypeCondition
    variableCondition
    vimNavigation
    raycastWindow
    mediaKeys
    modifierRemaps
    appLauncher
    textSnippets
    homeRowMod
    homeRowMods
    homeRowModsWithCombinations
    standardHomeRowMods
    altHomeRowMods
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
