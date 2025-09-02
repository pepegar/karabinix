{
  lib,
  types,
  rules,
  utils,
}:
with lib;
# Main function to create a Karabiner Elements configuration
  config: let
    # Default global settings
    defaultGlobal = {
      check_for_updates_on_startup = true;
      show_in_menu_bar = true;
      show_profile_name_in_menu_bar = false;
      unsafe_ui = false;
    };

    # Default virtual HID keyboard settings
    defaultVirtualHidKeyboard = {
      country_code = 0;
      indicate_sticky_modifier_keys_state = true;
      mouse_key_xy_scale = 100;
    };

    # Default complex modification parameters
    defaultComplexModificationParameters = {
      "basic.simultaneous_threshold_milliseconds" = 50;
      "basic.to_if_alone_timeout_milliseconds" = 1000;
      "basic.to_if_held_down_threshold_milliseconds" = 500;
      "basic.to_delayed_action_delay_milliseconds" = 500;
    };

    # Process a profile configuration
    processProfile = profileConfig: let
      profile =
        profileConfig
        // {
          virtual_hid_keyboard = defaultVirtualHidKeyboard // (profileConfig.virtual_hid_keyboard or {});

          complex_modifications = let
            cm = profileConfig.complex_modifications or {rules = [];};
          in {
            parameters = defaultComplexModificationParameters // (cm.parameters or {});
            rules = cm.rules or [];
          };
        };
    in
      profile;

    # Convert the configuration to the final JSON structure
    finalConfig = {
      global = defaultGlobal // (config.global or {});
      profiles = map processProfile config.profiles;
    };
  in
    # Return the configuration as a JSON string
    builtins.toJSON finalConfig
