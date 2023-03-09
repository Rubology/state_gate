# frozen_string_literal: true

module StateGate
  class Engine
    ##
    # = Description
    #
    # Parses the configuration for StateGate::Engine.
    #
    # The configuration defines the state names, allowed transitions and a number of
    # options to help customise the _state-gate_ to your exact preference.
    #
    # Options include:
    #
    # [state]
    #   Required name for the new state, supplied as a Symbol. The +state-gate+ requires
    #   a minimum of two states to be defined.
    #     state :state_name
    #
    #
    #   **_:transitions_to_**
    #   An optional list of the other state that this state is allowed to change to.
    #     state :state_1, transtions_to: [:state_2, :state_3, :state_4]
    #     state :state_2, transtions_to: :state_4
    #     state :state_3, transtions_to: :any
    #     state :state_4
    #
    #   **_:human_**
    #   An optional String name to used when displaying gthe state in a view. If no
    #   name is specified, it will default to +:state.titleized+.
    #     state :state_1, transtions_to: [:state_2, :state_3], human: "My State"
    #
    #
    # [default]
    #   Optional setting to specify the default state for a new object. The state name
    #   is given as a Symbol.
    #     default :state_name
    #
    #
    # [prefix]
    #   Optional setting to add a given Symbol before each state name when using Class Scopes.
    #   This helps to differential between multiple attributes that have similar state names.
    #     prefix :before  #=> Class.before_active
    #
    #
    # [suffix]
    #   Optional setting to add a given Symbol after each state name when using Class Scopes.
    #   This helps to differential between multiple attributes that have similar state names.
    #     suffix :after  #=> Class.active_after
    #
    #
    # [make_sequential]
    #   Optional setting to automatically add transitions from each state to both the
    #   preceeding and following states.
    #     make_sequential
    #
    #   **_:one_way_**
    #     Option to restrict the generated transitions to one directtion only: from each
    #     state to the follow state.
    #       make_sequential :one_way
    #
    #   **_:loop_**
    #     Option to add transitions from the last state to the first and, unless +:one_way+
    #     is specified, also from the first state to the last.
    #       make_sequential :one_way, :loop
    #
    #
    # [no_scopes]
    #   Optional setting to disable the generation of Class Scope helpers methods.
    #     no_scopes
    #
    module Configurator

      # = Private
      # ======================================================================
      private


      # ======================================================================
      #  Configuration Commands
      # ======================================================================


      ##
      # Execute the provided configuration.
      #
      # @block config
      #   the given configuration
      #
      # ==== actions
      #
      # - create sequence links and transitions
      # - create scope names
      # - remove duplicate transitions for each state
      #
      # - verify there are multiple valid state names
      # - verify all transitions lead to existing states
      # - verify each state, except the default, can be reached from a transition
      #
      def parse_configuration(&config)
        exec_configuration(&config)

        generate_sequences
        generate_scope_names

        assert_states_are_valid
        assert_transitions_exist
        assert_uniq_transitions
        assert_any_has_been_expanded
        assert_all_transitions_are_states
        assert_all_states_are_reachable
      end



      ##
      # Run the configuration commands.
      #
      # @block config
      #   the given configuration
      #
      # ==== actions
      #
      # - create sequence links and transitions
      # - create scope names
      # - remove duplicate transitions for each state
      #
      # - verify there are multiple valid state names
      # - verify all transitions lead to existing states
      # - verify each state, except the default, can be reached from a transition
      #
      def exec_configuration(&config)
        instance_exec(&config)
      rescue NameError => e
        err_command = e.to_s.gsub('undefined local variable or method `', '')
                       .split("'")
                       .first
        cerr :bad_command, cmd: err_command
      end



      # ======================================================================
      #  Assertions
      # ======================================================================

      ##
      # Ensure there are enough states and the default is a valid state, setting
      # the default to the first state if required.
      #
      def assert_states_are_valid
        state_names = @states.keys

        # are there states
        cerr(:states_missing_err) if state_names.blank?

        # is there more than one state
        cerr(:single_state_err) if state_names.one?

        # set the deafult state if needed, otherwise check it is a valid state
        if @default
          cerr(:default_state_err) unless state_names.include?(@default)
        else
          @default = state_names.first
        end
      end



      ##
      # Ensure that transitions have been specified.  If not, then add the transitions
      # to allow every stater to transition to another state and flag the engine as
      # transitionless, so we don't add any validation methods.
      #
      def assert_transitions_exist
        return if @states.map { |_state, opts| opts[:transitions_to] }.uniq.flatten.any?

        @transitionless = true
        @states.keys.each do |key|
          @states[key][:transitions_to] = @states.keys - [key]
        end
      end



      ##
      # Ensure that there is only one of reach transition
      #
      def assert_uniq_transitions
        @states.each { |_state, opts| opts[:transitions_to].uniq! }
      end



      ##
      # Ensure that the :any transition is expanded or raise an exception
      # if it's included with other transitions
      def assert_any_has_been_expanded
        @states.each do |state_name, opts|
          if opts[:transitions_to] == [:any]
            @states[state_name][:transitions_to] = @states.keys - [state_name]

          elsif opts[:transitions_to].include?(:any)
            cerr(:any_transition_err, state: state_name, kattr: true)
          end
        end
      end



      ##
      # Ensure all transitions are to valid states.
      #
      # Replaces transition to :any with a list of all states
      # Raises an exception if :any in included with a list of other transitions
      #
      def assert_all_transitions_are_states
        @states.each do |state_name, opts|
          opts[:transitions_to].each do |transition|
            unless @states.keys.include?(transition)
              cerr(:transition_state_err, state: state_name, transition: transition, kattr: true)
            end
          end
        end
      end



      ##
      # Ensure there is a transition leading to every non-default state.
      #
      def assert_all_states_are_reachable
        # is there a transition to every state except the default.
        transitions   = @states.map { |_state, opts| opts[:transitions_to] }.flatten.uniq
        adrift_states = (@states.keys - transitions - [@default])
        return if adrift_states.blank?

        states = adrift_states.map { |s| ':' + s.to_s }.to_sentence
        cerr(:transitionless_states_err, states: states, kattr: true)
      end

    end # ConfigurationMethods
  end # Engine
end # StateGate
