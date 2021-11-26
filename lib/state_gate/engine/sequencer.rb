# frozen_string_literal: true

module StateGate
  class Engine
    ##
    # = Description
    #
    # Provides state sequence helper methods for StateGate::Engine.
    #
    # All methods raise an error if +sequential?+ is FALSE
    #
    module Sequencer

      # ======================================================================
      #   Configuration Methods
      # ======================================================================

      # Automatically add transitions from each state to the preceeding and following states.
      #   make_sequential
      #
      # [:one_way]
      #   Only adds tranitions from each state to the follow state. (optional)
      #     make_sequential :one_way
      #
      # [:loop]
      #   Adds transitions from the last state to the first and from the first to the last
      #   (unless also :one_way) (optional)
      #     make_sequential :one_way, :loop
      #
      def make_sequential(*args)
        @sequential         = true
        @sequential_loop    = true if args.include?(:loop)
        @sequential_one_way = true if args.include?(:one_way)
      end



      # Add sequence hooks if sequential requested.
      #
      def generate_sequences
        return unless sequential?

        add_previous_sequential_state
        add_next_sequential_state
        loop_sequence
      end # generate_sequences



      # Add the previous sequential state
      #
      def add_previous_sequential_state
        return if @sequential_one_way

        previous_state = nil
        @states.keys.each do |state|
          if previous_state
            @states[state][:previous_state] =  previous_state
            @states[state][:transitions_to] << previous_state
          end
          previous_state = state
        end
      end



      # Add the next sequential state
      #
      def add_next_sequential_state
        next_state = nil
        @states.keys.reverse.each do |state|
          if next_state
            @states[state][:next_state] =      next_state
            @states[state][:transitions_to] << next_state
          end
          next_state = state
        end
      end



      # Add the first and last transitions to complete the sequential loop.
      #
      def loop_sequence
        return unless @sequential_loop

        first_state = @states.keys.first
        last_state  = @states.keys.last

        @states[last_state][:next_state] =      first_state
        @states[last_state][:transitions_to] << first_state

        return if @sequential_one_way

        @states[first_state][:previous_state] =  last_state
        @states[first_state][:transitions_to] << last_state
      end # loop_sequence



      # ======================================================================
      #   Helper Methods
      # ======================================================================

      ##
      # return TRUE if the state_gate is sequential, otherwise FALSE.
      #
      #   .sequential?  # => TRUE
      #
      def sequential?
        !!@sequential
      end

    end # Sequencer
  end # Engine
end # StateGate
