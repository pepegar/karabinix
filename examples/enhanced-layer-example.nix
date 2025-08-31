# Example demonstrating the enhanced layerKey function with modifier support
{ lib, ... }:

let
  karabinix = import ../lib { inherit lib; };
  inherit (karabinix) layerKey mkToEvent keyCodes;
in

{
  # Enhanced IntelliJ layer with support for Shift+M
  intellijLayer = layerKey {
    key = keyCodes.i;
    variable_name = "intellij_layer";
    alone_key = keyCodes.i;
    mappings = {
      # Regular lowercase m - next method
      m = mkToEvent {
        key_code = keyCodes.down_arrow;
        modifiers = ["left_control" "left_shift"];
      };

      # Capital M (Shift+M) - previous method
      "shift+m" = mkToEvent {
        key_code = keyCodes.up_arrow;
        modifiers = ["left_control" "left_shift"];
      };

      # Rename (F2)
      n = mkToEvent {
        key_code = keyCodes.f2;
      };

      # Toggle Breakpoint
      b = mkToEvent {
        key_code = keyCodes.f8;
        modifiers = ["fn" "left_command"];
      };

      # File structure
      e = mkToEvent {
        key_code = keyCodes.f12;
        modifiers = ["fn" "left_command"];
      };

      # More examples with different modifier combinations
      "ctrl+d" = mkToEvent {
        key_code = keyCodes.d;
        modifiers = ["left_command"];
      };

      "shift+ctrl+f" = mkToEvent {
        key_code = keyCodes.f;
        modifiers = ["left_command" "left_shift"];
      };
    };
  };
}
