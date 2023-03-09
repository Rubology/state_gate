# frozen_string_literal: true

module StateGate
  class Engine
    ##
    # = Description
    #
    # Provides state helper methods for StateGate::Engine.
    #
    module Stator

      # ======================================================================
      #   Configursation Methods
      # ======================================================================

      # Add a new +state+.
      #
      # @param [Symbol, String] name
      #   The name for the new state. It must be converatbel to a Symbol
      #     state :state_name
      #
      # @param [Hash] opts
      #   configuration options for the given state
      #
      # @option opts [Hash] :transitions_to
      #   A list of other state that this state may change to. (Array | optional)
      #     state :state_name, transtions_to: [:state_1, :state_4, :state_5]
      #
      # @option opts [Hash] :human
      #   A display name for the state used in views, defaulting to state.titleized.
      #     state :state_name, transtions_to: [:state_1, :state_4, :state_5], human: "My State"
      #
      def state(name, opts = {})
        name = StateGate.symbolize(name)
        _assert_valid_state_name(name)
        _assert_valid_opts(opts, name)

        # add the state
        @states[name] = _state_template.merge({ human: opts[:human] || name.to_s.titleize })

        # add the state transitions
        Array(opts[:transitions_to]).each do |transition|
          @states[name][:transitions_to] << StateGate.symbolize(transition)
        end
      end # state



      ##
      # The name for the default state for a new object. (String | required)
      #
      # @param [Symbol] default_state
      #   the state name to set as default
      #
      # @example
      #   default :state_name
      #
      def default(default_state = nil)
        _cerr(:default_type_err, kattr: true) unless default_state.is_a?(Symbol)
        _cerr(:default_repeat_err, kattr: true) if   @default
        @default = StateGate.symbolize(default_state)
      end



      # ======================================================================
      #   Helper Methods
      # ======================================================================

      ##
      # Returns an Array defined states.
      #
      # @example
      #   .states  #=> [:pending, :active, :suspended, :archived]
      #
      def states
        @states.keys
      end



      ##
      # Ensures the given value is a valid state name.
      #
      # @param [String, Symbol] value
      #   the state name.
      #
      # @example
      #   .assert_valid_state!(:active)    #=> :active
      #   .assert_valid_state!('PENDING')  #=> :pending
      #   .assert_valid_state!(:dummy)     #=> ArgumentError
      #
      #
      # @note
      #   Valid state names preceeded with +force_+ are also allowed.
      #
      #     .assert_valid_state!(:force_active)  #=> :force_active
      #
      # @return [Symbol]
      #   the Symbol state name
      #
      # @raise [ArgumentError]
      #   if the value is not a valid state name.
      #
      def assert_valid_state!(value)
        state_name                      = StateGate.symbolize(value)
        unforced_state                  = state_name.to_s.remove(/^force_/).to_sym
        _invalid_state_error(value) unless @states.keys.include?(unforced_state)
        state_name
      end



      ##
      # Returns an Array of the human display names for each defined state.
      #
      # @example
      #   human_states  #=> ['Pending Activation', 'Active', 'Suspended By Admin']
      #
      def human_states
        @states.map { |_k, v| v[:human] }
      end



      ##
      # Returns the human display name for a given state.
      #
      # @param [Symbol] state
      #   the state name
      #
      # @example
      #   .human_state_for(:pending)  #=> 'Panding Activation'
      #   .human_state_for(:active)   #=> 'Active'
      #
      def human_state_for(state)
        state_name = assert_valid_state!(state)
        @states[state_name][:human]
      end



      ##
      # Return an Array of states, with their human display names, ready for
      # use in a form select.
      #
      # @param [Boolean] sorted
      #   true is the states should be sorted by human name, defaults to false
      #
      # @return [Array[Array[Strings]]]
      #   Array of state names with their human names
      #
      # @example
      #   .states_for_select        #=> [['Pending Activation', 'pending'],
      #                                   ['Active', 'active'],
      #                                   ['Suspended by Admin', 'suspended']]
      #
      #   .states_for_select(true)  #=> [['Active', 'active'],
      #                                   ['Pending Activation', 'pending'],
      #                                   ['Suspended by Admin', 'suspended']]
      #
      def states_for_select(sorted = false)
        result = []
        if sorted
          @states.sort_by { |_k, v| v[:human] }
                 .each { |state, opts| result << [opts[:human], state.to_s] }
        else
          @states.each { |state, opts| result << [opts[:human], state.to_s] }
        end
        result
      end



      ##
      # @return [Hash]
      #   a hash of states and their transitions & human names
      #
      # @example
      #   .raw_states  #=> { pending: { transitions_to: [:active],
      #                                  human:          'Pending Activation'},
      #                       active:  { transitions_to: [:pending],
      #                                  human:          'Active'}}
      #
      def raw_states
        @states
      end



      ##
      # @return [String]
      #   the state_gate default state
      #
      # @example
      #   .default_state   #=> :pending
      #
      def default_state
        @default
      end



      # ======================================================================
      #   Private
      # ======================================================================
      private



      ##
      # @return [Hash]
      #   of the state keys defined.
      #
      def _state_template
        {
          transitions_to: [],
          previous_state: nil,
          next_state:     nil,
          scope_name:     nil,
          human:          ''
        }
      end



      ##
      # Raises an error fail if the supplied name is not a symbol, already added
      # or starts with 'not_' or 'force'.
      #
      # @param [Symbol] name
      #   the state name to validate
      #
      # @raise [AygumentError]
      #   if the state name is invalid
      #
      def _assert_valid_state_name(name)
        _cerr(:state_type_err, kattr: true) unless name.is_a?(Symbol)
        _cerr(:state_repeat_err, state: name, kattr: true)     if @states.key?(name)
        _cerr(:state_not_name_err, state: name, kattr: true)   if name.to_s.start_with?('not_')
        _cerr(:state_force_name_err, state: name, kattr: true) if name.to_s.start_with?('force_')
      end



      ##
      # raises an error if opts is not a hash, has non-symbol keys or non-symbol transitions.
      #
      # @param [Hash] opts
      #   an options hash
      #
      # @param [Symbol] name
      #   the state name
      #
      # @raise [ArgumentError]
      #   if any invalid options
      #
      def _assert_valid_opts(opts, state_name)
        unless opts.keys.reject { |k| k.is_a?(Symbol) }.blank?
          _cerr(:state_opts_key_type_err, state: state_name, kattr: true)
        end

        return if Array(opts[:transitions_to]).reject { |k| k.is_a?(Symbol) }.blank?

        _cerr(:transition_key_type_err, state: state_name, kattr: true)
      end

    end # Stater
  end # Engine
end # StateGate
