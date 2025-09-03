# Example configuration using Raycast window management
# This demonstrates how to use the raycastWindow and raycastWindowManagement functions
{lib, ...}: let
  karabinix = import ../lib {inherit lib;};
  inherit (karabinix) mkConfiguration mkProfile mkComplexModification raycastWindow raycastWindowManagement keyCodes;
in
  mkConfiguration {
    profiles = [
      (mkProfile {
        name = "Raycast Window Management";
        selected = true;

        complex_modifications = mkComplexModification {
          rules = [
            # Use the pre-built raycastWindowManagement with default spacebar hyper key
            raycastWindowManagement
            {}

            # Or create custom window management shortcuts using individual raycastWindow calls
            # This example uses 'w' as a layer key for window management
            (karabinix.layerKey {
              key = keyCodes.w;
              alone_key = keyCodes.w;
              variable_name = "window_layer";
              mappings = {
                # Basic halves
                h = raycastWindow "left-half";
                l = raycastWindow "right-half";
                k = raycastWindow "top-half";
                j = raycastWindow "bottom-half";

                # Maximize and center
                f = raycastWindow "maximize";
                c = raycastWindow "center";

                # Quarters
                "1" = raycastWindow "top-left-quarter";
                "2" = raycastWindow "top-right-quarter";
                "3" = raycastWindow "bottom-left-quarter";
                "4" = raycastWindow "bottom-right-quarter";

                # Move between displays
                n = raycastWindow "next-display";
                p = raycastWindow "previous-display";

                # Custom window actions
                r = raycastWindow "restore";
                m = raycastWindow "minimize";

                # Thirds for ultrawide monitors
                t = raycastWindow "first-third";
                y = raycastWindow "center-third";
                u = raycastWindow "last-third";
              };
            })
          ];
        };
      })
    ];
  }
