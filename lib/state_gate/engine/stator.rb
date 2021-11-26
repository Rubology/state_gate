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
      # [:state_name*]
      #   The name for the new state. (Symbol | required)
      #     state :state_name
      #
      #
      # [:transitions_to]
      #   A list of other state that this state may change to. (Array | optional)
      #     state :state_name, transtions_to: [:state_1, :state_4, :state_5]
      #
      # [:human]
      #   A display name for the state used in views.
      #   (String | optoinal | default: state.titleized)
      #     state :state_name, transtions_to: [:state_1, :state_4, :state_5], human: "My State"
      #
      def state(name, opts = {})
        name = StateGate.symbolize(name)
        assert_valid_state_name(name)
        assert_valid_opts(opts, name)

        # add the state
        @states[name] = state_template.merge({ human: opts[:human] || name.to_s.titleize })

        # add the state transitions
        Array(opts[:transitions_to]).each do |transition|
          @states[name][:transitions_to] << StateGate.symbolize(transition)
        end
      end # state



      # The name for the default state for a new object. (String | required)
      #
      #   default :state_name
      #
      def default(val = nil)
        cerr(:default_type_err, kattr: true) unless val.is_a?(Symbol)
        cerr(:default_repeat_err, kattr: true) if   @default
        @default = StateGate.symbolize(val)
      end



      # ======================================================================
      #   Helper Methods
      # ======================================================================

      ##
      # Returns an Array defined states.
      #
      #   .states  # => [:pending, :active, :suspended, :archived]
      #
      def states
        @states.keys
      end



      ##
      # Ensures the given value is a valid state name.
      #
      # [value]
      #   A String or Symbol state name.
      #
      #     .assert_valid_state!(:active)    # => :active
      #     .assert_valid_state!('PENDING')  # => :pending
      #     .assert_valid_state!(:dummy)     # => ArgumentError
      #
      #
      # [Note]
      #   Valid state names preceeded with +force_+ are also allowed.
      #
      #     .assert_valid_state!(:force_active)  # => :force_active
      #
      # Returns the Symbol state name
      # Raises an exception if the value is not a valid state name.
      #
      def assert_valid_state!(value)
        state_name                      = StateGate.symbolize(value)
        unforced_state                  = state_name.to_s.remove(/^force_/).to_sym
        invalid_state_error(value) unless @states.keys.include?(unforced_state)
        state_name
      end



      ##
      # Returns an Array of the human display names for each defined state.
      #
      #   human_states  # => ['Pending Activation', 'Active', 'Suspended By Admin']
      #
      def human_states
        @states.map { |_k, v| v[:human] }
      end



      ##
      # Returns the human display name for a given state.
      #
      #   .human_state_for(:pending)  # => 'Panding Activation'
      #   .human_state_for(:active)   # => 'Active'
      #
      def human_state_for(state)
        state_name = assert_valid_state!(state)
        @states[state_name][:human]
      end



      ##
      # Return an Array of states, with their human display names, ready for
      # use in a form select.
      #
      # sorted - TRUE is the states should be sorted by human name, defaults to false
      #
      #   .states_for_select        # => [['Pending Activation', 'pending'],
      #                             #     ['Active', 'active'],
      #                             #     ['Suspended by Admin', 'suspended']]
      #
      #   .states_for_select(true)  # => [['Active', 'active'],
      #                             #     ['Pending Activation', 'pending'],
      #                             #     ['Suspended by Admin', 'suspended']]
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
      # Return the raw states hash, allowing inspection of the core engine states.
      #
      #   .raw_states  # => { pending: { transitions_to: [:active],
      #                #                 human:          'Pending Activation'},
      #                #      active:  { transitions_to: [:pending],
      #                #                 human:          'Active'}}
      #
      def raw_states
        @states
      end



      ##
      # Returns the state_gate default state
      #
      #   .default_state   # => :pending
      #
      def default_state
        @default
      end



      # ======================================================================
      #   Private
      # ======================================================================
      private



      # return a Hash with the state keys defined.
      def state_template
        {
          transitions_to: [],
          previous_state: nil,
          next_state:     nil,
          scope_name:     nil,
          human:          ''
        }
      end



      # fail if the supplied name is not a symbol, already added
      # or starts with 'not_' or 'force'.
      #
      def assert_valid_state_name(name)
        cerr(:state_type_err, kattr: true) unless name.is_a?(Symbol)
        cerr(:state_repeat_err, state: name, kattr: true)     if @states.key?(name)
        cerr(:state_not_name_err, state: name, kattr: true)   if name.to_s.start_with?('not_')
        cerr(:state_force_name_err, state: name, kattr: true) if name.to_s.start_with?('force_')
      end



      # Fail if opts is not a hash, has non-symbol keys or non-symbol transitions.
      #
      def assert_valid_opts(opts, state_name)
        unless opts.keys.reject { |k| k.is_a?(Symbol) }.blank?
          cerr(:state_opts_key_type_err, state: state_name, kattr: true)
        end

        return if Array(opts[:transitions_to]).reject { |k| k.is_a?(Symbol) }.blank?

        cerr(:transition_key_type_err, state: state_name, kattr: true)
      end

    end # Stater
  end # Engine
end # StateGate
