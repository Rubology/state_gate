# frozen_string_literal: true

module StateGate
  class Builder
    ##
    # = Description
    #
    # Multiple private methods allowing StateGate::Builder to generate
    # transition methods.
    #
    # - query the class for all allowed transitions:
    #     Klass.status_transitions  #=>  { pending:   [:active],
    #                                      active:    [:suspended, :archived],
    #                                      suspended: [:active, :archived],
    #                                      archived:  [] }
    #
    # - query the class for the allowed transitions for the given state:
    #     Klass.status_transitions_for(:pending)  #=>  [:active]
    #     Klass.status_transitions_for(:active)   #=>  [:suspended, :archived]
    #
    # - list the allowed transitions from the current state:
    #     .status_transitions  #=>  [:suspended, :archived]
    #
    # - query if a given transition is allowed from the current state:
    #     .status_transitions_to?(:active)  #=>  true
    #
    module TransitionMethods

      #  Private
      # ======================================================================
      private



      ##
      # Add instance methods to the klass that query the allowed transitions
      #
      def generate_transition_methods
        _add__klass__attr_transitions
        _add__klass__attr_transitions_for

        _add__instance__attr_transitions
        _add__instance__attr_transitions_to

        return unless @alias

        _add__klass__attr_transitions(@alias)
        _add__klass__attr_transitions_for(@alias)

        _add__instance__attr_transitions(@alias)
        _add__instance__attr_transitions_to(@alias)
      end



      # ======================================================================
      #  Class methods
      # ======================================================================

      ##
      # Adds a Class method to return a Hash of the allowed transitions for the attribte
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @example
      #   Klass.status_transitions  #=>  { pending:   [:active],
      #                                     active:    [:suspended, :archived],
      #                                     suspended: [:active, :archived],
      #                                     archived:  [] }
      #
      def _add__klass__attr_transitions(method_name = @attribute)
        method_name = "#{method_name}_transitions"

        add__klass__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}
            stateables[:#{@attribute}].transitions
          end
        ))
      end



      ##
      # Adds a Class method to return an Array of the allowed attribute transitions for
      # the provided state.
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @example
      #   Klass.status_transitions_for(:pending) #=>  [:active]
      #   Klass.status_transitions_for(:active)  #=>  [:suspended, :archived]
      #   Klass.status_transitions_for(:dummy)   #=>  ArgumentError
      #
      def _add__klass__attr_transitions_for(method_name = @attribute)
        method_name = "#{method_name}_transitions_for"

        add__klass__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}(state)
            stateables[:#{@attribute}].transitions_for_state(state)
          end
        ))
      end



      # ======================================================================
      #  Instance methods
      # ======================================================================


      ##
      # Adds an instance method to return an Array of the allowed transitions from
      # the current attribute state.
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @example
      #   .status_transitions  #=>  [:active]
      #   .status_transitions  #=>  [:suspended, :archived]
      #   .status_transitions  #=>  []
      #
      def _add__instance__attr_transitions(method_name = @attribute)
        method_name = "#{method_name}_transitions"

        add__instance__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}
            stateables[:#{@attribute}].transitions_for_state(self[:#{@attribute}])
          end
        ))
      end



      ##
      # Adds an instance method to return TRUE if the current attribute state can
      # transition to the queries status.
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @example
      #   .status_transitions_to?(:active)    #=>  true
      #   .status_transitions_to?(:archived)  #=>  false
      #
      def _add__instance__attr_transitions_to(method_name = @attribute)
        method_name = "#{method_name}_transitions_to?"

        add__instance__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}(query_state)
            test_state = StateGate.symbolize(query_state)
            stateables[:#{@attribute}].transitions_for_state(self[:#{@attribute}])
                                      .include?(test_state)
          end
        ))
      end

    end # TransitionMethods
  end # Builder
end # StateGate
