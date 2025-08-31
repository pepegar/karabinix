# Sublayer System

The sublayer system in karabinix allows you to create hierarchical keyboard shortcuts similar to mxstbr's Karabiner configuration. This enables complex, organized shortcuts using a pattern like:

**Hyper Key + Sublayer Key + Action Key**

For example: `Caps Lock + o + w` (window left half) or `Caps Lock + b + t` (open Twitter).

## How It Works

The sublayer system works by:

1. **Hyper Key Activation**: A key (like Caps Lock) becomes your "hyper" key
2. **Sublayer Selection**: While holding hyper, press a sublayer key (like `o` for "open" or `b` for "browse")  
3. **Action Execution**: While holding both, press an action key to execute the command

This is **sequential**, not a chord - you hold the keys in sequence, not all at once.

## Key Flow Example

```
Hold Caps Lock → hyper = 1
Hold 'o' (while holding Caps Lock) → hyper_sublayer_o = 1  
Press 'w' (while holding both) → Execute "left half window"
Release keys → variables reset to 0
```

## Basic Usage

```nix
{karabinix}:
with karabinix.lib;
  mkConfiguration {
    profiles = [
      (mkProfile {
        name = "My Sublayers";
        selected = true;

        complex_modifications = mkComplexModification {
          rules = [
            (sublayerKey {
              key = keyCodes.caps_lock;     # The hyper key
              alone_key = keyCodes.escape;  # What to send if pressed alone
              
              sublayers = {
                # Window management sublayer
                "o" = {
                  "w" = raycastWindow "left-half";
                  "e" = raycastWindow "right-half";
                  "f" = raycastWindow "maximize";
                };

                # Browser shortcuts sublayer  
                "b" = {
                  "t" = { shell_command = "open https://twitter.com"; };
                  "g" = { shell_command = "open https://github.com"; };
                };
              };
            })
          ];
        };
      })
    ];
  }
```

## Configuration Options

### `sublayerKey` Function

```nix
sublayerKey = {
  key,                           # The main hyper key (e.g., "caps_lock")
  alone_key ? "escape",          # What to send if pressed alone
  variable_name ? "hyper",       # Base variable name for the hyper key
  sublayers                      # Nested sublayers: { "o" = { "w" = action; }; }
}
```

#### Parameters

- **`key`** (required): The key that acts as your hyper key (e.g., `keyCodes.caps_lock`)
- **`alone_key`** (optional): What key to send if the hyper key is pressed alone (default: `"escape"`)
- **`variable_name`** (optional): Base name for internal variables (default: `"hyper"`)
- **`sublayers`** (required): Nested attribute set defining your sublayers and actions

### Action Types

Actions in sublayers can be:

1. **Key codes**: Simple string key codes
   ```nix
   "w" = "left_arrow";
   ```

2. **Key sequences**: Lists of key codes
   ```nix
   "w" = ["left_command" "left_arrow"];
   ```

3. **Shell commands**: Attribute sets with shell_command
   ```nix
   "t" = { shell_command = "open https://twitter.com"; };
   ```

4. **Raycast actions**: Using the raycastWindow helper
   ```nix
   "w" = raycastWindow "left-half";
   ```

## Complete Example

Here's a comprehensive example similar to mxstbr's configuration:

```nix
(sublayerKey {
  key = keyCodes.caps_lock;
  alone_key = keyCodes.escape;
  
  sublayers = {
    # Window management (o for "open")
    "o" = {
      "w" = raycastWindow "left-half";
      "e" = raycastWindow "right-half";
      "r" = raycastWindow "top-half";
      "s" = raycastWindow "bottom-half";
      "f" = raycastWindow "maximize";
      "c" = raycastWindow "center";
    };

    # Browser/bookmarks (b for "browse")
    "b" = {
      "t" = { shell_command = "open https://twitter.com"; };
      "f" = { shell_command = "open https://facebook.com"; };
      "r" = { shell_command = "open https://reddit.com"; };
      "y" = { shell_command = "open https://news.ycombinator.com"; };
      "g" = { shell_command = "open https://github.com"; };
    };

    # Work applications (w for "work")
    "w" = {
      "s" = { shell_command = "open -a 'Slack'"; };
      "d" = { shell_command = "open -a 'Discord'"; };
      "c" = { shell_command = "open -a 'Visual Studio Code'"; };
      "t" = { shell_command = "open -a 'Terminal'"; };
    };

    # System controls (s for "system")
    "s" = {
      "l" = { shell_command = "pmset displaysleepnow"; };  # Lock screen
      "s" = { shell_command = "pmset sleepnow"; };         # Sleep
      "v" = { key_code = keyCodes.volume_up; };
      "c" = { key_code = keyCodes.volume_down; };
      "m" = { key_code = keyCodes.mute; };
    };

    # Raycast extensions (r for "raycast")
    "r" = {
      "c" = { shell_command = "open raycast://extensions/raycast/clipboard-history/clipboard-history"; };
      "e" = { shell_command = "open raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"; };
      "s" = { shell_command = "open raycast://extensions/raycast/snippets/search-snippets"; };
      "a" = { shell_command = "open raycast://extensions/raycast/raycast-ai/ai-chat"; };
    };
  };
})
```

## Tips and Best Practices

1. **Mnemonic Keys**: Use memorable sublayer keys:
   - `o` for "open" (window management)
   - `b` for "browse" (websites)
   - `w` for "work" (applications)
   - `s` for "system" (controls)
   - `r` for "raycast" (extensions)

2. **Consistent Action Keys**: Use consistent action keys across sublayers:
   - `w` for "west/left"
   - `e` for "east/right"  
   - `r` for "raise/up"
   - `s` for "sink/down"
   - `f` for "fullscreen"
   - `c` for "center"

3. **Logical Grouping**: Group related actions in the same sublayer

4. **Avoid Conflicts**: Make sure sublayer keys don't conflict with common action keys

## Comparison with Regular Layers

| Feature | Regular `layerKey` | `sublayerKey` |
|---------|-------------------|---------------|
| Pattern | Hold + Action | Hold + Sublayer + Action |
| Complexity | Simple | Hierarchical |
| Organization | Flat | Nested |
| Scalability | Limited | High |
| Memory | Easier | Requires more planning |

## Examples

See the following example files:
- `examples/simple-sublayers.nix` - Basic sublayer usage
- `examples/sublayers-mxstbr-style.nix` - Comprehensive mxstbr-style configuration
