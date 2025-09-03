{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.karabinix;
  karabinixLib = import ../lib {inherit lib;};
in {
  options.services.karabinix = {
    enable = mkEnableOption "Karabinix Karabiner Elements configuration";

    configuration = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Karabiner Elements configuration using karabinix DSL.

        Note: This module only manages the configuration file by default.
        To install Karabiner Elements, either set installPackage = true,
        or install it separately via Homebrew: `brew install --cask karabiner-elements`

        Example:
        ```nix
        {
          profiles = [{
            name = "Default";
            selected = true;
            simple_modifications = [
              (karabinixLib.mapKey "caps_lock" "left_control")
            ];
            complex_modifications.rules = [
              (karabinixLib.vimNavigation { layer_key = "caps_lock"; })
            ];
          }];
        }
        ```
      '';
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The Karabiner Elements package to install.
        Set to null to skip package installation (useful if you install Karabiner Elements via other means like Homebrew).
        Set to pkgs.karabiner-elements to install via Nix.
      '';
    };

    installPackage = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to install the Karabiner Elements package.
        If false, only the configuration file and reload script will be managed.
        This is useful if you prefer to install Karabiner Elements via Homebrew or other package managers.
      '';
    };

    configFile = mkOption {
      type = types.path;
      readOnly = true;
      description = "Generated karabiner.json configuration file";
    };
  };

  config = mkIf cfg.enable {
    services.karabinix.configFile = let
      configJson = karabinixLib.mkConfiguration cfg.configuration;
    in
      pkgs.writeText "karabiner.json" configJson;

    # Create the karabiner configuration directory and symlink the config
    home.file.".config/karabiner/karabiner.json".source = cfg.configFile;

    # Add reload script (always available)
    home.packages =
      [
        (pkgs.writeShellScriptBin "karabinix-reload" ''
          echo "Reloading Karabiner Elements configuration..."
          launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server
          echo "Configuration reloaded!"
        '')
      ]
      ++ optionals (cfg.installPackage && cfg.package != null) [
        # Conditionally install Karabiner Elements package
        cfg.package
      ];
  };
}
