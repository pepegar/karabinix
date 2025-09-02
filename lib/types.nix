{lib}:
with lib; rec {
  # Key code type - represents a Karabiner key code
  keyCode = types.str;

  # Modifier type - represents modifier keys
  modifier = types.enum [
    "left_command"
    "right_command"
    "command"
    "left_control"
    "right_control"
    "control"
    "left_shift"
    "right_shift"
    "shift"
    "left_option"
    "right_option"
    "option"
    "fn"
    "caps_lock"
  ];

  # From event type - what triggers the modification
  fromEvent = types.submodule {
    options = {
      key_code = mkOption {
        type = types.nullOr keyCode;
        default = null;
        description = "The key code to match";
      };

      consumer_key_code = mkOption {
        type = types.nullOr keyCode;
        default = null;
        description = "Consumer key code (media keys, etc.)";
      };

      pointing_button = mkOption {
        type = types.nullOr keyCode;
        default = null;
        description = "Mouse button";
      };

      modifiers = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            mandatory = mkOption {
              type = types.listOf modifier;
              default = [];
              description = "Required modifiers";
            };
            optional = mkOption {
              type = types.listOf modifier;
              default = [];
              description = "Optional modifiers";
            };
          };
        });
        default = null;
        description = "Modifier requirements";
      };

      simultaneous = mkOption {
        type = types.nullOr (types.listOf (types.submodule {
          options = {
            key_code = mkOption {
              type = keyCode;
              description = "Key code for simultaneous press";
            };
          };
        }));
        default = null;
        description = "Keys that must be pressed simultaneously";
      };

      simultaneous_options = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            detect_key_down_uninterruptedly = mkOption {
              type = types.bool;
              default = false;
              description = "Detect uninterrupted key down";
            };
            key_down_order = mkOption {
              type = types.nullOr (types.enum ["strict" "strict_inverse" "insensitive"]);
              default = null;
              description = "Key down order requirement";
            };
            key_up_order = mkOption {
              type = types.nullOr (types.enum ["strict" "strict_inverse" "insensitive"]);
              default = null;
              description = "Key up order requirement";
            };
            key_up_when = mkOption {
              type = types.nullOr (types.enum ["any" "all"]);
              default = null;
              description = "When to trigger key up";
            };
            to_after_key_up = mkOption {
              type = types.listOf toEvent;
              default = [];
              description = "Events to send after key up";
            };
          };
        });
        default = null;
        description = "Options for simultaneous key detection";
      };
    };
  };

  # To event type - what action to perform
  toEvent = types.submodule {
    options = {
      key_code = mkOption {
        type = types.nullOr keyCode;
        default = null;
        description = "Key code to send";
      };

      consumer_key_code = mkOption {
        type = types.nullOr keyCode;
        default = null;
        description = "Consumer key code to send";
      };

      pointing_button = mkOption {
        type = types.nullOr keyCode;
        default = null;
        description = "Mouse button to send";
      };

      shell_command = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Shell command to execute";
      };

      select_input_source = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            input_source_id = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Input source ID";
            };
            input_mode_id = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Input mode ID";
            };
            language = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Language code";
            };
          };
        });
        default = null;
        description = "Input source selection";
      };

      set_variable = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Variable name";
            };
            value = mkOption {
              type = types.oneOf [types.str types.int types.bool];
              description = "Variable value";
            };
          };
        });
        default = null;
        description = "Set a variable";
      };

      modifiers = mkOption {
        type = types.listOf modifier;
        default = [];
        description = "Modifiers to apply";
      };

      lazy = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the key press is lazy";
      };

      repeat = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the key press repeats";
      };

      halt = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to halt further processing";
      };

      hold_down_milliseconds = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "How long to hold the key down";
      };
    };
  };

  # Condition type - when a rule applies
  condition = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [
          "frontmost_application_if"
          "frontmost_application_unless"
          "device_if"
          "device_unless"
          "keyboard_type_if"
          "keyboard_type_unless"
          "input_source_if"
          "input_source_unless"
          "variable_if"
          "variable_unless"
          "event_changed_if"
          "event_changed_unless"
        ];
        description = "Type of condition";
      };

      # Application conditions
      bundle_identifiers = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = "Application bundle identifiers";
      };

      file_paths = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = "Application file paths";
      };

      # Device conditions
      identifiers = mkOption {
        type = types.nullOr (types.listOf (types.submodule {
          options = {
            vendor_id = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Device vendor ID";
            };
            product_id = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Device product ID";
            };
            location_id = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Device location ID";
            };
            is_keyboard = mkOption {
              type = types.nullOr types.bool;
              default = null;
              description = "Whether device is a keyboard";
            };
            is_pointing_device = mkOption {
              type = types.nullOr types.bool;
              default = null;
              description = "Whether device is a pointing device";
            };
          };
        }));
        default = null;
        description = "Device identifiers";
      };

      # Keyboard type conditions
      keyboard_types = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = "Keyboard types";
      };

      # Input source conditions
      input_sources = mkOption {
        type = types.nullOr (types.listOf (types.submodule {
          options = {
            input_source_id = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Input source ID";
            };
            input_mode_id = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Input mode ID";
            };
            language = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Language code";
            };
          };
        }));
        default = null;
        description = "Input sources";
      };

      # Variable conditions
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Variable name";
      };

      value = mkOption {
        type = types.nullOr (types.oneOf [types.str types.int types.bool]);
        default = null;
        description = "Variable value";
      };
    };
  };

  # Manipulator type - a single key transformation rule
  manipulator = types.submodule {
    options = {
      type = mkOption {
        type = types.enum ["basic" "mouse_motion_to_scroll"];
        default = "basic";
        description = "Type of manipulator";
      };

      from = mkOption {
        type = fromEvent;
        description = "Event to transform from";
      };

      to = mkOption {
        type = types.listOf toEvent;
        default = [];
        description = "Events to transform to";
      };

      to_if_alone = mkOption {
        type = types.listOf toEvent;
        default = [];
        description = "Events to send if key is pressed alone";
      };

      to_if_held_down = mkOption {
        type = types.listOf toEvent;
        default = [];
        description = "Events to send if key is held down";
      };

      to_after_key_up = mkOption {
        type = types.listOf toEvent;
        default = [];
        description = "Events to send after key up";
      };

      to_delayed_action = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            to_if_invoked = mkOption {
              type = types.listOf toEvent;
              default = [];
              description = "Events if delayed action is invoked";
            };
            to_if_canceled = mkOption {
              type = types.listOf toEvent;
              default = [];
              description = "Events if delayed action is canceled";
            };
          };
        });
        default = null;
        description = "Delayed action configuration";
      };

      conditions = mkOption {
        type = types.listOf condition;
        default = [];
        description = "Conditions for this manipulator";
      };

      parameters = mkOption {
        type = types.nullOr (types.submodule {
          options = {
            basic.simultaneous_threshold_milliseconds = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Simultaneous key threshold in milliseconds";
            };
            basic.to_if_alone_timeout_milliseconds = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Timeout for to_if_alone in milliseconds";
            };
            basic.to_if_held_down_threshold_milliseconds = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Threshold for to_if_held_down in milliseconds";
            };
            basic.to_delayed_action_delay_milliseconds = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Delay for delayed action in milliseconds";
            };
          };
        });
        default = null;
        description = "Parameters for this manipulator";
      };

      description = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Description of this manipulator";
      };
    };
  };

  # Rule type - a collection of manipulators
  rule = types.submodule {
    options = {
      description = mkOption {
        type = types.str;
        description = "Description of the rule";
      };

      manipulators = mkOption {
        type = types.listOf manipulator;
        description = "List of manipulators in this rule";
      };
    };
  };

  # Simple modification type
  simpleModification = types.submodule {
    options = {
      from = mkOption {
        type = types.submodule {
          options = {
            key_code = mkOption {
              type = keyCode;
              description = "Key to modify";
            };
          };
        };
        description = "Key to modify";
      };

      to = mkOption {
        type = types.listOf (types.submodule {
          options = {
            key_code = mkOption {
              type = keyCode;
              description = "Target key";
            };
          };
        });
        description = "Target key(s)";
      };
    };
  };

  # Profile type
  profile = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Profile name";
      };

      selected = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this profile is selected";
      };

      simple_modifications = mkOption {
        type = types.listOf simpleModification;
        default = [];
        description = "Simple key modifications";
      };

      complex_modifications = mkOption {
        type = types.submodule {
          options = {
            parameters = mkOption {
              type = types.nullOr (types.submodule {
                options = {
                  "basic.simultaneous_threshold_milliseconds" = mkOption {
                    type = types.int;
                    default = 50;
                    description = "Simultaneous key threshold";
                  };
                  "basic.to_if_alone_timeout_milliseconds" = mkOption {
                    type = types.int;
                    default = 1000;
                    description = "Timeout for alone key actions";
                  };
                  "basic.to_if_held_down_threshold_milliseconds" = mkOption {
                    type = types.int;
                    default = 500;
                    description = "Threshold for held down actions";
                  };
                  "basic.to_delayed_action_delay_milliseconds" = mkOption {
                    type = types.int;
                    default = 500;
                    description = "Delay for delayed actions";
                  };
                };
              });
              default = null;
              description = "Global parameters for complex modifications";
            };

            rules = mkOption {
              type = types.listOf rule;
              default = [];
              description = "Complex modification rules";
            };
          };
        };
        default = {rules = [];};
        description = "Complex modifications";
      };

      devices = mkOption {
        type = types.listOf (types.submodule {
          options = {
            identifiers = mkOption {
              type = types.submodule {
                options = {
                  vendor_id = mkOption {
                    type = types.int;
                    description = "Device vendor ID";
                  };
                  product_id = mkOption {
                    type = types.int;
                    description = "Device product ID";
                  };
                  is_keyboard = mkOption {
                    type = types.bool;
                    description = "Whether device is a keyboard";
                  };
                  is_pointing_device = mkOption {
                    type = types.bool;
                    description = "Whether device is a pointing device";
                  };
                };
              };
              description = "Device identifiers";
            };

            ignore = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to ignore this device";
            };

            manipulate_caps_lock_led = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to manipulate caps lock LED";
            };

            simple_modifications = mkOption {
              type = types.listOf simpleModification;
              default = [];
              description = "Device-specific simple modifications";
            };

            fn_function_keys = mkOption {
              type = types.listOf (types.submodule {
                options = {
                  from = mkOption {
                    type = types.submodule {
                      options = {
                        key_code = mkOption {
                          type = keyCode;
                          description = "Function key";
                        };
                      };
                    };
                    description = "Function key to modify";
                  };

                  to = mkOption {
                    type = types.listOf (types.submodule {
                      options = {
                        key_code = mkOption {
                          type = keyCode;
                          description = "Target key";
                        };
                      };
                    });
                    description = "Target key(s)";
                  };
                };
              });
              default = [];
              description = "Function key modifications";
            };
          };
        });
        default = [];
        description = "Device-specific settings";
      };

      fn_function_keys = mkOption {
        type = types.listOf (types.submodule {
          options = {
            from = mkOption {
              type = types.submodule {
                options = {
                  key_code = mkOption {
                    type = keyCode;
                    description = "Function key";
                  };
                };
              };
              description = "Function key to modify";
            };

            to = mkOption {
              type = types.listOf (types.submodule {
                options = {
                  key_code = mkOption {
                    type = keyCode;
                    description = "Target key";
                  };
                };
              });
              description = "Target key(s)";
            };
          };
        });
        default = [];
        description = "Global function key modifications";
      };

      virtual_hid_keyboard = mkOption {
        type = types.submodule {
          options = {
            country_code = mkOption {
              type = types.int;
              default = 0;
              description = "Keyboard country code";
            };
            indicate_sticky_modifier_keys_state = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to indicate sticky modifier keys state";
            };
            mouse_key_xy_scale = mkOption {
              type = types.int;
              default = 100;
              description = "Mouse key XY scale";
            };
          };
        };
        default = {};
        description = "Virtual HID keyboard settings";
      };
    };
  };

  # Main configuration type
  configuration = types.submodule {
    options = {
      global = mkOption {
        type = types.submodule {
          options = {
            check_for_updates_on_startup = mkOption {
              type = types.bool;
              default = true;
              description = "Check for updates on startup";
            };
            show_in_menu_bar = mkOption {
              type = types.bool;
              default = true;
              description = "Show in menu bar";
            };
            show_profile_name_in_menu_bar = mkOption {
              type = types.bool;
              default = false;
              description = "Show profile name in menu bar";
            };
            unsafe_ui = mkOption {
              type = types.bool;
              default = false;
              description = "Enable unsafe UI features";
            };
          };
        };
        default = {};
        description = "Global settings";
      };

      profiles = mkOption {
        type = types.listOf profile;
        description = "Configuration profiles";
      };
    };
  };
}
