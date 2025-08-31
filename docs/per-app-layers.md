# Per-Application Layers

Karabinix now supports per-application layers, allowing you to have different key mappings activated by the same layer key depending on which application is currently in the foreground.

## Overview

Per-application layers work by combining:
- A layer activation key (like spacebar)
- Application-specific conditions using bundle identifiers
- Different mappings for each application

When you hold the layer key, different mappings become active depending on which app is frontmost.

## Functions

### `appLayerKey`

Creates a layer key with different mappings per application.

```nix
appLayerKey {
  key = keyCodes.spacebar;
  alone_key = keyCodes.spacebar;  # Optional: what to do when pressed alone
  variable_name = "my_app_layer"; # Optional: custom variable name
  app_mappings = {
    "com.microsoft.VSCode" = {
      f = keyCodes.p;  # 'f' maps to 'p' in VS Code
      # ... more mappings
    };
    "com.apple.Terminal" = {
      f = { shell_command = "ls -la"; };  # 'f' runs command in Terminal
      # ... more mappings
    };
  };
}
```



## Finding Application Bundle Identifiers

To use per-app layers, you need to know the bundle identifier for each application:

### Method 1: Using `osascript`
```bash
osascript -e 'id of app "Application Name"'
```

### Method 2: Using `mdls`
```bash
mdls -name kMDItemCFBundleIdentifier -r /Applications/AppName.app
```

### Method 3: Activity Monitor
1. Open Activity Monitor
2. Find your application
3. Double-click it and look at the "Bundle Identifier" field

## Common Bundle Identifiers

| Application | Bundle Identifier |
|-------------|------------------|
| VS Code | `com.microsoft.VSCode` |
| Terminal | `com.apple.Terminal` |
| iTerm2 | `com.googlecode.iterm2` |
| Safari | `com.apple.Safari` |
| Chrome | `com.google.Chrome` |
| Finder | `com.apple.finder` |
| IntelliJ IDEA | `com.jetbrains.intellij` |
| Xcode | `com.apple.dt.Xcode` |

## Examples

### Basic Spacebar Layer

```nix
appLayerKey {
  key = keyCodes.spacebar;
  alone_key = keyCodes.spacebar;
  variable_name = "spacebar_app_layer";
  app_mappings = {
  # VS Code - Development shortcuts
  "com.microsoft.VSCode" = {
    f = { key_code = keyCodes.p; modifiers = ["left_command"]; }; # Quick open
    s = { key_code = keyCodes.s; modifiers = ["left_command"]; }; # Save
    h = keyCodes.left_arrow;  # Vim-like navigation
    j = keyCodes.down_arrow;
    k = keyCodes.up_arrow;
    l = keyCodes.right_arrow;
  };
  
  # Terminal - System shortcuts
  "com.apple.Terminal" = {
    h = { shell_command = "cd ~"; };
    l = { shell_command = "ls -la"; };
    g = { shell_command = "git status"; };
  };
  
  # Safari - Web browsing
  "com.apple.Safari" = {
    t = { key_code = keyCodes.t; modifiers = ["left_command"]; }; # New tab
    w = { key_code = keyCodes.w; modifiers = ["left_command"]; }; # Close tab
    r = { key_code = keyCodes.r; modifiers = ["left_command"]; }; # Reload
  };
  };
}
```

### Custom Layer Key

```nix
appLayerKey {
  key = keyCodes.i;
  alone_key = keyCodes.i;  # Still types 'i' when alone
  variable_name = "ide_layer";
  
  app_mappings = {
    "com.jetbrains.intellij" = {
      r = keyCodes.f2;  # Rename
      f = { key_code = keyCodes.f; modifiers = ["left_command" "left_shift"]; }; # Find in files
      b = { key_code = keyCodes.f8; modifiers = ["fn" "left_command"]; }; # Toggle breakpoint
    };
    
    "com.apple.dt.Xcode" = {
      r = { key_code = keyCodes.r; modifiers = ["left_command"]; }; # Run
      b = { key_code = keyCodes.b; modifiers = ["left_command"]; }; # Build
    };
  };
}
```

### Modifier Support

You can use modifiers in your trigger keys:

```nix
appLayerKey {
  key = keyCodes.spacebar;
  alone_key = keyCodes.spacebar;
  variable_name = "spacebar_app_layer";
  app_mappings = {
  "com.microsoft.VSCode" = {
    m = keyCodes.down_arrow;        # Regular 'm'
    "shift+m" = keyCodes.up_arrow;  # Shift+M
    "ctrl+d" = { key_code = keyCodes.d; modifiers = ["left_command"]; };
  };
  };
}
```

## Integration with Full Configuration

```nix
{ lib, ... }:

let
  karabinix = import ./path/to/karabinix/lib { inherit lib; };
  inherit (karabinix) mkConfiguration mkProfile mkComplexModification appLayerKey keyCodes;
in

mkConfiguration {
  profiles = [
    (mkProfile {
      name = "My Per-App Profile";
      selected = true;
      
      complex_modifications = mkComplexModification {
        rules = [
          # Your per-app layer
          (appLayerKey {
            key = keyCodes.spacebar;
            alone_key = keyCodes.spacebar;
            variable_name = "spacebar_app_layer";
            app_mappings = {
            "com.microsoft.VSCode" = {
              # VS Code mappings
            };
            "com.apple.Terminal" = {
              # Terminal mappings
            };
            };
          })
          
          # Other rules...
        ];
      };
    })
  ];
}
```

## Tips

1. **Test with one app first**: Start with mappings for just one application to make sure everything works.

2. **Use consistent mappings**: Try to use similar key mappings across apps for muscle memory.

3. **Fallback behavior**: The layer key can still have its normal behavior when pressed alone by setting `alone_key`.

4. **Multiple layers**: You can have multiple per-app layers using different activation keys.

5. **Shell commands**: Use shell commands for complex actions, especially in terminal applications.

6. **Bundle ID verification**: Always verify bundle identifiers are correct - a typo will prevent the layer from working.
