# Example demonstrating per-application layers
# This shows how to create different layer mappings for different applications
{ lib, ... }:

let
  karabinix = import ../lib { inherit lib; };
  inherit (karabinix) appLayerKey keyCodes;
in

{
  # Example 1: Spacebar activates different layers per app
  spacebarPerAppExample = appLayerKey {
    key = keyCodes.spacebar;
    alone_key = keyCodes.spacebar;
    variable_name = "spacebar_app_layer";
    app_mappings = {
    # VS Code - Development shortcuts
    "com.microsoft.VSCode" = {
      # File operations
      f = keyCodes.f; # Find
      r = keyCodes.r; # Replace
      g = keyCodes.g; # Go to line
      
      # Navigation
      h = keyCodes.left_arrow;
      j = keyCodes.down_arrow;
      k = keyCodes.up_arrow;
      l = keyCodes.right_arrow;
      
      # Code actions
      "shift+r" = {
        key_code = keyCodes.f2; # Rename symbol
      };
      "ctrl+d" = {
        key_code = keyCodes.d;
        modifiers = ["left_command"]; # Duplicate line
      };
    };

    # Terminal - Terminal-specific shortcuts
    "com.apple.Terminal" = {
      # Directory navigation
      h = {
        shell_command = "cd ~";
      };
      d = {
        shell_command = "cd ~/Desktop";
      };
      p = {
        shell_command = "cd ~/projects";
      };
      
      # Common commands
      l = {
        shell_command = "ls -la";
      };
      g = {
        shell_command = "git status";
      };
      "shift+g" = {
        shell_command = "git log --oneline -10";
      };
    };

    # Safari - Web browsing shortcuts
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
      
      # Bookmarks and search
      b = {
        key_code = keyCodes.b;
        modifiers = ["left_command" "left_shift"]; # Show bookmarks
      };
      f = {
        key_code = keyCodes.f;
        modifiers = ["left_command"]; # Find
      };
    };

    # Finder - File management
    "com.apple.finder" = {
      # View options
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
      
      # Navigation
      h = keyCodes.left_arrow; # Go up in hierarchy
      l = keyCodes.right_arrow; # Go down/open
      j = keyCodes.down_arrow;
      k = keyCodes.up_arrow;
      
      # Quick actions
      n = {
        key_code = keyCodes.n;
        modifiers = ["left_command" "left_shift"]; # New folder
      };
      d = {
        key_code = keyCodes.delete_or_backspace; # Move to trash
      };
    };
    };
  };

  # Example 2: Custom key for per-app layers (using 'i' key)
  customKeyPerAppExample = appLayerKey {
    key = keyCodes.i;
    alone_key = keyCodes.i; # Still types 'i' when pressed alone
    variable_name = "i_app_layer";
    
    app_mappings = {
      # IntelliJ IDEA - IDE shortcuts
      "com.jetbrains.intellij" = {
        # Code navigation
        m = {
          key_code = keyCodes.down_arrow;
          modifiers = ["left_control" "left_shift"]; # Next method
        };
        "shift+m" = {
          key_code = keyCodes.up_arrow;
          modifiers = ["left_control" "left_shift"]; # Previous method
        };
        
        # Refactoring
        r = keyCodes.f2; # Rename
        e = {
          key_code = keyCodes.f12;
          modifiers = ["fn" "left_command"]; # File structure
        };
        
        # Debugging
        b = {
          key_code = keyCodes.f8;
          modifiers = ["fn" "left_command"]; # Toggle breakpoint
        };
        d = keyCodes.f7; # Step into
        o = keyCodes.f8; # Step over
      };

      # Xcode - iOS development
      "com.apple.dt.Xcode" = {
        # Build and run
        r = {
          key_code = keyCodes.r;
          modifiers = ["left_command"]; # Run
        };
        b = {
          key_code = keyCodes.b;
          modifiers = ["left_command"]; # Build
        };
        
        # Navigation
        j = {
          key_code = keyCodes.j;
          modifiers = ["left_command" "left_shift"]; # Jump to definition
        };
        f = {
          key_code = keyCodes.f;
          modifiers = ["left_command" "left_shift"]; # Find in project
        };
        
        # Interface Builder
        "shift+i" = {
          key_code = keyCodes.return_or_enter;
          modifiers = ["left_option" "left_command"]; # Show assistant editor
        };
      };

      # Photoshop - Creative shortcuts
      "com.adobe.Photoshop" = {
        # Tools
        v = keyCodes.v; # Move tool
        b = keyCodes.b; # Brush tool
        e = keyCodes.e; # Eraser tool
        t = keyCodes.t; # Type tool
        
        # Layers
        "shift+n" = {
          key_code = keyCodes.n;
          modifiers = ["left_command" "left_shift"]; # New layer
        };
        "shift+d" = {
          key_code = keyCodes.j;
          modifiers = ["left_command"]; # Duplicate layer
        };
        
        # View
        "0" = {
          key_code = keyCodes."0";
          modifiers = ["left_command"]; # Fit to screen
        };
        "1" = {
          key_code = keyCodes."1";
          modifiers = ["left_command"]; # 100% zoom
        };
      };
    };
  };

  # Example 3: Multiple apps with similar bundle IDs
  jetbrainsAppsExample = appLayerKey {
    key = keyCodes.j;
    alone_key = keyCodes.j;
    variable_name = "jetbrains_layer";
    
    app_mappings = {
      # Works for any JetBrains IDE
      "com.jetbrains.intellij" = {
        r = keyCodes.f2; # Rename
        f = {
          key_code = keyCodes.f;
          modifiers = ["left_command" "left_shift"]; # Find in files
        };
        g = {
          key_code = keyCodes.g;
          modifiers = ["left_command"]; # Go to line
        };
      };
      
      "com.jetbrains.pycharm" = {
        r = keyCodes.f2; # Rename
        f = {
          key_code = keyCodes.f;
          modifiers = ["left_command" "left_shift"]; # Find in files
        };
        g = {
          key_code = keyCodes.g;
          modifiers = ["left_command"]; # Go to line
        };
        # Python-specific
        p = {
          key_code = keyCodes.f9;
          modifiers = ["left_control"]; # Run Python console
        };
      };
      
      "com.jetbrains.webstorm" = {
        r = keyCodes.f2; # Rename
        f = {
          key_code = keyCodes.f;
          modifiers = ["left_command" "left_shift"]; # Find in files
        };
        g = {
          key_code = keyCodes.g;
          modifiers = ["left_command"]; # Go to line
        };
        # Web-specific
        s = {
          key_code = keyCodes.s;
          modifiers = ["left_command" "left_option"]; # Start dev server
        };
      };
    };
  };
}
