{
  description = "Notification message debugging example for karabinix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    karabinix.url = "github:pepegar/karabinix";
  };

  outputs = { self, nixpkgs, karabinix }:
    let
      system = "aarch64-darwin"; # or "x86_64-darwin"
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (karabinix.lib.${system}) utils rules keyCodes;
    in
    {
      # Basic notification message usage
      basic-notifications = utils.mkRule "Basic Notification Examples" [
        # Simple notification on key press
        (rules.mkManipulator {
          from = rules.mkFromEvent {
            key_code = "f1";
          };
          to = [
            (utils.showNotification "f1_pressed" "F1 key was pressed!")
            (rules.mkToEvent { key_code = "f1"; })
          ];
          to_after_key_up = [
            (utils.hideNotification "f1_pressed")
          ];
          description = "F1 with notification";
        })

        # Show notification for a few seconds then auto-hide
        (rules.mkManipulator {
          from = rules.mkFromEvent {
            key_code = "f2";
          };
          to = [
            (utils.showNotification "f2_info" "This message will stay visible while F2 is held")
            (rules.mkToEvent { key_code = "f2"; })
          ];
          to_after_key_up = [
            (utils.hideNotification "f2_info")
          ];
          description = "F2 with persistent notification";
        })
      ];

      # Debug layer key example - ENABLED to show mappings
      debug-layer-example = utils.layerKey {
        key = "spacebar";
        layer_name = "Navigation";
        enable_debug = true; # Set to true to enable debugging notifications
        mappings = {
          h = keyCodes.left_arrow;
          j = keyCodes.down_arrow;
          k = keyCodes.up_arrow;
          l = keyCodes.right_arrow;
          w = ["left_option" "right_arrow"];
          b = ["left_option" "left_arrow"];
          "0" = keyCodes.home;
          "4" = keyCodes.end;
          u = keyCodes.page_up;
        };
      };

      # Debug individual keys - DISABLED by default
      debug-keys-example = utils.mkRule "Debug Individual Keys" [
        (utils.debugKey {
          key = "caps_lock";
          action = rules.mkToEvent { key_code = "escape"; };
          notification_text = "Caps Lock -> Escape";
          enable_debug = false; # Set to true to enable debugging notifications
        })

        (utils.debugKey {
          key = "tab";
          notification_text = "Tab key pressed";
          enable_debug = false; # Set to true to enable debugging notifications
        })
      ];

      # Advanced example: Layer with debug notifications enabled
      advanced-debug-layer = utils.layerKey {
        key = "right_command";
        alone_key = "right_command";
        layer_name = "Window Management";
        variable_name = "window_mgmt_layer";
        enable_debug = true; # This one is enabled for demonstration
        mappings = {
          "1" = utils.raycastWindow "left-half";
          "2" = utils.raycastWindow "right-half";
          "3" = utils.raycastWindow "maximize";
          "4" = utils.raycastWindow "center";
        };
      };

      # Debug vim navigation example
      debug-vim-navigation = utils.vimNavigation {
        layer_key = "caps_lock";
        layer_name = "Vim Mode";
        enable_debug = true; # Enable to see vim mappings
      };

      # Manual notification control example
      manual-notifications = utils.mkRule "Manual Notification Control" [
        # Toggle a persistent notification
        (rules.mkManipulator {
          from = rules.mkFromEvent {
            key_code = "f10";
            modifiers = rules.mkModifiers {
              mandatory = ["left_command"];
            };
          };
          to = [
            (utils.showNotification "status_indicator" "Debug mode active - Press Cmd+F11 to hide")
          ];
          description = "Show debug status notification";
        })

        # Hide the persistent notification
        (rules.mkManipulator {
          from = rules.mkFromEvent {
            key_code = "f11";
            modifiers = rules.mkModifiers {
              mandatory = ["left_command"];
            };
          };
          to = [
            (utils.hideNotification "status_indicator")
          ];
          description = "Hide debug status notification";
        })

        # Show detailed key information
        (rules.mkManipulator {
          from = rules.mkFromEvent {
            key_code = "f12";
            modifiers = rules.mkModifiers {
              mandatory = ["left_command"];
            };
          };
          to = [
            (utils.showNotification "key_info" "Cmd+F12 pressed at ${toString builtins.currentTime}")
          ];
          to_after_key_up = [
            (utils.hideNotification "key_info")
          ];
          description = "Show timestamp notification";
        })
      ];

      # Complete configuration example
      complete-config = {
        profiles = [
          {
            name = "Notification Debug Profile";
            selected = true;
            complex_modifications = {
              rules = [
                # Include all the examples above
                # NOTE: Most debugging is DISABLED by default
                # To enable debugging, set enable_debug = true in the examples above
                
                # Basic notifications (always enabled for demonstration)
                self.basic-notifications
                
                # Debug features (disabled by default)
                self.debug-layer-example
                self.debug-keys-example
                
                # Advanced debug layer (enabled for demonstration)
                self.advanced-debug-layer
                
                # Manual notification controls
                self.manual-notifications
              ];
            };
          }
        ];
      };
    };
}
