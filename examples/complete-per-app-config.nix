# Complete configuration example using per-app layers
# This demonstrates how to integrate per-app layers into a full Karabiner configuration
{lib, ...}: let
  karabinix = import ../lib {inherit lib;};
  inherit (karabinix) mkConfiguration mkProfile mkComplexModification appLayerKey keyCodes;
in
  mkConfiguration {
    profiles = [
      (mkProfile {
        name = "Per-App Layers";
        selected = true;

        complex_modifications = mkComplexModification {
          # Timing parameters
          parameters = {
            "basic.simultaneous_threshold_milliseconds" = 50;
            "basic.to_if_alone_timeout_milliseconds" = 1000;
            "basic.to_if_held_down_threshold_milliseconds" = 500;
          };

          rules = [
            # Main per-app spacebar layer
            (appLayerKey {
              key = keyCodes.spacebar;
              alone_key = keyCodes.spacebar;
              variable_name = "spacebar_app_layer";
              app_mappings = {
                # Development environments
                "com.microsoft.VSCode" = {
                  # Quick file operations
                  f = {
                    key_code = keyCodes.p;
                    modifiers = ["left_command"]; # Quick open file
                  };
                  s = {
                    key_code = keyCodes.s;
                    modifiers = ["left_command"]; # Save
                  };

                  # Navigation (Vim-like)
                  h = keyCodes.left_arrow;
                  j = keyCodes.down_arrow;
                  k = keyCodes.up_arrow;
                  l = keyCodes.right_arrow;

                  # Word navigation
                  w = {
                    key_code = keyCodes.right_arrow;
                    modifiers = ["left_option"]; # Next word
                  };
                  b = {
                    key_code = keyCodes.left_arrow;
                    modifiers = ["left_option"]; # Previous word
                  };

                  # Line operations
                  "0" = keyCodes.home; # Beginning of line
                  "4" = keyCodes.end; # End of line ($ key)

                  # Code actions
                  r = {
                    key_code = keyCodes.f2; # Rename symbol
                  };
                  d = {
                    key_code = keyCodes.d;
                    modifiers = ["left_command"]; # Duplicate line
                  };

                  # Panel toggles
                  t = {
                    key_code = keyCodes.grave_accent_and_tilde;
                    modifiers = ["left_command"]; # Toggle terminal
                  };
                  e = {
                    key_code = keyCodes.b;
                    modifiers = ["left_command"]; # Toggle sidebar
                  };
                };

                # Terminal applications
                "com.apple.Terminal" = {
                  # Directory shortcuts
                  h = {
                    shell_command = "cd ~ && clear";
                  };
                  d = {
                    shell_command = "cd ~/Desktop && clear";
                  };
                  p = {
                    shell_command = "cd ~/projects && clear";
                  };

                  # Git shortcuts
                  g = {
                    shell_command = "git status";
                  };
                  "shift+g" = {
                    shell_command = "git log --oneline -10";
                  };
                  a = {
                    shell_command = "git add .";
                  };
                  c = {
                    shell_command = "git commit -m ";
                  };

                  # System shortcuts
                  l = {
                    shell_command = "ls -la";
                  };
                  "shift+l" = {
                    shell_command = "ls -la | grep";
                  };

                  # Process management
                  k = {
                    shell_command = "ps aux | grep";
                  };
                  "shift+k" = {
                    shell_command = "killall";
                  };
                };

                # iTerm2 (same as Terminal but different bundle ID)
                "com.googlecode.iterm2" = {
                  # Directory shortcuts
                  h = {
                    shell_command = "cd ~ && clear";
                  };
                  d = {
                    shell_command = "cd ~/Desktop && clear";
                  };
                  p = {
                    shell_command = "cd ~/projects && clear";
                  };

                  # Git shortcuts
                  g = {
                    shell_command = "git status";
                  };
                  "shift+g" = {
                    shell_command = "git log --oneline -10";
                  };
                  a = {
                    shell_command = "git add .";
                  };
                  c = {
                    shell_command = "git commit -m ";
                  };

                  # System shortcuts
                  l = {
                    shell_command = "ls -la";
                  };
                  "shift+l" = {
                    shell_command = "ls -la | grep";
                  };
                };

                # Web browsers
                "com.apple.Safari" = {
                  # Tab management
                  t = {
                    key_code = keyCodes.t;
                    modifiers = ["left_command"]; # New tab
                  };
                  w = {
                    key_code = keyCodes.w;
                    modifiers = ["left_command"]; # Close tab
                  };
                  "shift+t" = {
                    key_code = keyCodes.t;
                    modifiers = ["left_command" "left_shift"]; # Reopen closed tab
                  };

                  # Navigation
                  h = {
                    key_code = keyCodes.left_arrow;
                    modifiers = ["left_command"]; # Back
                  };
                  l = {
                    key_code = keyCodes.right_arrow;
                    modifiers = ["left_command"]; # Forward
                  };
                  r = {
                    key_code = keyCodes.r;
                    modifiers = ["left_command"]; # Reload
                  };
                  "shift+r" = {
                    key_code = keyCodes.r;
                    modifiers = ["left_command" "left_shift"]; # Hard reload
                  };

                  # Search and bookmarks
                  f = {
                    key_code = keyCodes.f;
                    modifiers = ["left_command"]; # Find
                  };
                  b = {
                    key_code = keyCodes.b;
                    modifiers = ["left_command" "left_shift"]; # Show bookmarks
                  };

                  # Developer tools
                  i = {
                    key_code = keyCodes.i;
                    modifiers = ["left_command" "left_option"]; # Web Inspector
                  };
                };

                # Google Chrome
                "com.google.Chrome" = {
                  # Same shortcuts as Safari for consistency
                  t = {
                    key_code = keyCodes.t;
                    modifiers = ["left_command"];
                  };
                  w = {
                    key_code = keyCodes.w;
                    modifiers = ["left_command"];
                  };
                  h = {
                    key_code = keyCodes.left_arrow;
                    modifiers = ["left_command"];
                  };
                  l = {
                    key_code = keyCodes.right_arrow;
                    modifiers = ["left_command"];
                  };
                  r = {
                    key_code = keyCodes.r;
                    modifiers = ["left_command"];
                  };
                  f = {
                    key_code = keyCodes.f;
                    modifiers = ["left_command"];
                  };
                  i = {
                    key_code = keyCodes.i;
                    modifiers = ["left_command" "left_option"];
                  };
                };

                # File management
                "com.apple.finder" = {
                  # View modes
                  "1" = {
                    key_code = keyCodes."1";
                    modifiers = ["left_command"]; # Icon view
                  };
                  "2" = {
                    key_code = keyCodes."2";
                    modifiers = ["left_command"]; # List view
                  };
                  "3" = {
                    key_code = keyCodes."3";
                    modifiers = ["left_command"]; # Column view
                  };
                  "4" = {
                    key_code = keyCodes."4";
                    modifiers = ["left_command"]; # Gallery view
                  };

                  # Navigation
                  h = keyCodes.left_arrow; # Go up
                  l = keyCodes.right_arrow; # Go down/open
                  j = keyCodes.down_arrow;
                  k = keyCodes.up_arrow;

                  # File operations
                  n = {
                    key_code = keyCodes.n;
                    modifiers = ["left_command" "left_shift"]; # New folder
                  };
                  d = keyCodes.delete_or_backspace; # Move to trash
                  r = keyCodes.return_or_enter; # Rename

                  # Quick navigation
                  a = {
                    key_code = keyCodes.a;
                    modifiers = ["left_command" "left_shift"]; # Applications
                  };
                  u = {
                    key_code = keyCodes.u;
                    modifiers = ["left_command" "left_shift"]; # Utilities
                  };
                };

                # Text editors
                "com.coteditor.CotEditor" = {
                  # Navigation
                  h = keyCodes.left_arrow;
                  j = keyCodes.down_arrow;
                  k = keyCodes.up_arrow;
                  l = keyCodes.right_arrow;

                  # Word navigation
                  w = {
                    key_code = keyCodes.right_arrow;
                    modifiers = ["left_option"];
                  };
                  b = {
                    key_code = keyCodes.left_arrow;
                    modifiers = ["left_option"];
                  };

                  # Line operations
                  "0" = keyCodes.home;
                  "4" = keyCodes.end;

                  # File operations
                  s = {
                    key_code = keyCodes.s;
                    modifiers = ["left_command"];
                  };
                  f = {
                    key_code = keyCodes.f;
                    modifiers = ["left_command"];
                  };
                };
              };
            })

            # Additional layer for 'i' key in development apps
            (appLayerKey {
              key = keyCodes.i;
              alone_key = keyCodes.i;
              variable_name = "dev_layer";

              app_mappings = {
                "com.jetbrains.intellij" = {
                  # IntelliJ-specific shortcuts
                  m = {
                    key_code = keyCodes.down_arrow;
                    modifiers = ["left_control" "left_shift"]; # Next method
                  };
                  "shift+m" = {
                    key_code = keyCodes.up_arrow;
                    modifiers = ["left_control" "left_shift"]; # Previous method
                  };
                  r = keyCodes.f2; # Rename
                  f = {
                    key_code = keyCodes.f;
                    modifiers = ["left_command" "left_shift"]; # Find in files
                  };
                  g = {
                    key_code = keyCodes.g;
                    modifiers = ["left_command"]; # Go to line
                  };
                  b = {
                    key_code = keyCodes.f8;
                    modifiers = ["fn" "left_command"]; # Toggle breakpoint
                  };
                };

                "com.apple.dt.Xcode" = {
                  # Xcode-specific shortcuts
                  r = {
                    key_code = keyCodes.r;
                    modifiers = ["left_command"]; # Run
                  };
                  b = {
                    key_code = keyCodes.b;
                    modifiers = ["left_command"]; # Build
                  };
                  f = {
                    key_code = keyCodes.f;
                    modifiers = ["left_command" "left_shift"]; # Find in project
                  };
                  j = {
                    key_code = keyCodes.j;
                    modifiers = ["left_command" "left_shift"]; # Jump to definition
                  };
                };
              };
            })
          ];
        };
      })
    ];
  }
