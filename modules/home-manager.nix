{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.karabinix;
  karabinixLib = import ../lib { inherit lib; };
in

{
  options.services.karabinix = {
    enable = mkEnableOption "Karabinix Karabiner Elements configuration";

    configuration = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Karabiner Elements configuration using karabinix DSL.
        
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
      type = types.package;
      default = pkgs.karabiner-elements;
      description = "The Karabiner Elements package to use";
    };

    configFile = mkOption {
      type = types.path;
      readOnly = true;
      description = "Generated karabiner.json configuration file";
    };
  };

  config = mkIf cfg.enable {
    services.karabinix.configFile = 
      let
        configJson = karabinixLib.mkConfiguration cfg.configuration;
      in
      pkgs.writeText "karabiner.json" configJson;

    # Create the karabiner configuration directory and symlink the config
    home.file.".config/karabiner/karabiner.json".source = cfg.configFile;

    # Ensure Karabiner Elements is available
    home.packages = [ cfg.package ];

    # Add a script to reload Karabiner configuration
    home.packages = [
      (pkgs.writeShellScriptBin "karabinix-reload" ''
        echo "Reloading Karabiner Elements configuration..."
        launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server
        echo "Configuration reloaded!"
      '')
    ];
  };
}
