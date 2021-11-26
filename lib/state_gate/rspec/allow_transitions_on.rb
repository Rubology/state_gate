# frozen_string_literal: true

##
# = Description
#
# RSpec matcher to verify allowed state transitions.
#
# [:source_obj]
#   The Class or Instance to be tested.
#
# [:attr_name]
#   The attrbute being tested.
#
# [:from]
#   The state being transtioned from
#
# [:to]
#   The states being transitions to
#
#  expect(User).to allow_transitions_on(:status).from(:active).to(:suspended, :archived)
#
# Fails if a given transitions is not allowed, or an allowed transition is missing.
#
RSpec::Matchers.define :allow_transitions_on do |attr_name| # rubocop:disable Metrics/BlockLength
  ##
  # Expect the given attribute state to match all given transitions.
  #
  match do |source_obj| # :nodoc:
    # validate we have a state engine and parameters
    return false unless valid_setup?(attr_name, source_obj)

    allowed_transitions  = source_obj.stateables[@key]
                                     .transitions_for_state(@state)
    expected_transitions = @to.map(&:to_s).map(&:to_sym)
    @missing_states      = allowed_transitions - expected_transitions
    @extra_states        = expected_transitions - allowed_transitions

    @error = :missing_states if @missing_states.any?
    @error = :extra_states   if @extra_states.any?

    @error ? false : true
  end



  # Expect the attribute state not to have any given transitions.
  #
  match_when_negated do |source_obj|
    # validate we have a state engine and parameters
    return false unless valid_setup?(attr_name, source_obj)

    allowed_transitions  = source_obj.stateables[@key]
                                     .transitions_for_state(@state)
    expected_transitions = @to.map(&:to_s).map(&:to_sym)
    remaining_states     = expected_transitions - allowed_transitions

    unless remaining_states.count == expected_transitions.count
      @error             = :found_states
      @found_states      = expected_transitions - remaining_states
    end

    @error ? false : true
  end



  # The state to be checked.
  chain :from do |state|
    @state = state
  end



  # The transitions to check
  chain :to do |*transitions|
    @to        = transitions.flatten
    @to_called = true
  end



  # Failure messages for an expected match.
  #
  failure_message do
    case @error
    when :no_state_gates
      "no state machines are defined for #{@source_name}."

    when :invalid_key
      "no state machine is defined for ##{@key}."

    when :invalid_state
      ":#{@state} is not a valid state for #{@source_name}##{@key}."

    when :no_from
      'missing ".from(<state>)".'

    when :no_to
      'missing ".to(<states>)".'

    when :invalid_transition_states
      states = @invalid_states.map { |s| ":#{s}" }
      if states.one?
        "#{states.first} is not a valid ##{@key} state."
      else
        "#{states.to_sentence} are not valid ##{@key} states."
      end

    when :missing_states
      states = @missing_states.map { |s| ":#{s}" }
      "##{@key} also transitions from :#{@state} to #{states.to_sentence}."

    when :extra_states
      states = @extra_states.map { |s| ":#{s}" }
      "##{@key} does not transition from :#{@state} to #{states.to_sentence}."
    end
  end



  # failure messages for a negated match.
  #
  failure_message_when_negated do
    case @error
    when :no_state_gates
      "no state machines are defined for #{@source_name}."

    when :invalid_key
      "no state machine is defined for ##{@key}."

    when :invalid_state
      ":#{@state} is not a valid state for #{@source_name}##{@key}."

    when :no_from
      'missing ".from(<state>)".'

    when :no_to
      'missing ".to(<states>)".'

    when :invalid_transition_states
      states = @invalid_states.map { |s| ":#{s}" }
      if states.one?
        "#{states.first} is not a valid ##{@key} state."
      else
        "#{states.to_sentence} are not valid ##{@key} states."
      end

    when :found_states
      states = @found_states.map { |s| ":#{s}" }
      ":#{@state} is allowed to transition to #{states.to_sentence}."
    end
  end



  # = Helpers
  # ======================================================================

  # Check the setup is correct with the required information available.
  #
  def valid_setup?(attr_name, source_obj) # :nodoc:
    @key            = StateGate.symbolize(attr_name)
    @state          = StateGate.symbolize(@state)
    @source_name    = source_obj.is_a?(Class) ? source_obj.name : source_obj.class.name

    # detect_setup_errors(source_obj)

    return false unless assert_state_gate(source_obj)
    return false unless assert_valid_key(source_obj)
    return false unless assert_from_present
    return false unless assert_valid_state
    return false unless assert_to_present

    assert_valid_transition
  end



  # Validate the state machines container exists
  #
  def assert_state_gate(source_obj)
    return true if source_obj.respond_to?(:stateables)

    @error = :no_state_gates
    false
  end



  # Validate the state machine is there
  #
  def assert_valid_key(source_obj)
    @eng = source_obj.stateables[@key]
    return true unless @eng.blank?

    @error = :invalid_key
    false
  end



  # Validate the :from state is present
  #
  def assert_from_present
    return true unless @state.blank?

    @error = :no_from
    false
  end



  # Validate it is a valid state supplied
  #
  def assert_valid_state
    return true if @eng.states.include?(@state)

    @error = :invalid_state
    false
  end



  # Validate the transitions have been supplied
  #
  def assert_to_present
    return true if @to_called

    @error = :no_to
    false
  end



  # Validate the supplied transitions are valid
  #
  def assert_valid_transition
    return true unless invalid_transition_states?

    @error = :invalid_transition_states
    false
  end



  # Check the supplied transition states are valid for the attribute.
  #
  def invalid_transition_states? # :nodoc:
    @invalid_states = []
    @to.each do |state|
      unless @eng.states.include?(state.to_s.to_sym)
        @invalid_states << state.to_s.to_sym
        @error = :invalid_transition_states
      end
    end

    @invalid_states.any? ? true : false
  end
end
