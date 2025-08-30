{ config, pkgs, ... }:

{
  # Enable karabinix service
  services.karabinix = {
    enable = true;
    configuration = import ./config.nix { 
      karabinix = builtins.getFlake "github:pepegar/karabinix";
    };
  };

  # Additional packages that work well with the advanced configuration
  home.packages = with pkgs; [
    yabai      # Window manager
    skhd       # Hotkey daemon
    raycast    # Application launcher (alternative to built-in shortcuts)
  ];

  # Optional: Configure yabai for window management
  # (This would typically go in your system configuration)
  home.file.".config/yabai/yabairc" = {
    text = ''
      #!/usr/bin/env sh
      
      # Global settings
      yabai -m config layout bsp
      yabai -m config window_placement second_child
      
      # Window appearance
      yabai -m config window_border on
      yabai -m config window_border_width 2
      yabai -m config active_window_border_color 0xff775759
      yabai -m config normal_window_border_color 0xff555555
      
      # Mouse settings
      yabai -m config mouse_follows_focus on
      yabai -m config focus_follows_mouse autoraise
    '';
    executable = true;
  };
}
