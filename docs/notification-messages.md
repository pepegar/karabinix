# Notification Messages

Karabinix supports Karabiner-Elements' notification message feature, which allows you to display temporary messages on screen when keys are pressed. This is particularly useful for debugging layer activations, understanding key behavior, and providing visual feedback during development.

## Overview

Notification messages appear as small pop-up messages on your screen that can be shown and hidden programmatically. They're ideal for:

- **Debugging**: Understanding when layers are activated/deactivated
- **Learning**: Seeing which keys are being triggered
- **Development**: Getting immediate feedback when testing configurations
- **Troubleshooting**: Identifying why certain key combinations aren't working

## Basic Usage

### Low-level API

The core functionality is provided through the `set_notification_message` field in `toEvent`:

```nix
# Show a notification
rules.mkToEvent {
  set_notification_message = {
    id = "my_notification";
    text = "Hello World!";
  };
}

# Hide a notification (set text to empty string)
rules.mkToEvent {
  set_notification_message = {
    id = "my_notification";
    text = "";
  };
}
```

### High-level Utilities

Karabinix provides convenient utility functions:

```nix
# Show a notification
utils.showNotification "notification_id" "Message text"

# Hide a notification
utils.hideNotification "notification_id"

# Create a notification event
utils.mkNotification {
  id = "notification_id";
  text = "Message text";
}
```

## Debug Functions

### Debug Key

Wrap any key with debugging notifications (disabled by default):

```nix
utils.debugKey {
  key = "caps_lock";
  action = rules.mkToEvent { key_code = "escape"; };
  notification_text = "Caps Lock -> Escape";
  enable_debug = false; # Set to true to enable
}
```

### Debug Layer Key

Add debugging to layer keys to see when they're activated:

```nix
utils.debugLayerKey {
  key = "spacebar";
  layer_name = "Navigation";
  enable_debug = false; # Set to true to enable
  mappings = {
    h = keyCodes.left_arrow;
    j = keyCodes.down_arrow;
    k = keyCodes.up_arrow;
    l = keyCodes.right_arrow;
  };
}
```

## Configuration Philosophy

All debugging features are **disabled by default** to ensure:

- Clean, production-ready configurations out of the box
- No unwanted notifications in daily use
- Easy toggling for development/debugging
- Minimal performance impact when disabled

To enable debugging, explicitly set `enable_debug = true` in your configuration.

## Example Use Cases

### 1. Debugging Layer Activation

```nix
# Enable debugging for a specific layer
utils.debugLayerKey {
  key = "tab";
  layer_name = "Window Management";
  enable_debug = true; # Enable to see layer state
  mappings = {
    "1" = utils.raycastWindow "left-half";
    "2" = utils.raycastWindow "right-half";
  };
}
```

### 2. Understanding Key Behavior

```nix
# Debug individual keys to understand their behavior
utils.debugKey {
  key = "right_command";
  notification_text = "Right Cmd pressed";
  enable_debug = true; # Enable for debugging
}
```

### 3. Manual Notification Control

```nix
# Toggle persistent notifications for status indication
rules.mkManipulator {
  from = rules.mkFromEvent {
    key_code = "f10";
    modifiers = rules.mkModifiers { mandatory = ["left_command"]; };
  };
  to = [
    (utils.showNotification "status" "Debug mode active")
  ];
  description = "Show debug status";
}
```

### 4. Temporary Feedback

```nix
# Show notifications only while key is held
rules.mkManipulator {
  from = rules.mkFromEvent { key_code = "spacebar"; };
  to = [
    (utils.showNotification "space_info" "Space layer active")
    (rules.mkToEvent { set_variable = { name = "space_layer"; value = 1; }; })
  ];
  to_after_key_up = [
    (utils.hideNotification "space_info")
    (rules.mkToEvent { set_variable = { name = "space_layer"; value = 0; }; })
  ];
  description = "Space layer with feedback";
}
```

## Best Practices

### 1. Use Descriptive IDs
```nix
# Good: descriptive and unique
utils.showNotification "layer_navigation_active" "Nav layer active"

# Avoid: generic and potentially conflicting
utils.showNotification "msg" "Active"
```

### 2. Keep Messages Short
Notifications have limited screen space, so keep messages concise:

```nix
# Good: short and clear
"Nav layer active"
"Caps -> Esc"

# Avoid: too verbose
"Navigation layer has been activated and is now ready for use"
```

### 3. Always Clean Up
Always hide notifications when they're no longer needed:

```nix
to_after_key_up = [
  (utils.hideNotification "my_notification")
];
```

### 4. Use Conditional Debugging
Structure your code to easily toggle debugging:

```nix
let
  debug_enabled = false; # Change to true for debugging
in
utils.debugLayerKey {
  # ... layer configuration ...
  enable_debug = debug_enabled;
}
```

## Technical Details

### Notification Lifecycle

1. **Show**: Call `showNotification` with an ID and text
2. **Update**: Call `showNotification` again with the same ID and new text
3. **Hide**: Call `hideNotification` with the ID, or use empty text

### Performance Considerations

- Notifications are lightweight and don't impact performance significantly
- When debugging is disabled, functions return regular manipulators with no notification overhead
- Multiple notifications can be active simultaneously with different IDs

### Limitations

- Notification positioning is controlled by Karabiner-Elements
- Styling options are limited to what Karabiner-Elements provides
- Messages should be kept short due to display constraints

## Related Documentation

- [Karabiner-Elements notification documentation](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/set-notification-message/)
- [karabinix layer documentation](per-app-layers.md)
- [karabinix sublayer documentation](sublayers.md)
