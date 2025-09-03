# Home Row Mods Examples
# This file demonstrates various ways to use the home row mod utilities in Karabinix
{lib, ...}: let
  karabinix = import ../lib {inherit lib;};
  inherit (karabinix) keyCodes homeRowMod homeRowMods homeRowModsWithCombinations standardHomeRowMods altHomeRowMods;
in {
  # Example 1: Using the predefined standard home row mods
  # This matches the common QWERTY home row mod layout:
  # A=Shift, S=Option, D=Control, F=Command | J=Command, K=Control, L=Option, ;=Shift
  example1 = standardHomeRowMods;

  # Example 2: Using the alternative home row mods
  # A=Control, S=Option, D=Command, F=Shift | J=Shift, K=Command, L=Option, ;=Control
  example2 = altHomeRowMods;

  # Example 3: Custom home row mods using homeRowMods function
  # Your exact configuration from the original request
  example3 = homeRowMods {
    s = keyCodes.left_option; # S = Option when held, S when tapped
    d = keyCodes.left_control; # D = Control when held, D when tapped
    f = keyCodes.left_command; # F = Command when held, F when tapped
    j = keyCodes.right_command; # J = Command when held, J when tapped
    k = keyCodes.right_control; # K = Control when held, K when tapped
    l = keyCodes.right_option; # L = Option when held, L when tapped
  };

  # Example 4: Individual home row mod with custom description
  example4_individual = homeRowMod {
    key = keyCodes.spacebar;
    modifier = keyCodes.left_shift;
    description = "Space: Shift when held, Space when tapped";
  };

  # Example 5: Minimal home row mods (just the core modifiers)
  example5_minimal = homeRowMods {
    d = keyCodes.left_control;
    f = keyCodes.left_command;
    j = keyCodes.right_command;
    k = keyCodes.right_control;
  };

  # Example 6: Extended home row mods (including number row)
  example6_extended = homeRowMods {
    # Home row
    a = keyCodes.left_shift;
    s = keyCodes.left_option;
    d = keyCodes.left_control;
    f = keyCodes.left_command;
    j = keyCodes.right_command;
    k = keyCodes.right_control;
    l = keyCodes.right_option;
    semicolon = keyCodes.right_shift;

    # Number row mods (less common but some users like them)
    "1" = keyCodes.left_shift;
    "2" = keyCodes.left_option;
    "3" = keyCodes.left_control;
    "4" = keyCodes.left_command;
    "7" = keyCodes.right_command;
    "8" = keyCodes.right_control;
    "9" = keyCodes.right_option;
    "0" = keyCodes.right_shift;
  };

  # Example 7: Colemak home row mods
  example7_colemak = homeRowMods {
    a = keyCodes.left_shift;
    r = keyCodes.left_option;
    s = keyCodes.left_control;
    t = keyCodes.left_command;
    n = keyCodes.right_command;
    e = keyCodes.right_control;
    i = keyCodes.right_option;
    o = keyCodes.right_shift;
  };

  # Example 8: Home row mods with combinations enabled
  # This creates individual key mods PLUS combination mods
  # For example: holding A+S gives Shift+Control, holding S+D gives Control+Option, etc.
  example8_with_combinations = homeRowModsWithCombinations {
    a = keyCodes.left_shift;
    s = keyCodes.left_control;
    d = keyCodes.left_option;
    f = keyCodes.left_command;
    j = keyCodes.right_command;
    k = keyCodes.right_option;
    l = keyCodes.right_control;
    semicolon = keyCodes.right_shift;
  };

  # Example 9: Minimal combination setup (just the core 4 keys)
  # This creates combinations like:
  # - S+D = Control+Option
  # - D+F = Option+Command
  # - J+K = Command+Option
  # - K+L = Option+Control
  # - S+D+F = Control+Option+Command (3-key combo)
  # - J+K+L = Command+Option+Control (3-key combo)
  # - S+D+F+J = all modifiers (4-key combo)
  example9_minimal_combinations = homeRowModsWithCombinations {
    s = keyCodes.left_control;
    d = keyCodes.left_option;
    f = keyCodes.left_command;
    j = keyCodes.right_command;
    k = keyCodes.right_option;
    l = keyCodes.right_control;
  };
}
