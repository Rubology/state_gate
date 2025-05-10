# frozen_string_literal: true

module StateGate
  ##
  # = Description
  #
  # Minitest assertions to verify StateGate defined states and transitions.
  #
  # The Minitest equivalent of the StateGate RSpec +have_states+ and
  # +allow_transitions_on+ matchers.
  #
  # [:source_obj]
  #   The Class or Instance to be tested.
  #
  # [:attribute]
  #   The attribute being tested.
  #
  # [:states]
  #   The expected states as Symbols or Strings.
  #
  # [:from]
  #   The state being transitioned from.
  #
  # [:to]
  #   The states being transitioned to, as a Symbol, String or Array.
  #
  #   assert_has_states Sysop, :status, :pending, :active
  #   refute_has_states Sysop, :status, :deleted
  #
  #   assert_allows_transitions Sysop, :status, from: :active, to: [:locked, :archived]
  #   refute_allows_transitions Sysop, :status, from: :active, to: :pending
  #
  # +assert_has_states+ fails if an existing state is missing, or if given
  # states are not defined for the attribute.
  #
  # +refute_has_states+ fails if any of the given states are defined for
  # the attribute.
  #
  # +assert_allows_transitions+ fails if an allowed transition is missing, or
  # if a given transition is not allowed.
  #
  # +refute_allows_transitions+ fails if any of the given transitions are
  # allowed for the state.
  #
  module Assertions
  
    #  States
    # ======================================================================
  
    ##
    # Asserts the given states are exactly the states defined for the attribute.
    #
    #   assert_has_states Sysop, :status, :pending, :active, :locked
    #   assert_has_states sysop, :status, %w[pending active locked]
    #
    def assert_has_states(source_obj, attribute, *states)
      engine   = state_gate_engine(source_obj, attribute)
      key      = StateGate.symbolize(attribute)
      expected = state_gate_symbolize_states(states)
  
      missing  = engine.states - expected
      extra    = expected      - engine.states
  
      return pass if missing.empty? && extra.empty?
  
      messages = []
      messages << state_gate_also_valid_message(missing, key) if missing.any?
      messages << state_gate_not_valid_message(extra, key)    if extra.any?
  
      flunk messages.join(' ')
    end
  
  
    ##
    # Asserts none of the given states are defined for the attribute.
    #
    #   refute_has_states Sysop, :status, :deleted, :banned
    #
    def refute_has_states(source_obj, attribute, *states)
      engine   = state_gate_engine(source_obj, attribute)
      key      = StateGate.symbolize(attribute)
      expected = state_gate_symbolize_states(states)
  
      found    = expected.select { |s| engine.states.include?(s) }
  
      return pass if found.empty?
  
      if found.one?
        flunk "#{state_gate_list(found)} is a valid state for ##{key}."
      else
        flunk "#{state_gate_list(found)} are valid states for ##{key}."
      end
    end
  
  
    #  Transitions
    # ======================================================================
  
    ##
    # Asserts the given states are exactly the transitions allowed from the
    # +:from+ state.
    #
    #   assert_allows_transitions Sysop, :status, from: :active,
    #                                             to: [:locked, :suspended, :archived]
    #   assert_allows_transitions sysop, :status, from: :pending, to: :active
    #
    def assert_allows_transitions(source_obj, attribute, from: nil, to: nil)
      key, engine, state, expected = state_gate_transition_setup(source_obj, attribute, from, to)
  
      allowed = engine.transitions_for_state(state)
      missing = allowed  - expected
      extra   = expected - allowed
  
      return pass if missing.empty? && extra.empty?
  
      messages = []
      if missing.any?
        messages << "##{key} also transitions from :#{state} to #{state_gate_list(missing)}."
      end
      if extra.any?
        messages << "##{key} does not transition from :#{state} to #{state_gate_list(extra)}."
      end
  
      flunk messages.join(' ')
    end
  
  
    ##
    # Asserts none of the given states are transitions allowed from the
    # +:from+ state.
    #
    #   refute_allows_transitions Sysop, :status, from: :archived, to: [:locked, :suspended]
    #
    def refute_allows_transitions(source_obj, attribute, from: nil, to: nil)
      _key, engine, state, expected = state_gate_transition_setup(source_obj, attribute, from, to)
  
      found = expected & engine.transitions_for_state(state)
  
      return pass if found.empty?
  
      flunk ":#{state} is allowed to transition to #{state_gate_list(found)}."
    end
  
  
    #  Helpers
    # ======================================================================
  
    private
  
    ##
    # Returns the StateGate engine for the attribute, flunking with the
    # relevant message when the setup is incomplete or incorrect.
    #
    def state_gate_engine(source_obj, attribute) # :nodoc:
      key = StateGate.symbolize(attribute)
  
      flunk 'missing the <attribute> to be tested.' if key.blank?
  
      unless source_obj.respond_to?(:stateables)
        flunk "no state machines are defined for #{state_gate_source_name(source_obj)}."
      end
  
      engine = source_obj.stateables[key]
      flunk "no state machine is defined for ##{key}." if engine.blank?
  
      engine
    end
  
  
    ##
    # Validates the transition parameters, returning the attribute key, the
    # engine, the +:from+ state and the expected +:to+ states.
    #
    def state_gate_transition_setup(source_obj, attribute, from, to) # :nodoc:
      engine = state_gate_engine(source_obj, attribute)
      key    = StateGate.symbolize(attribute)
  
      flunk 'missing the <from:> state.' if from.blank?
      flunk 'missing the <to:> states.'  if to.nil?
  
      state = state_gate_symbolize_states([from]).first
      unless engine.states.include?(state)
        flunk ":#{state} is not a valid state for #{state_gate_source_name(source_obj)}##{key}."
      end
  
      expected = state_gate_symbolize_states(Array(to))
      invalid  = expected.reject { |s| engine.states.include?(s) }
  
      if invalid.one?
        flunk "#{state_gate_list(invalid)} is not a valid ##{key} state."
      elsif invalid.any?
        flunk "#{state_gate_list(invalid)} are not valid ##{key} states."
      end
  
      [key, engine, state, expected]
    end
  
  
    ##
    # The name of the Class or Instance being tested.
    #
    def state_gate_source_name(source_obj) # :nodoc:
      source_obj.is_a?(Class) ? source_obj.name : source_obj.class.name
    end
  
  
    ##
    # Flattens and symbolizes the given state names.
    #
    def state_gate_symbolize_states(states) # :nodoc:
      states.flatten.map do |state|
        StateGate.symbolize(state) || flunk("\"#{state}\" is not a valid state name.")
      end
    end
  
  
    # ":pending, :active, and :locked"
    #
    def state_gate_list(states) # :nodoc:
      states.map { |s| ":#{s}" }.to_sentence
    end
  
  
    # "...is also a valid state for #status."
    #
    def state_gate_also_valid_message(missing, key) # :nodoc:
      if missing.one?
        "#{state_gate_list(missing)} is also a valid state for ##{key}."
      else
        "#{state_gate_list(missing)} are also valid states for ##{key}."
      end
    end
  
  
    # "...is not a valid state for #status."
    #
    def state_gate_not_valid_message(extra, key) # :nodoc:
      if extra.one?
        "#{state_gate_list(extra)} is not a valid state for ##{key}."
      else
        "#{state_gate_list(extra)} are not valid states for ##{key}."
      end
    end
  
  end # Assertions
end # StateGate
