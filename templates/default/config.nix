{ karabinix }:

with karabinix.lib;

mkConfiguration {
  profiles = [
    (mkProfile {
      name = "Default";
      selected = true;

      # Simple key remappings
      simple_modifications = [
        # Map Caps Lock to Left Control
        (mapKey keyCodes.caps_lock keyCodes.left_control)
      ];

      # Complex modifications
      complex_modifications = mkComplexModification {
        rules = [
          # Add your custom rules here
          # Example: Vim navigation layer
          # (vimNavigation { layer_key = keyCodes.caps_lock; })
        ];
      };
    })
  ];
}
