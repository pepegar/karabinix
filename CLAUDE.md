# Karabinix - Claude Development Guide

## Project Overview

Karabinix is a Nix utility for generating [Karabiner Elements](https://karabiner-elements.pqrs.org/) configurations using a declarative DSL. It provides a composable, reproducible way to configure keyboard customizations on macOS.

**Key Features:**
- Declarative keyboard configuration using Nix
- Home Manager integration
- Rich DSL with high-level functions for complex modifications
- Debugging support with optional notifications
- Template system for quick setup
- Composable functions for common patterns (hyper keys, layers, vim navigation)

## Architecture

### Core Components

- **`lib/`** - Main library with configuration generation functions
  - `default.nix` - Main exports and function aggregation
  - `config.nix` - Core configuration generation (`mkConfiguration`)
  - `rules.nix` - Rule creation functions (`mkRule`, `mkManipulator`, etc.)
  - `utils.nix` - Utility functions (hyperKey, layerKey, vimNavigation, etc.)
  - `types.nix` - Nix type definitions
  - `keycodes.nix` - Karabiner key code constants

- **`modules/`** - Home Manager integration
  - `home-manager.nix` - Home Manager module for seamless configuration management

- **`examples/`** - Configuration examples demonstrating various features
- **`templates/`** - Nix flake templates for quick project setup
- **`docs/`** - Additional documentation for specific features

### Key Functions

**Configuration Creation:**
- `mkConfiguration` - Creates complete Karabiner configuration
- `mkProfile` - Creates configuration profiles
- `mkRule` - Creates complex modification rules

**Utility Functions:**
- `mapKey` - Simple key-to-key mapping
- `hyperKey` - Creates hyper key with multiple mappings
- `layerKey` - Creates layer activation key
- `simultaneousKeys` - Maps simultaneous key presses
- `vimNavigation` - Pre-built Vim-style navigation layer
- `homeRowMods` - Home row modifier key configurations

**Conditions:**
- `appCondition` - Restrict rules to specific applications
- `deviceCondition` - Restrict rules to specific devices

## Tech Stack

- **Language:** Nix
- **Target:** Karabiner Elements (macOS keyboard customization tool)
- **Integration:** Home Manager, Nix Flakes
- **Development Tools:** alejandra (formatter), nil (LSP), deadnix (dead code detection)

## Development Workflow

### Building and Testing

```bash
# Enter development shell
nix develop

# Format code
alejandra .

# Check for issues
deadnix
```

### Common Development Tasks

1. **Adding new utility functions** - Add to `lib/utils.nix` and export in `lib/default.nix`
2. **Modifying configuration generation** - Edit `lib/config.nix` or `lib/rules.nix`  
3. **Adding examples** - Create new files in `examples/` directory
4. **Home Manager changes** - Modify `modules/home-manager.nix`

### Code Patterns

The codebase follows functional programming patterns typical in Nix:
- Functions take attribute sets as parameters
- Heavy use of `lib` utilities (`mapAttrsToList`, `optionalAttrs`, etc.)
- Type checking through Nix type system
- Composable function design

### Testing Configuration

Test generated configurations by:
1. Using the examples in `examples/` directory
2. Running `nix flake show` to verify flake structure
3. Testing home-manager integration with templates

## Integration Points

### Home Manager Module

The home-manager module (`modules/home-manager.nix`) provides:
- `services.karabinix.enable` - Enable karabinix configuration management
- `services.karabinix.configuration` - Karabinix DSL configuration
- `services.karabinix.installPackage` - Optional Karabiner Elements installation
- `karabinix-reload` script for configuration reloading

### Flake Structure

- **`lib`** - Library functions available across systems
- **`homeManagerModules`** - Home Manager integration
- **`templates`** - Project templates (default, advanced)
- **`devShells`** - Development environment
- **`formatter`** - Code formatting (alejandra)

## Debugging Features

Karabinix includes optional notification support for debugging:
- `enable_debug` parameter on layer functions
- `showNotification` and `hideNotification` utilities  
- Debug notifications are **disabled by default** for production use

## Important Notes

- All debugging features are disabled by default to ensure clean configurations
- The project focuses on macOS/Karabiner Elements specifically
- Home Manager integration is optional - can be used standalone
- Configuration is generated as JSON for Karabiner Elements consumption