# frozen_string_literal: true

module StateGate
  class Builder
    ##
    # = Description
    #
    # Multiple private methods enabling StateGate::Builder to generate
    # state functionality.
    #
    # - query the class for all state:
    #     Klass.statuses  #=> [:pending, :active, :archived]
    #
    # - query the class for the human names of all state:
    #     Klass.human_statuses  #=> ['Pending Activation', 'Active', 'Archived']
    #
    # - query the class for an Array of human names/state names for use in a select form:
    #     Klass.statuses_for_select
    #     #=> [['Pending Activation', 'pending'],["Active', 'active'], ['Archived','archived']]
    #
    # - list all attribute states:
    #     .status_states  #=> [:pending, :active, :archived]
    #
    # - list all human names for the attribute states:
    #     .status_human_names  #=> ['Pending Activation', 'Active', 'Archived']
    #
    # - list the human name for the attribute state:
    #     .human_status  #=> 'Pending Activation'
    #
    # - is a particular state set:
    #     .pending?   #=> false
    #     .active?    #=> true
    #     .archived?  #=> false
    #
    # - is a particular state not set:
    #     .not_pending?   #=> true
    #     .not_active?    #=> false
    #     .not_archived?  #=> true
    #
    # - list the allowed transitions for the current state.
    #     .status_transitions  #=> [:suspended, :archived]
    #
    module StateMethods

      #  Private
      # ======================================================================
      private

      ##
      # Add Class and instance methods that allow querying states
      #
      def generate_state_methods
        add_state_attribute_methods
        add_state_alias_methods
      end



      ##
      # add attribute methods
      #
      def add_state_attribute_methods
        _add__klass__attrs
        _add__klass__human_attrs
        _add__klass__attrs_for_select

        _add__instance__attrs
        _add__instance__human_attrs
        _add__instance__human_attr
        _add__instance__state?
        _add__instance__not_state?
        _add__instance__attrs_for_select
      end



      ##
      # add alias methods
      #
      def add_state_alias_methods
        return unless @alias

        _add__klass__attrs(@alias)
        _add__klass__human_attrs(@alias)
        _add__klass__attrs_for_select(@alias)

        _add__instance__attrs(@alias)
        _add__instance__human_attrs(@alias)
        _add__instance__attrs_for_select(@alias)
      end



      # ======================================================================
      #  Class Merthods
      # ======================================================================

      ##
      # Adds a Class method to return an Array of the defined states for the attribute
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @example
      #   Klass.statuses   #=> [:pending, :active, :suspended, :archived]
      #
      def _add__klass__attrs(method_name = @attribute)
        method_name = method_name.to_s.pluralize

        add__klass__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}
            stateables[:#{@attribute}].states
          end
        ))
      end



      ##
      # Adds a Class method to return an Array of the human names of the defined states
      # for the attribute
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @example
      #   Klass.human_statuses   #=> ['Pending Activation', 'Active',
      #                                'Suspended by Admin', 'Archived']
      #
      def _add__klass__human_attrs(method_name = @attribute)
        method_name = "human_#{method_name.to_s.pluralize}"

        add__klass__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}
            stateables[:#{@attribute}].human_states
          end
        ))
      end



      ##
      # Adds a Class method to return an Array of the human and state names for the
      # attribute, suitable for using in a form select statement.
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @option method_name sorted
      #   if TRUE, the array is sorted in alphabetical order by human name
      #   otherwise it is in the order specified
      #
      # @example
      #   Klass.statuses_for_select         #=> [ ['Pending Activation', 'pending'],
      #                                            ['Active', 'active'],
      #                                            ['Suspended by Admin', 'suspended',
      #                                            ['Archived', 'archived'] ]
      #
      #   Klass.statuses_for_select(true)   #=> [ ['Active', 'active'],
      #                                            ['Pending Activation', 'pending'],
      #                                            ['Suspended by Admin', 'suspended',
      #                                            ['Archived', 'archived'] ]
      #
      # @note
      #   States should NEVER be set from direct user selection. This method is
      #   intended for use within search forms, where the user may filter by state.
      #
      def _add__klass__attrs_for_select(method_name = @attribute)
        method_name = "#{method_name.to_s.pluralize}_for_select"

        add__klass__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}(sorted = false)
            stateables[:#{@attribute}].states_for_select(sorted)
          end
        ))
      end



      # ======================================================================
      #  Instance Methods
      # ======================================================================

      ##
      # Adds an Instance method to return Array of the defined states for the attribute
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @example
      #   .statuses   #=> [:pending, :active, :suspended, :archived]
      #
      def _add__instance__attrs(method_name = @attribute)
        method_name = method_name.to_s.pluralize

        add__instance__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}
            stateables[:#{@attribute}].states
          end
        ))
      end



      ##
      # Adds an Instance method to return an Array of the human names for the attribute
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @example
      #   .status_human_states   #=> ['Pending Activation', 'Active',
      #                                'Suspended by Admin', 'Archived']
      #
      def _add__instance__human_attrs(method_name = @attribute)
        method_name = "human_#{method_name.to_s.pluralize}"

        add__instance__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}
            stateables[:#{@attribute}].human_states
          end
        ))
      end



      # Adds an Instance method to return the human name for the attribute's state
      #   eg:
      #       .human_status   #=> 'Suspended by Admin'
      #
      def _add__instance__human_attr(method_name = @attribute)
        method_name = "human_#{method_name.to_s}"

        add__instance__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}
            stateables[:#{@attribute}].human_state_for(#{@attribute})
          end
        ))
      end



      ##
      # Adds an Instance method for each state, returning TRUE if the state is set
      #
      # @example
      #   --> when :active
      #   .active?     #=> true
      #   .archived?   #=> false
      #
      def _add__instance__state?
        @engine.states.each do |state|
          method_name = "#{@engine.scope_name_for_state(state)}?"

          add__instance__helper_method(method_name, __FILE__, __LINE__ - 3, %(
            def #{method_name}
              self[:#{@attribute}] == :#{state}.to_s
            end
          ))
        end
      end



      ##
      # Adds an Instance method for each state, returning TRUE if the state is not set.
      #
      # @example
      #   --> when :active
      #     .not_active?     #=> false
      #     .not_archived?   #=> true
      #
      def _add__instance__not_state?
        @engine.states.each do |state|
          method_name = "not_#{@engine.scope_name_for_state(state)}?"

          add__instance__helper_method(method_name, __FILE__, __LINE__ - 3, %(
            def #{method_name}
              self[:#{@attribute}] != :#{state}.to_s
            end
          ))
        end
      end



      ##
      # Adds a, Instance method to return an Array of the human and state names for the
      # attribute, suitable for using in a form select statement.
      #
      # @param [Symbol] method_name
      #   the name for the new method
      #
      # @option method_name sorted
      #   if TRUE, the array is sorted in alphabetical order by human name
      #   otherwise it is in the order specified
      #
      # @example
      #   .statuses_for_select         #=> [ ['Pending Activation', 'pending'],
      #                                       ['Active', 'active'],
      #                                       ['Suspended by Admin', 'suspended',
      #                                       ['Archived', 'archived'] ]
      #
      #   .statuses_for_select(true)   #=> [ ['Active', 'active'],
      #                                       ['Pending Activation', 'pending'],
      #                                       ['Suspended by Admin', 'suspended',
      #                                       ['Archived', 'archived'] ]
      #
      # @note
      #   States should NEVER be set from direct user selection. This method is
      #   intended for use within search forms, where the user may filter by state.
      #
      def _add__instance__attrs_for_select(method_name = @attribute)
        method_name = "#{method_name.to_s.pluralize}_for_select"

        add__instance__helper_method(method_name, __FILE__, __LINE__ - 2, %(
          def #{method_name}(sorted = false)
            stateables[:#{@attribute}].states_for_select(sorted)
         end
        ))
      end

    end # StateMethods
  end # Builder
end # StateGate
