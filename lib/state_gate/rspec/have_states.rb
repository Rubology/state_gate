# frozen_string_literal: true

##
# = Description
#
# RSpec matcher to verify defined states.
#
# [:source_obj]
#   The Class or Instance to be tested.
#
# [:for]
#   The attrbute being tested.
#
# [:states]
#   The expected states as Symbols or Strings
#
#  expect(User).to have_states(:pending, :active).for(:status)
#
# Fails if an exisiting state is missing or there are defined states that
# have not been included.
#
RSpec::Matchers.define :have_states do |*states| # rubocop:disable Metrics/BlockLength
  #
  # Expect the given states to match all the states for the attribute.
  #
  match do |source_obj| # :nodoc:
    # validate we have a state engine and parameters
    return false unless valid_setup?(states, source_obj)

    @missing_states = @eng.states - @states
    @extra_states   = @states     - @eng.states

    @error = :missing_states if @missing_states.any?
    @error = :extra_states   if @extra_states.any?

    @error ? false : true
  end


  # Expect the attribute not to have any given states.
  #
  match_when_negated do |source_obj|
    # validate we have a state engine and parameters
    return false unless valid_setup?(states, source_obj)

    @valid_states = @states.select { |s| @eng.states.include?(s) }
    @error        = :valid_states_found if @valid_states.any?

    @error ? false : true
  end


  # The attribute that should have the expected states.
  #
  chain :for do |attr_name|
    @key = StateGate.symbolize(attr_name)
  end



  # Failure messages for an expected match.
  #
  failure_message do
    case @error
    when :no_state_gates
      "no state machines are defined for #{@source_name}."

    when :missing_key
      'missing ".for(<attribute>)".'

    when :invalid_key
      "no state machine is defined for ##{@key}."

    when :missing_states
      states = @missing_states.map { |s| ":#{s}" }
      if states.one?
        "#{states.first} is also a valid state for ##{@key}."
      else
        "#{states.to_sentence} are also valid states for ##{@key}."
      end

    when :extra_states
      states = @extra_states.map { |s| ":#{s}" }
      if states.one?
        "#{states.first} is not a valid state for ##{@key}."
      else
        "#{states.to_sentence} are not valid states for ##{@key}."
      end
    end
  end



  # failure messages for a negated match.
  #
  failure_message_when_negated do
    case @error
    when :no_state_gates
      "no state machines are defined for #{@source_name}."

    when :missing_key
      'missing ".for(<attribute>)".'

    when :invalid_key
      "no state machine is defined for ##{@key}."

    when :valid_states_found
      states = @valid_states.map { |s| ":#{s}" }
      if states.one?
        "#{states.first} is a valid state for ##{@key}."
      else
        "#{states.to_sentence} are valid states for ##{@key}."
      end
    end
  end



  #  Helpers
  # ======================================================================

  # Check the setup is correct with the required information available.
  #
  def valid_setup?(states, source_obj) # :nodoc:
    @states         = states.flatten.map { |s| StateGate.symbolize(s) }
    @source_name    = source_obj.is_a?(Class) ? source_obj.name : source_obj.class.name

    if @key.blank?
      @error = :missing_key

    elsif !source_obj.respond_to?(:stateables)
      @error = :no_state_gates

    elsif (@eng = source_obj.stateables[@key]).blank?
      @error = :invalid_key
    end

    @error ? false : true
  end
end
