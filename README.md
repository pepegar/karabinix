# Karabinix 🎹

A Nix utility for generating [Karabiner Elements](https://karabiner-elements.pqrs.org/) configurations using a declarative DSL.

Inspired by [@mxstbr's TypeScript-based Karabiner configuration](https://github.com/mxstbr/karabiner), but built with Nix for reproducible, composable keyboard customizations.

## ✨ Features

- **Declarative Configuration**: Define your keyboard layout using Nix expressions
- **Composable**: Reusable functions for common patterns (hyper keys, layers, vim navigation)
- **Home Manager Integration**: Seamless integration with home-manager
- **Rich DSL**: High-level functions for complex modifications, simultaneous keys, and more
- **Template System**: Get started quickly with pre-built templates

## 🚀 Quick Start

### Using with Home Manager (Recommended)

1. Add karabinix to your flake inputs:

```nix
{
  description = "My Home Manager configuration";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    karabinix.url = "github:pepegar/karabinix";
  };

  outputs = { nixpkgs, home-manager, karabinix, ... }: {
    homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-darwin; # or aarch64-darwin
      modules = [
        karabinix.homeManagerModules.karabinix
        {
          services.karabinix = {
            enable = true;
            
            # Optional: Install Karabiner Elements via Nix (default: false)
            # installPackage = true;
            # package = pkgs.karabiner-elements;
            
            configuration = with karabinix.lib; {
              profiles = [
                (mkProfile {
                  name = "My Profile";
                  selected = true;
                  
                  simple_modifications = [
                    (mapKey keyCodes.caps_lock keyCodes.left_control)
                  ];
                  
                  complex_modifications = mkComplexModification {
                    rules = [
                      (vimNavigation { layer_key = keyCodes.caps_lock; })
                    ];
                  };
                })
              ];
            };
          };
        }
      ];
    };
  };
}
```

2. Apply the configuration:

```bash
home-manager switch --flake .#your-username
```

### Using Templates

Create a new configuration from a template:

```bash
nix flake init -t github:pepegar/karabinix#default
# or for advanced features:
nix flake init -t github:pepegar/karabinix#advanced
```

### Standalone Usage

```nix
{
  inputs.karabinix.url = "github:pepegar/karabinix";
  
  outputs = { karabinix, ... }: {
    packages.x86_64-darwin.karabiner-config = 
      pkgs.writeText "karabiner.json" (
        karabinix.lib.mkConfiguration {
          profiles = [ /* your config */ ];
        }
      );
  };
}
```

## 📚 API Documentation

### Core Functions

#### `mkConfiguration`
Creates a complete Karabiner Elements configuration.

```nix
mkConfiguration {
  global = { /* global settings */ };
  profiles = [ /* list of profiles */ ];
}
```

#### `mkProfile`
Creates a configuration profile.

```nix
mkProfile {
  name = "Profile Name";
  selected = true;
  simple_modifications = [ /* simple key mappings */ ];
  complex_modifications = { /* complex rules */ };
}
```

#### `mkRule`
Creates a complex modification rule.

```nix
mkRule "Rule Description" [
  # list of manipulators
]
```

### Utility Functions

#### `mapKey`
Simple key-to-key mapping.

```nix
mapKey keyCodes.caps_lock keyCodes.left_control
```

#### `hyperKey`
Creates a hyper key that triggers different actions based on what key is pressed while holding it.

```nix
hyperKey {
  key = keyCodes.spacebar;
  alone_key = keyCodes.spacebar;  # What to do when pressed alone
  mappings = {
    h = keyCodes.left_arrow;
    j = keyCodes.down_arrow;
    k = keyCodes.up_arrow;
    l = keyCodes.right_arrow;
  };
}
```

#### `layerKey`
Creates a layer key that activates a set of mappings when held.

```nix
layerKey {
  key = keyCodes.semicolon;
  variable_name = "symbol_layer";
  mappings = {
    q = keyCodes."1";
    w = keyCodes."2";
    # ... more mappings
  };
}
```

#### `simultaneousKeys`
Maps simultaneous key presses to actions.

```nix
simultaneousKeys [ keyCodes.j keyCodes.k ] keyCodes.escape
```

#### `vimNavigation`
Pre-built Vim-style navigation layer.

```nix
vimNavigation {
  layer_key = keyCodes.caps_lock;
  variable_name = "vim_mode";
}
```

### Conditions

#### `appCondition`
Restrict rules to specific applications.

```nix
appCondition [ "com.apple.Terminal" "com.googlecode.iterm2" ] "frontmost_application_if"
```

#### `deviceCondition`
Restrict rules to specific devices.

```nix
deviceCondition {
  vendor_id = 1452;
  product_id = 627;
  is_keyboard = true;
}
```

### Key Codes

All Karabiner key codes are available in `keyCodes`:

```nix
keyCodes.a              # Letter keys
keyCodes."1"            # Number keys  
keyCodes.f1             # Function keys
keyCodes.left_arrow     # Arrow keys
keyCodes.spacebar       # Special keys
keyCodes.left_command   # Modifier keys
```

### Modifiers

Common modifier combinations:

```nix
modifiers.cmd    # [ "left_command" ]
modifiers.shift  # [ "left_shift" ]
modifiers.alt    # [ "left_option" ]
modifiers.ctrl   # [ "left_control" ]
modifiers.hyper  # [ "left_command" "left_control" "left_option" "left_shift" ]
modifiers.meh    # [ "left_control" "left_option" "left_shift" ]
```

## 🎯 Common Patterns

### Caps Lock as Control and Vim Navigation

```nix
complex_modifications = mkComplexModification {
  rules = [
    (vimNavigation { layer_key = keyCodes.caps_lock; })
  ];
};
```

### Hyper Key for Window Management

```nix
(hyperKey {
  key = keyCodes.spacebar;
  alone_key = keyCodes.spacebar;
  mappings = {
    h = mkToEvent { shell_command = "yabai -m window --focus west"; };
    j = mkToEvent { shell_command = "yabai -m window --focus south"; };
    k = mkToEvent { shell_command = "yabai -m window --focus north"; };
    l = mkToEvent { shell_command = "yabai -m window --focus east"; };
  };
})
```

### Application-Specific Shortcuts

```nix
(mkRule "Terminal Shortcuts" [
  (mkManipulator {
    from = mkFromEvent {
      key_code = keyCodes.n;
      modifiers = mkModifiers { mandatory = [ "left_command" ]; };
    };
    to = [
      (mkToEvent {
        key_code = keyCodes.t;
        modifiers = [ "left_command" ];
      })
    ];
    conditions = [
      (appCondition [ "com.apple.Terminal" ] "frontmost_application_if")
    ];
    description = "Cmd+N -> Cmd+T in Terminal";
  })
])
```

### Text Snippets

```nix
(mkManipulator {
  from = mkFromEvent {
    key_code = keyCodes.e;
    modifiers = mkModifiers {
      mandatory = [ "left_command" "left_shift" ];
    };
  };
  to = [
    (mkToEvent { 
      shell_command = "echo 'your.email@example.com' | pbcopy"; 
    })
  ];
  description = "Cmd+Shift+E -> Email to clipboard";
})
```

## 🔧 Advanced Configuration

### Custom Parameters

```nix
complex_modifications = mkComplexModification {
  parameters = {
    "basic.simultaneous_threshold_milliseconds" = 30;
    "basic.to_if_alone_timeout_milliseconds" = 500;
    "basic.to_if_held_down_threshold_milliseconds" = 200;
  };
  rules = [ /* your rules */ ];
};
```

### Multiple Profiles

```nix
profiles = [
  (mkProfile {
    name = "Work";
    selected = true;
    # work-specific configuration
  })
  (mkProfile {
    name = "Gaming";
    selected = false;
    # gaming-specific configuration
  })
];
```

### Device-Specific Settings

```nix
devices = [
  {
    identifiers = {
      vendor_id = 1452;
      product_id = 627;
      is_keyboard = true;
      is_pointing_device = false;
    };
    ignore = false;
    simple_modifications = [
      # device-specific mappings
    ];
  }
];
```

## 🏠 Home Manager Integration

The home-manager module provides additional features:

- Automatic configuration file management
- Optional Karabiner Elements package installation
- Configuration reload script (`karabinix-reload`)

### Package Installation Options

By default, karabinix only manages the configuration file. You have several options for installing Karabiner Elements:

**Option 1: Install via Homebrew (Recommended for macOS)**
```bash
brew install --cask karabiner-elements
```

**Option 2: Install via Nix (through karabinix)**
```nix
services.karabinix = {
  enable = true;
  installPackage = true;
  package = pkgs.karabiner-elements;
  configuration = { /* your config */ };
};
```

**Option 3: Install separately via home-manager**
```nix
services.karabinix = {
  enable = true;
  configuration = { /* your config */ };
};

home.packages = [ pkgs.karabiner-elements ];
```

## 🛠️ Development

### Building from Source

```bash
git clone https://github.com/pepegar/karabinix
cd karabinix
nix develop
```

## 📖 Examples

Check out the [examples directory](./examples/) for complete configuration examples:

- [`basic.nix`](./examples/basic.nix) - Simple key remappings and basic modifications
- [`advanced.nix`](./examples/advanced.nix) - Complex modifications, hyper keys, and layers
- [`home-manager.nix`](./examples/home-manager.nix) - Home Manager integration example

## 🤝 Acknowledgments

- [@mxstbr](https://github.com/mxstbr) for the original TypeScript-based approach
- [Karabiner Elements](https://karabiner-elements.pqrs.org/) for the amazing keyboard customization tool
- The Nix community for the powerful configuration management system
