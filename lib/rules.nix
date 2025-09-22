{
  lib,
  types,
}:
with lib; rec {
  # Create a simple key modification
  mkSimpleModification = from: to: {
    from = {
      key_code = from;
    };
    to = [
      {
        key_code = to;
      }
    ];
  };

  # Create a basic manipulator
  mkManipulator = {
    from,
    to ? [],
    to_if_alone ? [],
    to_if_held_down ? [],
    to_after_key_up ? [],
    to_delayed_action ? null,
    conditions ? [],
    parameters ? null,
    description ? null,
    type ? "basic",
  }:
    {
      inherit type from;
    }
    // (optionalAttrs (to != []) {inherit to;})
    // (optionalAttrs (to_if_alone != []) {inherit to_if_alone;})
    // (optionalAttrs (to_if_held_down != []) {inherit to_if_held_down;})
    // (optionalAttrs (to_after_key_up != []) {inherit to_after_key_up;})
    // (optionalAttrs (to_delayed_action != null) {inherit to_delayed_action;})
    // (optionalAttrs (conditions != []) {inherit conditions;})
    // (optionalAttrs (parameters != null) {inherit parameters;})
    // (optionalAttrs (description != null) {inherit description;});

  # Create a rule with multiple manipulators
  mkRule = description: manipulators: {
    inherit description manipulators;
  };

  # Create a complex modification (collection of rules)
  mkComplexModification = {
    rules ? [],
    parameters ? null,
  }:
    {
      inherit rules;
    }
    // (optionalAttrs (parameters != null) {inherit parameters;});

  # Helper to create a from event
  mkFromEvent = {
    key_code ? null,
    consumer_key_code ? null,
    pointing_button ? null,
    modifiers ? null,
    simultaneous ? null,
    simultaneous_options ? null,
  }:
    {}
    // (optionalAttrs (key_code != null) {inherit key_code;})
    // (optionalAttrs (consumer_key_code != null) {inherit consumer_key_code;})
    // (optionalAttrs (pointing_button != null) {inherit pointing_button;})
    // (optionalAttrs (modifiers != null) {inherit modifiers;})
    // (optionalAttrs (simultaneous != null) {inherit simultaneous;})
    // (optionalAttrs (simultaneous_options != null) {inherit simultaneous_options;});

  # Helper to create a to event
  mkToEvent = {
    key_code ? null,
    consumer_key_code ? null,
    pointing_button ? null,
    mouse_key ? null,
    shell_command ? null,
    select_input_source ? null,
    set_variable ? null,
    set_notification_message ? null,
    modifiers ? [],
    lazy ? false,
    repeat ? true,
    halt ? false,
    hold_down_milliseconds ? null,
    description ? null, # Human-readable description for debug notifications
  }:
    {}
    // (optionalAttrs (key_code != null) {inherit key_code;})
    // (optionalAttrs (consumer_key_code != null) {inherit consumer_key_code;})
    // (optionalAttrs (pointing_button != null) {inherit pointing_button;})
    // (optionalAttrs (mouse_key != null) {inherit mouse_key;})
    // (optionalAttrs (shell_command != null) {inherit shell_command;})
    // (optionalAttrs (select_input_source != null) {inherit select_input_source;})
    // (optionalAttrs (set_variable != null) {inherit set_variable;})
    // (optionalAttrs (set_notification_message != null) {inherit set_notification_message;})
    // (optionalAttrs (modifiers != []) {inherit modifiers;})
    // (optionalAttrs lazy {inherit lazy;})
    // (optionalAttrs (!repeat) {inherit repeat;})
    // (optionalAttrs halt {inherit halt;})
    // (optionalAttrs (hold_down_milliseconds != null) {inherit hold_down_milliseconds;})
    // (optionalAttrs (description != null) {inherit description;});

  # Helper to create modifiers specification
  mkModifiers = {
    mandatory ? [],
    optional ? [],
  }:
    {}
    // (optionalAttrs (mandatory != []) {inherit mandatory;})
    // (optionalAttrs (optional != []) {inherit optional;});

  # Helper to create conditions
  mkCondition = {
    type,
    bundle_identifiers ? null,
    file_paths ? null,
    identifiers ? null,
    keyboard_types ? null,
    input_sources ? null,
    name ? null,
    value ? null,
  }:
    {
      inherit type;
    }
    // (optionalAttrs (bundle_identifiers != null) {inherit bundle_identifiers;})
    // (optionalAttrs (file_paths != null) {inherit file_paths;})
    // (optionalAttrs (identifiers != null) {inherit identifiers;})
    // (optionalAttrs (keyboard_types != null) {inherit keyboard_types;})
    // (optionalAttrs (input_sources != null) {inherit input_sources;})
    // (optionalAttrs (name != null) {inherit name;})
    // (optionalAttrs (value != null) {inherit value;});

  # Create a profile
  mkProfile = {
    name,
    selected ? false,
    simple_modifications ? [],
    complex_modifications ? {rules = [];},
    devices ? [],
    fn_function_keys ? [],
    virtual_hid_keyboard ? {},
  }: {
    inherit name selected simple_modifications complex_modifications devices fn_function_keys virtual_hid_keyboard;
  };

  # Create the main configuration
  mkConfiguration = {
    global ? {},
    profiles,
  }: {
    inherit global profiles;
  };
}
