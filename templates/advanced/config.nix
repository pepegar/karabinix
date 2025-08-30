{ karabinix }:

with karabinix.lib;

mkConfiguration {
  profiles = [
    (mkProfile {
      name = "Advanced";
      selected = true;

      simple_modifications = [
        # Basic modifier remappings
        modifierRemaps.caps_to_ctrl
        modifierRemaps.right_opt_to_ctrl
      ];

      complex_modifications = mkComplexModification {
        parameters = {
          "basic.simultaneous_threshold_milliseconds" = 30;
          "basic.to_if_alone_timeout_milliseconds" = 500;
        };

        rules = [
          # Hyper key for window management and app launching
          (hyperKey {
            key = keyCodes.spacebar;
            alone_key = keyCodes.spacebar;
            mappings = {
              # Window focus (requires yabai)
              h = mkToEvent { shell_command = "yabai -m window --focus west"; };
              j = mkToEvent { shell_command = "yabai -m window --focus south"; };
              k = mkToEvent { shell_command = "yabai -m window --focus north"; };
              l = mkToEvent { shell_command = "yabai -m window --focus east"; };
              
              # Application launching
              t = mkToEvent { shell_command = "open -a 'Terminal'"; };
              c = mkToEvent { shell_command = "open -a 'Visual Studio Code'"; };
              f = mkToEvent { shell_command = "open -a 'Finder'"; };
              s = mkToEvent { shell_command = "open -a 'Safari'"; };
              
              # Workspace switching
              "1" = mkToEvent { shell_command = "yabai -m space --focus 1"; };
              "2" = mkToEvent { shell_command = "yabai -m space --focus 2"; };
              "3" = mkToEvent { shell_command = "yabai -m space --focus 3"; };
              "4" = mkToEvent { shell_command = "yabai -m space --focus 4"; };
            };
          })

          # Vim navigation layer
          (vimNavigation {
            layer_key = keyCodes.caps_lock;
          })

          # Simultaneous key combinations
          (mkRule "Simultaneous Keys" [
            (simultaneousKeys [ keyCodes.j keyCodes.k ] keyCodes.escape {})
            (simultaneousKeys [ keyCodes.f keyCodes.d ] keyCodes.delete_forward {})
          ])

          # Symbol layer
          (layerKey {
            key = keyCodes.semicolon;
            variable_name = "symbol_layer";
            mappings = {
              q = keyCodes."1";
              w = keyCodes."2";
              e = keyCodes."3";
              r = keyCodes."4";
              t = keyCodes."5";
              y = keyCodes."6";
              u = keyCodes."7";
              i = keyCodes."8";
              o = keyCodes."9";
              p = keyCodes."0";
            };
          })
        ];
      };
    })
  ];
}
