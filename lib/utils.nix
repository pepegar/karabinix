{ lib, types }:

with lib;

let
  rules = import ./rules.nix { inherit lib types; };
  keyCodes = import ./keycodes.nix;
in

rec {
  # Simple key mapping utility
  mapKey = from: to:
    rules.mkSimpleModification from to;

  # Create a hyper key configuration
  # Maps a key + modifiers to act as a "hyper" key that can trigger other mappings
  hyperKey = {
    key,
    mappings,
    modifiers ? [ "left_command" "left_control" "left_option" "left_shift" ],
    alone_key ? null,
    held_key ? null
  }:
    let
      # Create manipulators for each mapping
      hyperManipulators = mapAttrsToList (trigger: target: 
        rules.mkManipulator {
          from = rules.mkFromEvent {
            key_code = trigger;
            modifiers = rules.mkModifiers {
              mandatory = modifiers;
            };
          };
          to = if isString target then [
            (rules.mkToEvent { key_code = target; })
          ] else if isList target then
            map (t: rules.mkToEvent { key_code = t; }) target
          else [
            target
          ];
          description = "Hyper + ${trigger} -> ${if isString target then target else toString target}";
        }
      ) mappings;

      # Main hyper key manipulator
      hyperKeyManipulator = rules.mkManipulator {
        from = rules.mkFromEvent { key_code = key; };
        to = [
          (rules.mkToEvent {
            set_variable = {
              name = "hyper_mode";
              value = 1;
            };
          })
        ];
        to_if_alone = if alone_key != null then [
          (rules.mkToEvent { key_code = alone_key; })
        ] else [];
        to_if_held_down = if held_key != null then [
          (rules.mkToEvent { key_code = held_key; })
        ] else [];
        to_after_key_up = [
          (rules.mkToEvent {
            set_variable = {
              name = "hyper_mode";
              value = 0;
            };
          })
        ];
        description = "Hyper key (${key})";
      };

      # Add hyper_mode condition to all mappings
      hyperManipulatorsWithCondition = map (manipulator:
        manipulator // {
          conditions = (manipulator.conditions or []) ++ [
            (rules.mkCondition {
              type = "variable_if";
              name = "hyper_mode";
              value = 1;
            })
          ];
        }
      ) hyperManipulators;

    in
    rules.mkRule "Hyper Key (${key})" ([ hyperKeyManipulator ] ++ hyperManipulatorsWithCondition);

  # Create simultaneous key press mappings
  simultaneousKeys = keys: to: options:
    let
      simultaneousFrom = rules.mkFromEvent {
        simultaneous = map (key: { key_code = key; }) keys;
        simultaneous_options = {
          detect_key_down_uninterruptedly = options.detect_key_down_uninterruptedly or false;
          key_down_order = options.key_down_order or null;
          key_up_order = options.key_up_order or null;
          key_up_when = options.key_up_when or null;
          to_after_key_up = options.to_after_key_up or [];
        };
      };
      
      toEvents = if isString to then [
        (rules.mkToEvent { key_code = to; })
      ] else if isList to then
        map (t: if isString t then rules.mkToEvent { key_code = t; } else t) to
      else [
        to
      ];
    in
    rules.mkManipulator {
      from = simultaneousFrom;
      to = toEvents;
      description = "Simultaneous: ${concatStringsSep " + " keys} -> ${toString to}";
    };

  # Create a layer key (key that activates a layer when held)
  layerKey = {
    key,
    mappings,
    alone_key ? null,
    variable_name ? "${key}_layer"
  }:
    let
      # Create manipulators for each mapping in the layer
      layerManipulators = mapAttrsToList (trigger: target:
        rules.mkManipulator {
          from = rules.mkFromEvent { key_code = trigger; };
          to = if isString target then [
            (rules.mkToEvent { key_code = target; })
          ] else if isList target then
            map (t: rules.mkToEvent { key_code = t; }) target
          else [
            target
          ];
          conditions = [
            (rules.mkCondition {
              type = "variable_if";
              name = variable_name;
              value = 1;
            })
          ];
          description = "Layer ${key}: ${trigger} -> ${toString target}";
        }
      ) mappings;

      # Layer activation key
      layerKeyManipulator = rules.mkManipulator {
        from = rules.mkFromEvent { key_code = key; };
        to = [
          (rules.mkToEvent {
            set_variable = {
              name = variable_name;
              value = 1;
            };
          })
        ];
        to_if_alone = if alone_key != null then [
          (rules.mkToEvent { key_code = alone_key; })
        ] else [];
        to_after_key_up = [
          (rules.mkToEvent {
            set_variable = {
              name = variable_name;
              value = 0;
            };
          })
        ];
        description = "Layer key (${key})";
      };

    in
    rules.mkRule "Layer: ${key}" ([ layerKeyManipulator ] ++ layerManipulators);

  # Application-specific condition
  appCondition = apps: type:
    rules.mkCondition {
      inherit type;
      bundle_identifiers = if isString apps then [ apps ] else apps;
    };

  # Device-specific condition  
  deviceCondition = {
    vendor_id ? null,
    product_id ? null,
    location_id ? null,
    is_keyboard ? null,
    is_pointing_device ? null,
    type ? "device_if"
  }:
    rules.mkCondition {
      inherit type;
      identifiers = [{
        vendor_id = vendor_id;
        product_id = product_id;
        location_id = location_id;
        is_keyboard = is_keyboard;
        is_pointing_device = is_pointing_device;
      }];
    };

  # Keyboard type condition
  keyboardTypeCondition = keyboard_types: type:
    rules.mkCondition {
      inherit type keyboard_types;
    };

  # Variable condition
  variableCondition = name: value: type:
    rules.mkCondition {
      inherit type name value;
    };

  # Vim-style navigation layer
  vimNavigation = { layer_key, variable_name ? "vim_mode" }:
    layerKey {
      key = layer_key;
      variable_name = variable_name;
      mappings = {
        h = keyCodes.left_arrow;
        j = keyCodes.down_arrow;
        k = keyCodes.up_arrow;
        l = keyCodes.right_arrow;
        w = [ keyCodes.right_arrow ]; # word forward (simplified)
        b = [ keyCodes.left_arrow ];  # word backward (simplified)
        "0" = keyCodes.home;
        "4" = keyCodes.end; # $ key
        u = keyCodes.page_up;
        d = keyCodes.page_down;
        g = keyCodes.home;
        G = keyCodes.end;
      };
    };

  # Window management utilities
  windowManagement = { hyper_key ? "spacebar", modifiers ? [ "left_command" "left_control" "left_option" "left_shift" ] }:
    hyperKey {
      key = hyper_key;
      modifiers = modifiers;
      mappings = {
        # Window positioning
        h = {
          shell_command = "yabai -m window --resize left:-50:0 || yabai -m window --resize right:-50:0";
        };
        l = {
          shell_command = "yabai -m window --resize right:50:0 || yabai -m window --resize left:50:0";
        };
        k = {
          shell_command = "yabai -m window --resize top:0:-50 || yabai -m window --resize bottom:0:-50";
        };
        j = {
          shell_command = "yabai -m window --resize bottom:0:50 || yabai -m window --resize top:0:50";
        };
        
        # Window focus
        "1" = {
          shell_command = "yabai -m space --focus 1";
        };
        "2" = {
          shell_command = "yabai -m space --focus 2";
        };
        "3" = {
          shell_command = "yabai -m space --focus 3";
        };
        "4" = {
          shell_command = "yabai -m space --focus 4";
        };
        
        # Fullscreen
        f = {
          shell_command = "yabai -m window --toggle zoom-fullscreen";
        };
        
        # Float/unfloat
        t = {
          shell_command = "yabai -m window --toggle float";
        };
      };
    };

  # Media key utilities
  mediaKeys = {
    # Map function keys to media controls
    f7 = rules.mkSimpleModification keyCodes.f7 keyCodes.rewind;
    f8 = rules.mkSimpleModification keyCodes.f8 keyCodes.play_or_pause;
    f9 = rules.mkSimpleModification keyCodes.f9 keyCodes.fastforward;
    f10 = rules.mkSimpleModification keyCodes.f10 keyCodes.mute;
    f11 = rules.mkSimpleModification keyCodes.f11 keyCodes.volume_down;
    f12 = rules.mkSimpleModification keyCodes.f12 keyCodes.volume_up;
  };

  # Common modifier key remappings
  modifierRemaps = {
    # Caps lock to control
    caps_to_ctrl = rules.mkSimpleModification keyCodes.caps_lock keyCodes.left_control;
    
    # Caps lock to escape
    caps_to_esc = rules.mkSimpleModification keyCodes.caps_lock keyCodes.escape;
    
    # Right option to right control (useful for non-US keyboards)
    right_opt_to_ctrl = rules.mkSimpleModification keyCodes.right_option keyCodes.right_control;
  };

  # Application launcher shortcuts
  appLauncher = { hyper_key ? "spacebar", modifiers ? [ "left_command" "left_control" "left_option" "left_shift" ], apps ? {} }:
    hyperKey {
      key = hyper_key;
      modifiers = modifiers;
      mappings = mapAttrs (key: app: {
        shell_command = "open -a '${app}'";
      }) apps;
    };

  # Quick text snippets
  textSnippets = snippets:
    map (snippet:
      rules.mkManipulator {
        from = rules.mkFromEvent {
          key_code = snippet.trigger;
          modifiers = rules.mkModifiers {
            mandatory = snippet.modifiers or [ "left_command" "left_shift" ];
          };
        };
        to = map (char: rules.mkToEvent { key_code = char; }) (stringToCharacters snippet.text);
        description = "Text snippet: ${snippet.trigger} -> ${snippet.text}";
      }
    ) snippets;
}
