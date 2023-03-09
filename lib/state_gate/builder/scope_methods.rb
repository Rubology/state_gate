# frozen_string_literal: true

module StateGate
  class Builder
    ##
    # = Description
    #
    # Multiple private methods enabling StateGate::Builder to generate
    # scopes for each state.
    #
    # - fetch all records with the given state:
    #     Klass.active #=> Klass.where(state: :active)
    #
    # - fetch all records without the given state:
    #     Klass.not_active #=> Klass.where.not(state: :active)
    #
    # - fetch all records with the supplied states:
    #     Klass.with_statuses(:pending, :active) #=> Klass.where(state: [:pending, :active])
    #
    module ScopeMethods

      # = Private
      # ======================================================================
      private


      ##
      # Add scopes to the klass for filtering by state
      #
      # @note
      #   The scope name is a concatenation of <prefix><state name><suffix>
      #
      def _generate_scope_methods
        return unless @engine.include_scopes?

        _add__klass__state_scopes
        _add__klass__not_state_scopes
        _add__klass__with_attrs_scope

        _add__klass__with_attrs_scope(@alias) if @alias
      end



      # ======================================================================
      #  Klass methods
      # ======================================================================

      ##
      # Add a klass method that scopes records to the specified state.
      #
      # @example
      #   Klass.active         #=> ActiveRecord::Relation
      #   Klass.active_status  #=> ActiveRecord::Relation
      #
      def _add__klass__state_scopes
        attr_name = @attribute

        @engine.states.each do |state|
          scope_name = @engine.scope_name_for_state(state)
          _detect_class_method_conflict! scope_name
          @klass.scope(scope_name, -> { where(attr_name => state) })
        end # each state
      end # _add__klass__state_scopes



      ##
      # Add a klass method that scopes records to those without the specified state.
      #
      # @example
      #   Klass.not_active         #=> ActiveRecord::Relation
      #   Klass.not_active_status  #=> ActiveRecord::Relation
      #
      def _add__klass__not_state_scopes
        attr_name = @attribute

        @engine.states.each do |state|
          scope_name = @engine.scope_name_for_state(state)
          _detect_class_method_conflict! "not_#{scope_name}"
          @klass.scope "not_#{scope_name}", -> { where.not(attr_name => state) }
        end # each state
      end # _add__klass__not_state_scopes



      ##
      # Add a klass method that scopes records to the given states.
      #
      # @param [Symbol] method_name
      #   the method name for the new scope
      #
      # @example
      #   Klass.with_statuses(:active, :pending) #=> ActiveRecord::Relation
      #
      def _add__klass__with_attrs_scope(method_name = @attribute)
        attr_name   = @attribute
        method_name = "with_#{method_name.to_s.pluralize}"

        _detect_class_method_conflict! method_name
        @klass.scope method_name, ->(states) { where(attr_name => Array(states)) }
      end # _add__klass__with_attrs_scope

    end # LockingMethods
  end # Builder
end # StateGate
