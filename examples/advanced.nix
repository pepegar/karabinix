# Advanced Karabinix Configuration Example
# This example shows complex modifications, hyper keys, simultaneous keys, and application-specific rules

{ karabinix }:

with karabinix.lib;

mkConfiguration {
  profiles = [
    (mkProfile {
      name = "Advanced";
      selected = true;

      # Simple modifications
      simple_modifications = [
        # Caps Lock to Hyper (will be overridden by complex modifications)
        (mapKey keyCodes.caps_lock keyCodes.left_control)
      ];

      complex_modifications = mkComplexModification {
        # Custom parameters for timing
        parameters = {
          "basic.simultaneous_threshold_milliseconds" = 30;
          "basic.to_if_alone_timeout_milliseconds" = 500;
          "basic.to_if_held_down_threshold_milliseconds" = 200;
        };

        rules = [
          # Hyper key on spacebar for window management and app launching
          (hyperKey {
            key = keyCodes.spacebar;
            modifiers = modifiers.hyper;
            alone_key = keyCodes.spacebar; # Still works as spacebar when pressed alone
            mappings = {
              # Window management (requires yabai or similar)
              h = mkToEvent { shell_command = "yabai -m window --focus west"; };
              j = mkToEvent { shell_command = "yabai -m window --focus south"; };
              k = mkToEvent { shell_command = "yabai -m window --focus north"; };
              l = mkToEvent { shell_command = "yabai -m window --focus east"; };
              
              # Application launching
              t = mkToEvent { shell_command = "open -a 'Terminal'"; };
              c = mkToEvent { shell_command = "open -a 'Visual Studio Code'"; };
              f = mkToEvent { shell_command = "open -a 'Finder'"; };
              s = mkToEvent { shell_command = "open -a 'Safari'"; };
              
              # System controls
              "1" = mkToEvent { shell_command = "yabai -m space --focus 1"; };
              "2" = mkToEvent { shell_command = "yabai -m space --focus 2"; };
              "3" = mkToEvent { shell_command = "yabai -m space --focus 3"; };
              "4" = mkToEvent { shell_command = "yabai -m space --focus 4"; };
            };
          })

          # Simultaneous key presses for special functions
          (mkRule "Simultaneous Keys" [
            # J + K together for Escape
            (simultaneousKeys [ keyCodes.j keyCodes.k ] keyCodes.escape {})
            
            # F + D together for Delete
            (simultaneousKeys [ keyCodes.f keyCodes.d ] keyCodes.delete_forward {})
            
            # S + D together for Save (Cmd+S)
            (simultaneousKeys [ keyCodes.s keyCodes.d ] (mkToEvent {
              key_code = keyCodes.s;
              modifiers = [ "left_command" ];
            }) {})
          ])

          # Layer key for symbols and numbers
          (layerKey {
            key = keyCodes.semicolon;
            variable_name = "symbol_layer";
            mappings = {
              # Number row
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
              
              # Symbols
              a = keyCodes.grave_accent_and_tilde;
              s = keyCodes.hyphen;
              d = keyCodes.equal_sign;
              f = keyCodes.open_bracket;
              g = keyCodes.close_bracket;
              h = keyCodes.backslash;
            };
          })

          # Application-specific rules
          (mkRule "Terminal Specific" [
            (mkManipulator {
              from = mkFromEvent {
                key_code = keyCodes.n;
                modifiers = mkModifiers {
                  mandatory = [ "left_command" ];
                };
              };
              to = [
                (mkToEvent {
                  key_code = keyCodes.t;
                  modifiers = [ "left_command" ];
                })
              ];
              conditions = [
                (appCondition [ "com.apple.Terminal" "com.googlecode.iterm2" ] "frontmost_application_if")
              ];
              description = "Cmd+N -> Cmd+T in Terminal apps";
            })
          ])

          # Text snippets and shortcuts
          (mkRule "Text Snippets" [
            # Email signature
            (mkManipulator {
              from = mkFromEvent {
                key_code = keyCodes.e;
                modifiers = mkModifiers {
                  mandatory = [ "left_command" "left_shift" ];
                };
              };
              to = [
                (mkToEvent { shell_command = "echo 'Best regards,\nYour Name' | pbcopy"; })
              ];
              description = "Cmd+Shift+E -> Email signature to clipboard";
            })
            
            # Current date
            (mkManipulator {
              from = mkFromEvent {
                key_code = keyCodes.d;
                modifiers = mkModifiers {
                  mandatory = [ "left_command" "left_shift" ];
                };
              };
              to = [
                (mkToEvent { shell_command = "date '+%Y-%m-%d' | pbcopy"; })
              ];
              description = "Cmd+Shift+D -> Current date to clipboard";
            })
          ])

          # Mouse key simulation
          (mkRule "Mouse Keys" [
            (mkManipulator {
              from = mkFromEvent {
                key_code = keyCodes.h;
                modifiers = mkModifiers {
                  mandatory = [ "left_control" "left_option" ];
                };
              };
              to = [
                (mkToEvent { pointing_button = "button1"; })
              ];
              description = "Ctrl+Opt+H -> Left Click";
            })
          ])
        ];
      };
    })
  ];
}
