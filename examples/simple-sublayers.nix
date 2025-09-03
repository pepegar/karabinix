# Simple Sublayer Example
# This demonstrates the basic sublayer pattern: Hyper + Sublayer + Action
# Hold Caps Lock + o + w for window left half
# Hold Caps Lock + b + t to open Twitter
{karabinix}:
with karabinix.lib;
  mkConfiguration {
    profiles = [
      (mkProfile {
        name = "Simple Sublayers";
        selected = true;

        complex_modifications = mkComplexModification {
          rules = [
            # Simple sublayer system
            (sublayerKey {
              key = keyCodes.caps_lock; # Caps Lock is the hyper key
              alone_key = keyCodes.escape; # Caps Lock alone = Escape

              sublayers = {
                # Window management sublayer
                "o" = {
                  "w" = raycastWindow "left-half"; # Hyper+o+w = Left half
                  "e" = raycastWindow "right-half"; # Hyper+o+e = Right half
                  "f" = raycastWindow "maximize"; # Hyper+o+f = Fullscreen
                  "c" = raycastWindow "center"; # Hyper+o+c = Center
                };

                # Browser shortcuts sublayer
                "b" = {
                  "t" = {shell_command = "open https://twitter.com";}; # Hyper+b+t = Twitter
                  "g" = {shell_command = "open https://github.com";}; # Hyper+b+g = GitHub
                  "y" = {shell_command = "open https://youtube.com";}; # Hyper+b+y = YouTube
                };

                # App launcher sublayer
                "a" = {
                  "c" = {shell_command = "open -a 'Visual Studio Code'";}; # Hyper+a+c = VS Code
                  "s" = {shell_command = "open -a 'Slack'";}; # Hyper+a+s = Slack
                  "t" = {shell_command = "open -a 'Terminal'";}; # Hyper+a+t = Terminal
                };
              };
            })
          ];
        };
      })
    ];
  }
