# Sublayer System Example - mxstbr Style
# This example demonstrates the sublayer system similar to mxstbr's Karabiner configuration
# Usage: Hold Caps Lock (hyper) + sublayer key (o, b, w, etc.) + action key
{karabinix}:
with karabinix.lib;
  mkConfiguration {
    profiles = [
      (mkProfile {
        name = "Sublayers";
        selected = true;

        complex_modifications = mkComplexModification {
          rules = [
            # Main sublayer system using Caps Lock as hyper key
            (sublayerKey {
              key = keyCodes.caps_lock;
              alone_key = keyCodes.escape;  # Caps Lock alone sends Escape
              variable_name = "hyper";      # Base variable name
              
              sublayers = {
                # "o" sublayer - Window management (like mxstbr's "o" for "open")
                "o" = {
                  # Window positioning
                  "w" = raycastWindow "left-half";
                  "e" = raycastWindow "right-half";
                  "r" = raycastWindow "top-half";
                  "s" = raycastWindow "bottom-half";
                  
                  # Quarters
                  "q" = raycastWindow "top-left-quarter";
                  "a" = raycastWindow "top-right-quarter";
                  "z" = raycastWindow "bottom-left-quarter";
                  "x" = raycastWindow "bottom-right-quarter";
                  
                  # Fullscreen and center
                  "f" = raycastWindow "maximize";
                  "c" = raycastWindow "center";
                  
                  # Move between displays
                  "h" = raycastWindow "previous-display";
                  "l" = raycastWindow "next-display";
                };

                # "b" sublayer - Browser/Bookmarks (like mxstbr's "b" for "browse")
                "b" = {
                  "t" = { shell_command = "open https://twitter.com"; };
                  "f" = { shell_command = "open https://facebook.com"; };
                  "r" = { shell_command = "open https://reddit.com"; };
                  "y" = { shell_command = "open https://news.ycombinator.com"; };
                  "g" = { shell_command = "open https://github.com"; };
                  "m" = { shell_command = "open https://gmail.com"; };
                };

                # "w" sublayer - Work applications
                "w" = {
                  "s" = { shell_command = "open -a 'Slack'"; };
                  "d" = { shell_command = "open -a 'Discord'"; };
                  "z" = { shell_command = "open -a 'Zoom'"; };
                  "n" = { shell_command = "open -a 'Notion'"; };
                  "f" = { shell_command = "open -a 'Figma'"; };
                  "c" = { shell_command = "open -a 'Visual Studio Code'"; };
                };

                # "s" sublayer - System controls
                "s" = {
                  "l" = { shell_command = "pmset displaysleepnow"; };  # Lock screen
                  "s" = { shell_command = "pmset sleepnow"; };         # Sleep
                  "r" = { shell_command = "sudo shutdown -r now"; };   # Restart
                  "p" = { shell_command = "sudo shutdown -h now"; };   # Power off
                  "v" = { key_code = keyCodes.volume_up; };
                  "c" = { key_code = keyCodes.volume_down; };
                  "m" = { key_code = keyCodes.mute; };
                };

                # "v" sublayer - Development tools
                "v" = {
                  "t" = { shell_command = "open -a 'Terminal'"; };
                  "i" = { shell_command = "open -a 'iTerm'"; };
                  "c" = { shell_command = "open -a 'Visual Studio Code'"; };
                  "x" = { shell_command = "open -a 'Xcode'"; };
                  "d" = { shell_command = "open -a 'Docker Desktop'"; };
                  "p" = { shell_command = "open -a 'Postman'"; };
                };

                # "c" sublayer - Communication
                "c" = {
                  "s" = { shell_command = "open -a 'Slack'"; };
                  "d" = { shell_command = "open -a 'Discord'"; };
                  "t" = { shell_command = "open -a 'Telegram'"; };
                  "w" = { shell_command = "open -a 'WhatsApp'"; };
                  "m" = { shell_command = "open -a 'Mail'"; };
                  "z" = { shell_command = "open -a 'Zoom'"; };
                };

                # "r" sublayer - Raycast extensions (like mxstbr's raycast shortcuts)
                "r" = {
                  "c" = { shell_command = "open raycast://extensions/raycast/clipboard-history/clipboard-history"; };
                  "e" = { shell_command = "open raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"; };
                  "s" = { shell_command = "open raycast://extensions/raycast/snippets/search-snippets"; };
                  "p" = { shell_command = "open raycast://extensions/raycast/raycast/confetti"; };
                  "a" = { shell_command = "open raycast://extensions/raycast/raycast-ai/ai-chat"; };
                  "w" = { shell_command = "open raycast://extensions/raycast/window-management/center"; };
                };
              };
            })

            # Additional direct shortcuts (without sublayers)
            (hyperKey {
              key = keyCodes.spacebar;
              mappings = {
                # Quick Raycast launcher
                "space" = { shell_command = "open raycast://"; };
              };
            })
          ];
        };
      })
    ];
  }
