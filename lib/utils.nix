{
  lib,
  types,
}:
with lib; let
  rules = import ./rules.nix {inherit lib types;};
  keyCodes = import ./keycodes.nix;
in rec {
  # Create a layer key (key that activates a layer when held)
  layerKey = {
    key,
    mappings,
    alone_key ? null,
    variable_name ? "${key}_layer",
    enable_debug ? false, # Disabled by default
  }: let
    # Helper function to parse trigger keys that may include modifiers
    # Supports syntax like "shift+m", "ctrl+shift+a", or just "m"
    parseTrigger = trigger: let
      parts = splitString "+" trigger;
      key_code = last parts;
      modifierParts = init parts;

      # Map modifier names to Karabiner modifier names
      mapModifier = mod:
        if mod == "shift"
        then "left_shift"
        else if mod == "ctrl" || mod == "control"
        then "left_control"
        else if mod == "alt" || mod == "option"
        then "left_option"
        else if mod == "cmd" || mod == "command"
        then "left_command"
        else if mod == "fn"
        then "fn"
        else mod; # Pass through as-is for exact modifier names
    in
      {
        key_code = key_code;
      }
      // (optionalAttrs (modifierParts != []) {
        modifiers = map mapModifier modifierParts;
      });

    # Create manipulators for each mapping in the layer
    layerManipulators =
      mapAttrsToList (
        trigger: target: let
          triggerSpec = parseTrigger trigger;
          fromEvent = rules.mkFromEvent ({
              key_code = triggerSpec.key_code;
            }
            // (optionalAttrs (triggerSpec ? modifiers) {
              modifiers = rules.mkModifiers {
                mandatory = triggerSpec.modifiers;
              };
            }));
        in
          rules.mkManipulator {
            from = fromEvent;
            to =
              if isString target
              then [
                (rules.mkToEvent {key_code = target;})
              ]
              else if isList target
              then map (t: rules.mkToEvent {key_code = t;}) target
              else [
                target
              ];
            conditions = [
              (rules.mkCondition {
                type = "variable_if";
                name = variable_name;
                value = 1;
              })
            ];
            description = "Layer ${key}: ${trigger} -> ${
              if isString target
              then target
              else if isList target
              then toString target
              else "action"
            }";
          }
      )
      mappings;

    # Layer activation key with optional debug notifications
    layerKeyManipulator = rules.mkManipulator {
      from = rules.mkFromEvent {key_code = key;};
      to =
        [
          (rules.mkToEvent {
            set_variable = {
              name = variable_name;
              value = 1;
            };
          })
        ]
        ++ (
          if enable_debug
          then let
            mappingsText = formatMappingsForNotification mappings;
            notificationText =
              if mappingsText != ""
              then "${lib.toUpper variable_name}\n\n${mappingsText}"
              else "${lib.toUpper variable_name}";
          in [
            (showNotification "layer_${variable_name}" notificationText)
          ]
          else []
        );
      to_if_alone =
        if alone_key != null
        then [
          (rules.mkToEvent {key_code = alone_key;})
        ]
        else [];
      to_after_key_up =
        [
          (rules.mkToEvent {
            set_variable = {
              name = variable_name;
              value = 0;
            };
          })
        ]
        ++ (
          if enable_debug
          then [
            (hideNotification "layer_${variable_name}")
          ]
          else []
        );
      description = "Layer key (${key})";
    };
  in
    rules.mkRule "Layer: ${key}" ([layerKeyManipulator] ++ layerManipulators);

  # Application-specific condition (used internally by appLayerKey)
  appCondition = apps: type:
    rules.mkCondition {
      inherit type;
      bundle_identifiers =
        if isString apps
        then [apps]
        else apps;
    };

  # Vim-style navigation layer
  vimNavigation = {
    layer_key,
    variable_name ? "vim_mode",
    enable_debug ? false, # Disabled by default
  }: let
    # Basic vim navigation mappings
    basicVimLayer = layerKey {
      key = layer_key;
      variable_name = variable_name;
      enable_debug = enable_debug;
      alone_key = layer_key;
      mappings = {
        h = keyCodes.left_arrow;
        j = keyCodes.down_arrow;
        k = keyCodes.up_arrow;
        l = keyCodes.right_arrow;
        w = rules.mkToEvent {
          key_code = keyCodes.right_arrow;
          modifiers = ["left_option"];
          description = "word forward";
        };
        b = rules.mkToEvent {
          key_code = keyCodes.left_arrow;
          modifiers = ["left_option"];
          description = "word back";
        };
        "0" = keyCodes.home;
        "4" = keyCodes.end; # $ key
        u = keyCodes.page_up;
        d = keyCodes.page_down;
        g = keyCodes.home;
      };
    };

    # Additional manipulator for Shift+G (go to end, like Vim's G)
    shiftGManipulator = rules.mkManipulator {
      from = rules.mkFromEvent {
        key_code = keyCodes.g;
        modifiers = rules.mkModifiers {
          mandatory = ["left_shift"];
        };
      };
      to = [
        (rules.mkToEvent {key_code = keyCodes.end;})
      ];
      conditions = [
        (rules.mkCondition {
          type = "variable_if";
          name = variable_name;
          value = 1;
        })
      ];
      description = "Vim layer: Shift+G -> End";
    };
  in
    rules.mkRule "Vim Navigation (${layer_key})" (basicVimLayer.manipulators ++ [shiftGManipulator]);

  # Raycast window management function
  # Creates a shell command to trigger Raycast window management actions
  raycastWindow = name: {
    shell_command = "open -g raycast://extensions/raycast/window-management/${name}";
    description = name;
  };

  # Create per-application layer keys
  # This allows different layer mappings based on the frontmost application
  appLayerKey = {
    key,
    alone_key ? null,
    variable_name ? "${key}_app_layer",
    app_mappings, # attrset where keys are app bundle IDs and values are mapping attrsets
    enable_debug ? false, # Disabled by default
  }: let
    # Helper function to parse trigger keys that may include modifiers
    # Supports syntax like "shift+m", "ctrl+shift+a", or just "m"
    parseTrigger = trigger: let
      parts = splitString "+" trigger;
      key_code = last parts;
      modifierParts = init parts;

      # Map modifier names to Karabiner modifier names
      mapModifier = mod:
        if mod == "shift"
        then "left_shift"
        else if mod == "ctrl" || mod == "control"
        then "left_control"
        else if mod == "alt" || mod == "option"
        then "left_option"
        else if mod == "cmd" || mod == "command"
        then "left_command"
        else if mod == "fn"
        then "fn"
        else mod; # Pass through as-is for exact modifier names
    in
      {
        key_code = key_code;
      }
      // (optionalAttrs (modifierParts != []) {
        modifiers = map mapModifier modifierParts;
      });

    # Create manipulators for each app's mappings
    createAppManipulators = appId: mappings:
      mapAttrsToList (
        trigger: target: let
          triggerSpec = parseTrigger trigger;
          fromEvent = rules.mkFromEvent ({
              key_code = triggerSpec.key_code;
            }
            // (optionalAttrs (triggerSpec ? modifiers) {
              modifiers = rules.mkModifiers {
                mandatory = triggerSpec.modifiers;
              };
            }));
        in
          rules.mkManipulator {
            from = fromEvent;
            to =
              if isString target
              then [
                (rules.mkToEvent {key_code = target;})
              ]
              else if isList target
              then map (t: rules.mkToEvent {key_code = t;}) target
              else [
                target
              ];
            conditions = [
              (rules.mkCondition {
                type = "variable_if";
                name = variable_name;
                value = 1;
              })
              (appCondition appId "frontmost_application_if")
            ];
            description = "App Layer ${key} (${appId}): ${trigger} -> ${
              if isString target
              then target
              else if isList target
              then toString target
              else "action"
            }";
          }
      )
      mappings;

    # Create all manipulators for all apps
    allAppManipulators = flatten (mapAttrsToList createAppManipulators app_mappings);

    # Layer activation key with optional debug notifications
    layerKeyManipulator = rules.mkManipulator {
      from = rules.mkFromEvent {key_code = key;};
      to =
        [
          (rules.mkToEvent {
            set_variable = {
              name = variable_name;
              value = 1;
            };
          })
        ]
        ++ (
          if enable_debug
          then let
            mappingsText = formatAppMappingsForNotification app_mappings;
            notificationText =
              if mappingsText != ""
              then "${lib.toUpper variable_name}\n\n${mappingsText}"
              else "${lib.toUpper variable_name}";
          in [
            (showNotification "layer_${variable_name}" notificationText)
          ]
          else []
        );
      to_if_alone =
        if alone_key != null
        then [
          (rules.mkToEvent {key_code = alone_key;})
        ]
        else [];
      to_after_key_up =
        [
          (rules.mkToEvent {
            set_variable = {
              name = variable_name;
              value = 0;
            };
          })
        ]
        ++ (
          if enable_debug
          then [
            (hideNotification "layer_${variable_name}")
          ]
          else []
        );
      description =
        if enable_debug
        then "Debug App Layer key (${key})"
        else "App Layer key (${key})";
    };
  in
    rules.mkRule "App Layer: ${key}" ([layerKeyManipulator] ++ allAppManipulators);

  # Home row mod utilities (used internally by homeRowModsWithCombinations)
  # Create a single home row mod key (tap for key, hold for modifier)
  homeRowMod = {
    key, # The key to modify (e.g., "s", "d", "f", etc.)
    modifier, # The modifier when held (e.g., "left_option", "left_control", etc.)
    description ? null, # Optional custom description
  }:
    rules.mkManipulator {
      from = rules.mkFromEvent {
        key_code = key;
      };
      to_if_alone = [
        (rules.mkToEvent {
          halt = true;
          key_code = key;
        })
      ];
      to_if_held_down = [
        (rules.mkToEvent {
          halt = true;
          key_code = modifier;
        })
      ];
      to_delayed_action = {
        to_if_canceled = [{key_code = key;}];
        to_if_invoked = [{key_code = "vk_none";}];
      };
      description =
        if description != null
        then description
        else "${key}: ${modifier} when held, ${key} when tapped";
    };

  # Helper function to generate combinations of keys
  combinations = n: list: let
    # Generate combinations of size n from list
    combsHelper = n: list:
      if n == 0
      then [[]]
      else if list == []
      then []
      else let
        first = head list;
        rest = tail list;
        withFirst = map (comb: [first] ++ comb) (combsHelper (n - 1) rest);
        withoutFirst = combsHelper n rest;
      in
        withFirst ++ withoutFirst;
  in
    combsHelper n list;

  # Helper function to get modifiers for a key combination
  # Returns the modifier keys that should be active when the combination is held
  getCombinationModifiers = keyMods: keys: let
    # Get the modifiers for the given keys
    modifiers = map (key: keyMods.${key}) keys;
    # Find the primary modifier (the one that appears in the combination)
    # For 2-key combinations, use the second key's modifier as primary
    # For 3+ key combinations, use a more complex logic
    primaryMod =
      if length keys == 2
      then last modifiers
      else if length keys == 3
      then elemAt modifiers 1 # Use middle key's modifier
      else last modifiers; # For 4+ keys, use last
    # Get the other modifiers to include
    otherMods = filter (mod: mod != primaryMod) modifiers;
  in {
    primary = primaryMod;
    others = otherMods;
  };

  # Create combination home row mod manipulators
  homeRowModCombinations = keyMods: let
    keys = attrNames keyMods;

    # Generate 2, 3, and 4-key combinations
    twoCombos = combinations 2 keys;
    threeCombos = combinations 3 keys;
    fourCombos = combinations 4 keys;

    # Create manipulators for each combination size
    makeCombinationManipulator = keys: let
      comboMods = getCombinationModifiers keyMods keys;
      simultaneousKeys = map (key: {key_code = key;}) keys;

      # For 2-key combinations, create both orders with strict key_down_order
      createStrictOrderManipulators = keys: let
        keyOrder1 = keys;
        keyOrder2 = reverseList keys;
        simultaneousKeys1 = map (key: {key_code = key;}) keyOrder1;
        simultaneousKeys2 = map (key: {key_code = key;}) keyOrder2;
        toIfAlone = map (key: {key_code = key;}) keys;
        toIfHeld = [
          {
            key_code = comboMods.primary;
            modifiers = comboMods.others;
          }
        ];

        baseManipulator = {
          from = rules.mkFromEvent {
            simultaneous = simultaneousKeys1;
            simultaneous_options = {key_down_order = "strict";};
          };
          to_if_alone = toIfAlone;
          to_if_held_down = toIfHeld;
          description = "Home row mod combination: ${concatStringsSep "+" keys}";
        };

        # Create second manipulator with reversed order only if different
        secondManipulator =
          if keyOrder1 != keyOrder2
          then [
            {
              from = rules.mkFromEvent {
                simultaneous = simultaneousKeys2;
                simultaneous_options = {key_down_order = "strict";};
              };
              to_if_alone = map (key: {key_code = key;}) keyOrder2;
              to_if_held_down = toIfHeld;
              description = "Home row mod combination: ${concatStringsSep "+" keyOrder2}";
            }
          ]
          else [];
      in
        [baseManipulator] ++ secondManipulator;

      # For 3+ key combinations, use non-strict order
      createNonStrictManipulator = keys: [
        {
          from = rules.mkFromEvent {
            simultaneous = simultaneousKeys;
          };
          to_if_held_down = [
            {
              key_code = comboMods.primary;
              modifiers = comboMods.others;
            }
          ];
          description = "Home row mod combination: ${concatStringsSep "+" keys}";
        }
      ];
    in
      if length keys == 2
      then createStrictOrderManipulators keys
      else createNonStrictManipulator keys;

    # Generate all combination manipulators
    allCombinations =
      (map makeCombinationManipulator twoCombos)
      ++ (map makeCombinationManipulator threeCombos)
      ++ (map makeCombinationManipulator fourCombos);
  in
    flatten allCombinations;

  # Enhanced home row mods with combinations support
  homeRowModsWithCombinations = mods: let
    # Individual key manipulators
    modList =
      mapAttrsToList (
        key: modifier:
          homeRowMod {inherit key modifier;}
      )
      mods;

    # Combination manipulators
    combinationList = homeRowModCombinations mods;

    # Combine all manipulators, with combinations first (higher priority)
    allManipulators = (map (manip: rules.mkManipulator manip) combinationList) ++ modList;
  in
    rules.mkRule "Home Row Mods with Combinations" allManipulators;

  # Notification message utilities
  # Create a notification message event
  mkNotification = {
    id,
    text,
  }:
    rules.mkToEvent {
      set_notification_message = {
        inherit id text;
      };
    };

  # Show a notification message
  showNotification = id: text: mkNotification {inherit id text;};

  # Hide a notification message by setting text to empty string
  hideNotification = id:
    mkNotification {
      id = id;
      text = "";
    };

  # Helper function to translate modifier keys to symbols
  modifierToSymbol = modifier:
    if modifier == "left_command" || modifier == "right_command" || modifier == "command"
    then "⌘"
    else if modifier == "left_control" || modifier == "right_control" || modifier == "control"
    then "⌃"
    else if modifier == "left_option" || modifier == "right_option" || modifier == "option"
    then "⎇"
    else if modifier == "left_shift" || modifier == "right_shift" || modifier == "shift"
    then "⇧"
    else if modifier == "hyper"
    then "◆"
    else modifier; # Fallback to original if unknown

  # Helper function to translate key names to more readable symbols
  keyToSymbol = key:
    if key == "left_arrow"
    then "←"
    else if key == "right_arrow"
    then "→"
    else if key == "up_arrow"
    then "↑"
    else if key == "down_arrow"
    then "↓"
    else if key == "spacebar"
    then "space"
    else if key == "return_or_enter"
    then "↩"
    else if key == "escape"
    then "esc"
    else if key == "delete_or_backspace"
    then "⌫"
    else if key == "delete_forward"
    then "⌦"
    else if key == "tab"
    then "⇥"
    else if key == "caps_lock"
    then "⇪"
    else if key == "home"
    then "↖"
    else if key == "end"
    then "↘"
    else if key == "page_up"
    then "⇞"
    else if key == "page_down"
    then "⇟"
    else key; # Fallback to original key name

  # Helper function to wrap text to maximum width with proper line breaks
  wrapText = {
    text,
    maxWidth ? 80,
    separator ? " | ",
    indent ? "",
  }: let
    # Split text into individual items
    items = splitString separator text;

    # Function to build lines respecting max width
    buildLines = items: let
      # Helper function to add items to lines
      addToLines = lines: remainingItems:
        if remainingItems == []
        then lines
        else let
          currentItem = head remainingItems;
          restItems = tail remainingItems;
          currentLine =
            if lines == []
            then ""
            else last lines;
          otherLines =
            if lines == []
            then []
            else init lines;

          # Calculate the width if we add this item to current line
          newLineContent =
            if currentLine == ""
            then "${indent}${currentItem}"
            else "${currentLine}${separator}${currentItem}";

          newLineWidth = stringLength newLineContent;
        in
          if newLineWidth <= maxWidth
          then
            # Item fits on current line
            addToLines (otherLines ++ [newLineContent]) restItems
          else
            # Item doesn't fit, start new line
            addToLines (lines ++ ["${indent}${currentItem}"]) restItems;
    in
      addToLines [] items;
  in
    if text == ""
    then ""
    else concatStringsSep "\n" (buildLines items);

  # Helper function to format mappings for debug notifications
  formatMappingsForNotification = mappings: let
    # Convert a target to a readable string with symbols
    targetToString = target:
      if isString target
      then keyToSymbol target
      else if isList target
      then let
        # Separate modifiers from the main key
        modifiers = init target;
        mainKey = last target;
        symbolModifiers = map modifierToSymbol modifiers;
        symbolKey = keyToSymbol mainKey;
      in
        if modifiers == []
        then symbolKey
        else "${concatStringsSep "" symbolModifiers}${symbolKey}"
      else if isAttrs target && target ? key_code
      then let
        # Handle rules.mkToEvent structure - use description if available
        description = target.description or null;
      in
        if description != null
        then description
        else let
          key = keyToSymbol target.key_code;
          modifiers = target.modifiers or [];
          symbolModifiers = map modifierToSymbol modifiers;
        in
          if modifiers == []
          then key
          else "${concatStringsSep "" symbolModifiers}${key}"
      else if isAttrs target && target ? shell_command
      then let
        # Handle shell commands - use description if available
        description = target.description or null;
      in
        if description != null
        then description
        else "shell"
      else "action";

    # Format individual mapping with symbolic trigger
    formatMapping = trigger: target: let
      # Parse trigger for modifiers (e.g., "shift+m")
      triggerParts = splitString "+" trigger;
      triggerKey = last triggerParts;
      triggerModifiers = init triggerParts;

      formattedTrigger =
        if triggerModifiers == []
        then triggerKey
        else "${concatStringsSep "+" (map modifierToSymbol triggerModifiers)}${triggerKey}";

      formattedTarget = targetToString target;
    in "${formattedTrigger}:${formattedTarget}";

    # Format all mappings without arbitrary limits
    mappingsList = mapAttrsToList formatMapping mappings;

    # Join mappings with separator and wrap to 80 characters
    allMappingsText = concatStringsSep " | " mappingsList;
    wrappedMappingsText = wrapText {
      text = allMappingsText;
      maxWidth = 80;
      separator = " | ";
      indent = "";
    };
  in
    if mappings == {}
    then ""
    else wrappedMappingsText;

  # Helper function to format app mappings for debug notifications
  formatAppMappingsForNotification = app_mappings: let
    # Format mappings for a single app
    formatAppMappings = appId: mappings: let
      appName = builtins.baseNameOf appId; # Extract app name from bundle ID
      mappingsText = formatMappingsForNotification mappings;
    in
      if mappingsText != ""
      then let
        # If mappings span multiple lines, indent continuation lines
        mappingsLines = splitString "\n" mappingsText;
        firstLine = "${appName}: ${head mappingsLines}";
        remainingLines = tail mappingsLines;
        indentedRemainingLines = map (line: "  ${line}") remainingLines;
      in
        concatStringsSep "\n" ([firstLine] ++ indentedRemainingLines)
      else "${appName}: (no mappings)";

    # Format all apps without arbitrary limits
    appsList = mapAttrsToList formatAppMappings app_mappings;

    # Join with newlines and ensure total width doesn't exceed bounds
    appsText = concatStringsSep "\n" appsList;
  in
    if app_mappings == {}
    then ""
    else appsText;

  # Helper function to format sublayers for debug notifications
  formatSublayersForNotification = sublayers: let
    # Format mappings for a single sublayer
    formatSublayerMappings = sublayerKey: mappings: let
      mappingsText = formatMappingsForNotification mappings;
    in
      if mappingsText != ""
      then let
        # If mappings span multiple lines, indent continuation lines
        mappingsLines = splitString "\n" mappingsText;
        firstLine = "${sublayerKey}: ${head mappingsLines}";
        remainingLines = tail mappingsLines;
        indentedRemainingLines = map (line: "  ${line}") remainingLines;
      in
        concatStringsSep "\n" ([firstLine] ++ indentedRemainingLines)
      else "${sublayerKey}: (no mappings)";

    # Format all sublayers without arbitrary limits
    sublayersList = mapAttrsToList formatSublayerMappings sublayers;

    # Join with newlines
    sublayersText = concatStringsSep "\n" sublayersList;
  in
    if sublayers == {}
    then ""
    else sublayersText;
}
