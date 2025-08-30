# Basic Karabinix Configuration Example
# This example shows simple key remappings and basic complex modifications

{ karabinix }:

with karabinix.lib;

mkConfiguration {
  # Global settings (optional)
  global = {
    show_in_menu_bar = true;
    show_profile_name_in_menu_bar = false;
  };

  profiles = [
    (mkProfile {
      name = "Default";
      selected = true;

      # Simple key remappings
      simple_modifications = [
        # Map Caps Lock to Left Control
        (mapKey keyCodes.caps_lock keyCodes.left_control)
        
        # Map Right Option to Right Control (useful for non-US keyboards)
        (mapKey keyCodes.right_option keyCodes.right_control)
      ];

      # Complex modifications
      complex_modifications = mkComplexModification {
        rules = [
          # Vim-style navigation when holding Caps Lock
          (vimNavigation {
            layer_key = keyCodes.caps_lock;
          })

          # Media keys on function keys
          (mkRule "Media Keys" [
            (mkManipulator {
              from = mkFromEvent { key_code = keyCodes.f7; };
              to = [ (mkToEvent { consumer_key_code = keyCodes.rewind; }) ];
              description = "F7 -> Previous Track";
            })
            (mkManipulator {
              from = mkFromEvent { key_code = keyCodes.f8; };
              to = [ (mkToEvent { consumer_key_code = keyCodes.play_or_pause; }) ];
              description = "F8 -> Play/Pause";
            })
            (mkManipulator {
              from = mkFromEvent { key_code = keyCodes.f9; };
              to = [ (mkToEvent { consumer_key_code = keyCodes.fastforward; }) ];
              description = "F9 -> Next Track";
            })
          ])
        ];
      };
    })
  ];
}
