{
  lib,
  types,
}:
with lib; let
  rules = import ./rules.nix {inherit lib types;};
  keyCodes = import ./keycodes.nix;
in rec {
  # Simple key mapping utility
  mapKey = from: to:
    rules.mkSimpleModification from to;

  # Create a hyper key configuration
  # Maps a key + modifiers to act as a "hyper" key that can trigger other mappings
  hyperKey = {
    key,
    mappings,
    modifiers ? ["left_command" "left_control" "left_option" "left_shift"],
    alone_key ? null,
    held_key ? null,
  }: let
    # Create manipulators for each mapping
    hyperManipulators =
      mapAttrsToList (
        trigger: target:
          rules.mkManipulator {
            from = rules.mkFromEvent {
              key_code = trigger;
            };
            to =
              if isString target
              then [
                (rules.mkToEvent {key_code = target;})
              ]
              else if isList target
              then map (t: rules.mkToEvent {key_code = t;}) target
              else [
                target
              ];
            description = "Hyper + ${trigger} -> ${
              if isString target
              then target
              else if isList target
              then toString target
              else "action"
            }";
          }
      )
      mappings;

    # Main hyper key manipulator
    hyperKeyManipulator = rules.mkManipulator {
      from = rules.mkFromEvent {key_code = key;};
      to = [
        (rules.mkToEvent {
          set_variable = {
            name = "hyper_mode";
            value = 1;
          };
        })
      ];
      to_if_alone =
        if alone_key != null
        then [
          (rules.mkToEvent {key_code = alone_key;})
        ]
        else [];
      to_if_held_down =
        if held_key != null
        then [
          (rules.mkToEvent {key_code = held_key;})
        ]
        else [];
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
    hyperManipulatorsWithCondition =
      map (
        manipulator:
          manipulator
          // {
            conditions =
              (manipulator.conditions or [])
              ++ [
                (rules.mkCondition {
                  type = "variable_if";
                  name = "hyper_mode";
                  value = 1;
                })
              ];
          }
      )
      hyperManipulators;
  in
    rules.mkRule "Hyper Key (${key})" ([hyperKeyManipulator] ++ hyperManipulatorsWithCondition);

  # Create simultaneous key press mappings
  simultaneousKeys = keys: to: options: let
    simultaneousFrom = rules.mkFromEvent {
      simultaneous = map (key: {key_code = key;}) keys;
      simultaneous_options = {
        detect_key_down_uninterruptedly = options.detect_key_down_uninterruptedly or false;
        key_down_order = options.key_down_order or null;
        key_up_order = options.key_up_order or null;
        key_up_when = options.key_up_when or null;
        to_after_key_up = options.to_after_key_up or [];
      };
    };

    toEvents =
      if isString to
      then [
        (rules.mkToEvent {key_code = to;})
      ]
      else if isList to
      then
        map (t:
          if isString t
          then rules.mkToEvent {key_code = t;}
          else t)
        to
      else [
        to
      ];
  in
    rules.mkManipulator {
      from = simultaneousFrom;
      to = toEvents;
      description = "Simultaneous: ${concatStringsSep " + " keys} -> ${
        if isString to
        then to
        else if isList to
        then toString to
        else "action"
      }";
    };

  # Create a layer key (key that activates a layer when held)
  layerKey = {
    key,
    mappings,
    alone_key ? null,
    variable_name ? "${key}_layer",
  }: let
    # Helper function to parse trigger keys that may include modifiers
    # Supports syntax like "shift+m", "ctrl+shift+a", or just "m"
    parseTrigger = trigger: let
      parts = splitString "+" trigger;
      key_code = last parts;
      modifierParts = init parts;

      # Map modifier names to Karabiner modifier names
      mapModifier = mod:
        if mod == "shift"
        then "left_shift"
        else if mod == "ctrl" || mod == "control"
        then "left_control"
        else if mod == "alt" || mod == "option"
        then "left_option"
        else if mod == "cmd" || mod == "command"
        then "left_command"
        else if mod == "fn"
        then "fn"
        else mod; # Pass through as-is for exact modifier names
    in
      {
        key_code = key_code;
      }
      // (optionalAttrs (modifierParts != []) {
        modifiers = map mapModifier modifierParts;
      });

    # Create manipulators for each mapping in the layer
    layerManipulators =
      mapAttrsToList (
        trigger: target: let
          triggerSpec = parseTrigger trigger;
          fromEvent = rules.mkFromEvent ({
              key_code = triggerSpec.key_code;
            }
            // (optionalAttrs (triggerSpec ? modifiers) {
              modifiers = rules.mkModifiers {
                mandatory = triggerSpec.modifiers;
              };
            }));
        in
          rules.mkManipulator {
            from = fromEvent;
            to =
              if isString target
              then [
                (rules.mkToEvent {key_code = target;})
              ]
              else if isList target
              then map (t: rules.mkToEvent {key_code = t;}) target
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
            description = "Layer ${key}: ${trigger} -> ${
              if isString target
              then target
              else if isList target
              then toString target
              else "action"
            }";
          }
      )
      mappings;

    # Layer activation key
    layerKeyManipulator = rules.mkManipulator {
      from = rules.mkFromEvent {key_code = key;};
      to = [
        (rules.mkToEvent {
          set_variable = {
            name = variable_name;
            value = 1;
          };
        })
      ];
      to_if_alone =
        if alone_key != null
        then [
          (rules.mkToEvent {key_code = alone_key;})
        ]
        else [];
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
    rules.mkRule "Layer: ${key}" ([layerKeyManipulator] ++ layerManipulators);

  # Application-specific condition
  appCondition = apps: type:
    rules.mkCondition {
      inherit type;
      bundle_identifiers =
        if isString apps
        then [apps]
        else apps;
    };

  # Device-specific condition
  deviceCondition = {
    vendor_id ? null,
    product_id ? null,
    location_id ? null,
    is_keyboard ? null,
    is_pointing_device ? null,
    type ? "device_if",
  }:
    rules.mkCondition {
      inherit type;
      identifiers = [
        {
          vendor_id = vendor_id;
          product_id = product_id;
          location_id = location_id;
          is_keyboard = is_keyboard;
          is_pointing_device = is_pointing_device;
        }
      ];
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
  vimNavigation = {
    layer_key,
    variable_name ? "vim_mode",
  }: let
    # Basic vim navigation mappings
    basicVimLayer = layerKey {
      key = layer_key;
      variable_name = variable_name;
      mappings = {
        h = keyCodes.left_arrow;
        j = keyCodes.down_arrow;
        k = keyCodes.up_arrow;
        l = keyCodes.right_arrow;
        w = rules.mkToEvent {
          key_code = keyCodes.right_arrow;
          modifiers = ["left_option"];
        };
        b = rules.mkToEvent {
          key_code = keyCodes.left_arrow;
          modifiers = ["left_option"];
        };
        "0" = keyCodes.home;
        "4" = keyCodes.end; # $ key
        u = keyCodes.page_up;
        d = keyCodes.page_down;
        g = keyCodes.home;
      };
    };

    # Additional manipulator for Shift+G (go to end, like Vim's G)
    shiftGManipulator = rules.mkManipulator {
      from = rules.mkFromEvent {
        key_code = keyCodes.g;
        modifiers = rules.mkModifiers {
          mandatory = ["left_shift"];
        };
      };
      to = [
        (rules.mkToEvent {key_code = keyCodes.end;})
      ];
      conditions = [
        (rules.mkCondition {
          type = "variable_if";
          name = variable_name;
          value = 1;
        })
      ];
      description = "Vim layer: Shift+G -> End";
    };
  in
    rules.mkRule "Vim Navigation (${layer_key})" (basicVimLayer.manipulators ++ [shiftGManipulator]);

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
  appLauncher = {
    hyper_key ? "spacebar",
    modifiers ? ["left_command" "left_control" "left_option" "left_shift"],
    apps ? {},
  }:
    hyperKey {
      key = hyper_key;
      modifiers = modifiers;
      mappings =
        mapAttrs (key: app: {
          shell_command = "open -a '${app}'";
        })
        apps;
    };

  # Raycast window management function
  # Creates a shell command to trigger Raycast window management actions
  raycastWindow = name: {
    shell_command = "open -g raycast://extensions/raycast/window-management/${name}";
  };

  # Quick text snippets
  textSnippets = snippets:
    map (
      snippet:
        rules.mkManipulator {
          from = rules.mkFromEvent {
            key_code = snippet.trigger;
            modifiers = rules.mkModifiers {
              mandatory = snippet.modifiers or ["left_command" "left_shift"];
            };
          };
          to = map (char: rules.mkToEvent {key_code = char;}) (stringToCharacters snippet.text);
          description = "Text snippet: ${snippet.trigger} -> ${snippet.text}";
        }
    )
    snippets;

  # Create per-application layer keys
  # This allows different layer mappings based on the frontmost application
  appLayerKey = {
    key,
    alone_key ? null,
    variable_name ? "${key}_app_layer",
    app_mappings, # attrset where keys are app bundle IDs and values are mapping attrsets
  }: let
    # Helper function to parse trigger keys that may include modifiers
    # Supports syntax like "shift+m", "ctrl+shift+a", or just "m"
    parseTrigger = trigger: let
      parts = splitString "+" trigger;
      key_code = last parts;
      modifierParts = init parts;

      # Map modifier names to Karabiner modifier names
      mapModifier = mod:
        if mod == "shift"
        then "left_shift"
        else if mod == "ctrl" || mod == "control"
        then "left_control"
        else if mod == "alt" || mod == "option"
        then "left_option"
        else if mod == "cmd" || mod == "command"
        then "left_command"
        else if mod == "fn"
        then "fn"
        else mod; # Pass through as-is for exact modifier names
    in
      {
        key_code = key_code;
      }
      // (optionalAttrs (modifierParts != []) {
        modifiers = map mapModifier modifierParts;
      });

    # Create manipulators for each app's mappings
    createAppManipulators = appId: mappings:
      mapAttrsToList (
        trigger: target: let
          triggerSpec = parseTrigger trigger;
          fromEvent = rules.mkFromEvent ({
              key_code = triggerSpec.key_code;
            }
            // (optionalAttrs (triggerSpec ? modifiers) {
              modifiers = rules.mkModifiers {
                mandatory = triggerSpec.modifiers;
              };
            }));
        in
          rules.mkManipulator {
            from = fromEvent;
            to =
              if isString target
              then [
                (rules.mkToEvent {key_code = target;})
              ]
              else if isList target
              then map (t: rules.mkToEvent {key_code = t;}) target
              else [
                target
              ];
            conditions = [
              (rules.mkCondition {
                type = "variable_if";
                name = variable_name;
                value = 1;
              })
              (appCondition appId "frontmost_application_if")
            ];
            description = "App Layer ${key} (${appId}): ${trigger} -> ${
              if isString target
              then target
              else if isList target
              then toString target
              else "action"
            }";
          }
      )
      mappings;

    # Create all manipulators for all apps
    allAppManipulators = flatten (mapAttrsToList createAppManipulators app_mappings);

    # Layer activation key
    layerKeyManipulator = rules.mkManipulator {
      from = rules.mkFromEvent {key_code = key;};
      to = [
        (rules.mkToEvent {
          set_variable = {
            name = variable_name;
            value = 1;
          };
        })
      ];
      to_if_alone =
        if alone_key != null
        then [
          (rules.mkToEvent {key_code = alone_key;})
        ]
        else [];
      to_after_key_up = [
        (rules.mkToEvent {
          set_variable = {
            name = variable_name;
            value = 0;
          };
        })
      ];
      description = "App Layer key (${key})";
    };
  in
    rules.mkRule "App Layer: ${key}" ([layerKeyManipulator] ++ allAppManipulators);

  # Home row mod utilities
  # Create a single home row mod key (tap for key, hold for modifier)
  homeRowMod = {
    key, # The key to modify (e.g., "s", "d", "f", etc.)
    modifier, # The modifier when held (e.g., "left_option", "left_control", etc.)
    description ? null, # Optional custom description
  }:
    rules.mkManipulator {
      from = rules.mkFromEvent {
        key_code = key;
      };
      to_if_alone = [
        (rules.mkToEvent {
          halt = true;
          key_code = key;
        })
      ];
      to_if_held_down = [
        (rules.mkToEvent {
          halt = true;
          key_code = modifier;
        })
      ];
      to_delayed_action = {
        to_if_canceled = [{key_code = key;}];
        to_if_invoked = [{key_code = "vk_none";}];
      };
      description =
        if description != null
        then description
        else "${key}: ${modifier} when held, ${key} when tapped";
    };

  # Create multiple home row mods at once
  # Takes an attribute set where keys are the keys to modify and values are the modifiers
  homeRowMods = mods: let
    modList =
      mapAttrsToList (
        key: modifier:
          homeRowMod {inherit key modifier;}
      )
      mods;
  in
    rules.mkRule "Home Row Mods" modList;

  # Predefined common home row mod configurations
  # Standard QWERTY home row mods (ASDF / JKL;)
  standardHomeRowMods = homeRowMods {
    a = keyCodes.left_shift;
    s = keyCodes.left_option;
    d = keyCodes.left_control;
    f = keyCodes.left_command;
    j = keyCodes.right_command;
    k = keyCodes.right_control;
    l = keyCodes.right_option;
    semicolon = keyCodes.right_shift;
  };

  # Alternative home row mods (more common for some users)
  altHomeRowMods = homeRowMods {
    a = keyCodes.left_control;
    s = keyCodes.left_option;
    d = keyCodes.left_command;
    f = keyCodes.left_shift;
    j = keyCodes.right_shift;
    k = keyCodes.right_command;
    l = keyCodes.right_option;
    semicolon = keyCodes.right_control;
  };

  # This allows for hyper + sublayer + action patterns (e.g., hyper+o+w)
  sublayerKey = {
    key, # The main hyper key (e.g., "caps_lock")
    alone_key, # What to send if pressed alone
    variable_name, # Base variable name for the hyper key
    sublayers, # Nested sublayers: { "o" = { "w" = action; }; }
  }: let
    # Helper to convert action to toEvent
    actionToToEvent = action:
      if isString action
      then rules.mkToEvent {key_code = action;}
      else if isList action
      then
        map (a:
          if isString a
          then rules.mkToEvent {key_code = a;}
          else a)
        action
      else action;

    # Create the main hyper key manipulator
    hyperKeyManipulator = rules.mkManipulator {
      from = rules.mkFromEvent {key_code = key;};
      to = [
        (rules.mkToEvent {
          set_variable = {
            name = variable_name;
            value = 1;
          };
        })
      ];
      to_if_alone =
        if alone_key != null
        then [
          (rules.mkToEvent {key_code = alone_key;})
        ]
        else [];
      to_after_key_up = [
        (rules.mkToEvent {
          set_variable = {
            name = variable_name;
            value = 0;
          };
        })
      ];
      description = "Hyper Key (${key})";
    };

    # Get all sublayer keys to create mutual exclusion conditions
    sublayerKeys = attrNames sublayers;

    # Create sublayer variable names
    sublayerVariableNames = map (sublayerKey: "${variable_name}_sublayer_${sublayerKey}") sublayerKeys;

    # Helper to create conditions that ensure only one sublayer is active
    createMutualExclusionConditions = currentSublayerKey: let
      otherSublayerKeys = filter (k: k != currentSublayerKey) sublayerKeys;
      otherVariableNames = map (k: "${variable_name}_sublayer_${k}") otherSublayerKeys;
    in
      # Hyper must be active
      [
        (rules.mkCondition {
          type = "variable_if";
          name = variable_name;
          value = 1;
        })
      ]
      ++
      # All other sublayers must be inactive
      (map (varName:
        rules.mkCondition {
          type = "variable_if";
          name = varName;
          value = 0;
        })
      otherVariableNames);

    # Create sublayer activation manipulators
    createSublayerActivator = sublayerKey: sublayerMappings: let
      sublayerVarName = "${variable_name}_sublayer_${sublayerKey}";
      conditions = createMutualExclusionConditions sublayerKey;
    in
      rules.mkManipulator {
        from = rules.mkFromEvent {key_code = sublayerKey;};
        to = [
          (rules.mkToEvent {
            set_variable = {
              name = sublayerVarName;
              value = 1;
            };
          })
        ];
        to_after_key_up = [
          (rules.mkToEvent {
            set_variable = {
              name = sublayerVarName;
              value = 0;
            };
          })
        ];
        conditions = conditions;
        description = "Toggle Hyper sublayer ${sublayerKey}";
      };

    # Create action manipulators for each sublayer
    createSublayerActions = sublayerKey: sublayerMappings: let
      sublayerVarName = "${variable_name}_sublayer_${sublayerKey}";
    in
      mapAttrsToList (
        actionKey: action:
          rules.mkManipulator {
            from = rules.mkFromEvent {key_code = actionKey;};
            to =
              if isList action
              then map actionToToEvent action
              else [
                (actionToToEvent action)
              ];
            conditions = [
              (rules.mkCondition {
                type = "variable_if";
                name = sublayerVarName;
                value = 1;
              })
            ];
            description = "Hyper ${sublayerKey} + ${actionKey}";
          }
      )
      sublayerMappings;

    # Create all sublayer activators
    sublayerActivators = mapAttrsToList createSublayerActivator sublayers;

    # Create all sublayer actions
    allSublayerActions = flatten (mapAttrsToList createSublayerActions sublayers);

    # Combine all manipulators
    allManipulators = [hyperKeyManipulator] ++ sublayerActivators ++ allSublayerActions;
  in
    rules.mkRule "Sublayer System (${key})" allManipulators;
}
