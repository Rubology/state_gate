# frozen_string_literal: true

module StateGate
  class Engine
    ##
    # = Description
    #
    # Provides transition helper methods for StateGate::Engine.
    #
    module Transitioner

      ##
      # @return [Boolean]
      #   true if every state can transition to every other state, rendering
      #   transitions pointless.
      #
      # @example
      #   .transitionless?  #=> true
      #
      def transitionless?
        !!@transitionless
      end



      ##
      # @return [Hash]
      #   of states and allowed transitions.
      #
      # @example
      #   .transitions  #=> { pending:   [:active],
      #                        ativive:   [:suspended, :archived],
      #                        suspended: [:active, :archived],
      #                        archived:  [] }
      #
      def transitions
        @transitions ||= begin
          transitions = {}
          @states.each { |k, v| transitions[k] = v[:transitions_to] } # rubocop:disable Layout/ExtraSpacing
          transitions
        end
      end



      ##
      # @param [Symbol, String] state
      #   the state name
      #
      # @return [Array]
      #   of allowed transitions for the given state
      #
      # @example
      #   .transitions_for_state(:active) #=> [:suspended, :archived]
      #
      def transitions_for_state(state)
        state_name = assert_valid_state!(state)
        transitions[state_name]
      end



      ##
      # @return [true]
      #   if a transition is allowed
      #
      # @raise [ArgumentError]
      #   if a transition is invalid
      #
      # @example
      #   .assert_valid_transition!(:pending, :active) #=> true
      #   .assert_valid_transition!(:active, :pending) #=> ArgumentError
      #
      def assert_valid_transition!(current_state = nil, new_state = nil)
        from_state = assert_valid_state!(current_state)
        to_state   = assert_valid_state!(new_state)

        return true if to_state == from_state
        return true if to_state.to_s.start_with?('force_')
        return true if @states[from_state][:transitions_to].include?(to_state)

        aerr(:invalid_state_transition_err, from: from_state, to: to_state, kattr: true)
      end

    end # Sequencer
  end # Engine
end # StateGate
