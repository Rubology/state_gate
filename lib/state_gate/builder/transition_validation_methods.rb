# frozen_string_literal: true

module StateGate
  class Builder
    ##
    # = Description
    #
    # Multiple private methods allowing StateGate::Builder to generate
    # attribute setter methods for transition validation.
    #
    # - initializing the attribute with +Class.new+ :
    #     Klass.new(status: :active)  #=> ArgumentError
    #
    # - initializing the attribute with +Class.create+ :
    #     Klass.create(status: :active)  #=> ArgumentError
    #
    # - initializing the attribute with <tt>Class.create!</tt> :
    #     Klass.create!(status: :active)  #=> ArgumentError
    #
    # - setting the attribute with +attr=+ :
    #     .status = :active    #=> :active
    #     .status = :archived  #=> ArgumentError
    #
    # - setting the attribute with <tt>[:attr]=</tt> :
    #     [:status] = :active    #=> :active
    #     [:status] = :archived  #=> ArgumentError
    #
    # - setting the attribute with <tt>attributes=</tt> :
    #     .attrubutes = {status: :active}    #=> :active
    #     .attributes = {status: :archived } #=> ArgumentError
    #
    # - setting the attribute with <tt>assign_attributes</tt> :
    #     .assign_attrubutes(status: :active)    #=> :active
    #     .assign_attributes(status: :archived)  #=> ArgumentError
    #
    # - updating the attribute with <tt>Class.update</tt> :
    #     Klass.update(instance.id, status: :active)    #=> :active
    #     Klass.update(instance.id, status: :archived)  #=> ArgumentError
    #
    # - updating the attribute with <tt>.update</tt> :
    #     .update(status: :active)    #=> :active
    #     .update(status: :archived)  #=> ArgumentError
    #
    # - updating the attribute with <tt>.update_column</tt> :
    #     .update_column(:status, :active)    #=> :active
    #     .update_column(:status, :archived)  #=> ArgumentError
    #
    # - updating the attribute with <tt>.update_columns</tt> :
    #     .update_columns(status: :active)    #=> :active
    #     .update_columns(status: :archived)  #=> ArgumentError
    #
    # - updating the attribute with <tt>.write_attribute</tt> :
    #     .write_attribute(:status, :active)    #=> :active
    #     .write_attribute(:status, :archived)  #=> ArgumentError
    #
    #
    # === | Forcing a change
    #
    # To force a status change that would otherwise be prohibited, preceed the
    # new state with +force_+ :
    #   .status = :archived         #=> ArgumentError
    #   .status = :force_archived   #=> :archived
    #
    module TransitionValidationMethods

      #  Private
      # ======================================================================
      private



      ##
      # Add prepended instance methods to the klass that catch all methods for
      # updating the attribute and validated the new value is an allowed transition
      #
      # @note
      #   These methods are only added if the engine has an
      #   include_transition_validations? status on initialisation
      #
      # @note
      #   The three methods "<atrr>=(val)", "write_attribute(<attr>, val)" and
      #   "update_columns(<attr>: val)" cover all the possibilities of setting the
      #   attribute through ActiveRecord.
      #
      def generate_transition_validation_methods
        return if @engine.transitionless?

        _prepend__attribute_equals
        _prepend__write_attribute
        _prepend__update_columns
        _prepend__initialize
      end



      # ======================================================================
      #  Prepend Module
      # ======================================================================

      ##
      # Dynamically generated module to hold the validation setter methods
      # and is pre-pended to the class.
      #
      # A new module is create if it doesn't already exist.
      #
      # @note
      #   the module is named "StateGate::<klass>TranstionValidationMethods"
      #
      def _transition_validation_module # rubocop:disable Metrics/MethodLength
        @_transition_validation_module ||= begin
          mod_name = 'StateGate_ValidationMethods'

          if @klass.const_defined?(mod_name)
            "#{@klass}::#{mod_name}".constantize
          else
            @klass.const_set(mod_name, Module.new)
            mod = "#{@klass}::#{mod_name}".constantize
            @klass.prepend mod
            mod
          end
        end
      end



      # ======================================================================
      #  Instance methods
      # ======================================================================

      ##
      # Adds a method to overwrite the attribute :<attr>=(val) setter, raising an error
      # if the supplied value is not a valid transition
      #
      # @example
      #   .status = :archived  #=> ArgumentError
      #   .status - :active    #=> :active
      #
      # ==== actions
      #
      # - assert it's a valid transition
      # - call super
      #
      def _prepend__attribute_equals
        attr_name = @attribute

        _transition_validation_module.module_eval(%(
          def #{attr_name}=(new_val)
            stateables[StateGate.symbolize(:#{attr_name})] \
                &.assert_valid_transition!(self[:#{attr_name}], new_val)
            super(new_val)
          end
        ), __FILE__, __LINE__ - 6)
      end



      ##
      # Adds a method to overwrite the instance :write_attribute(attr, val) setter,
      # raising an error if the supplied value is not a valid transition
      #
      # @example
      #   .write_attribute(:status, :archived)  #=> ArgumentError
      #   .write_attribute(:status, :active)    #=> :active
      #
      # ==== actions
      #
      # - loop through each attribute
      # - get the base attribute name from any alias used
      # - assert it's a valid transition
      # - call super
      #
      def _prepend__write_attribute
        return if _transition_validation_module.method_defined?(:write_attribute)

        _transition_validation_module.module_eval(%(
          def write_attribute(attrribute_name, new_val = nil)
            name = attrribute_name.to_s.downcase
            name = self.class.attribute_aliases[name] || name

            stateables[StateGate.symbolize(name)] \
                &.assert_valid_transition!(self[name], new_val)
            super(attrribute_name, new_val)
          end
        ), __FILE__, __LINE__ - 9)
      end



      ##
      # Adds a method to overwrite the instance :update_columns(attr: val) setter,
      # raising an error if the supplied value is not a valid transition
      #
      # @example
      #   .update_columns(status: :archived)  #=> ArgumentError
      #   .update_columns(status: :active)    #=> :active
      #
      # ==== actions
      #
      # - loop through each attribute
      # - get the base attribute name from any alias used
      # - assert it's a valid transition
      # - call super
      #
      def _prepend__update_columns # rubocop:disable Metrics/MethodLength
        return if _transition_validation_module.method_defined?(:update_columns)

        _transition_validation_module.module_eval(%(
          def update_columns(args)
            super(args) and return if (new_record? || destroyed?)

            args.each do |key, value|
              name = key.to_s.downcase
              name = self.class.attribute_aliases[name] || name

              stateables[StateGate.symbolize(name)] \
                  &.assert_valid_transition!(self[name], value)
            end

            super
          end
        ), __FILE__, __LINE__ - 14)
      end



      ##
      #Prepends an :itialize method to ensure the attribute is not set on initializing
      # a new instance unless :forced.
      #
      # @example
      #   Klass.new(status: :archived)  #=> ArgumentError
      #
      def _prepend__initialize # rubocop:disable Metrics/MethodLength
        return if _transition_validation_module.method_defined?(:initialize)

        _transition_validation_module.module_eval(%(
          def initialize(attributes = nil, &block)
            attributes&.each do |attr_name, value|
              key = self.class.attribute_aliases[attr_name.to_s] || attr_name
              if self.stateables.keys.include?(key.to_sym)
                unless value.to_s.start_with?('force_')
                  msg = ":\#{attr_name} may not be included in the parameters for a new" \
                  " \#{self.class.name}.  Create the new instance first, then transition" \
                  " :\#{attr_name} as required."
                  fail ArgumentError, msg
                end
              end
            end

            super
          end
        ), __FILE__, __LINE__ - 13)
      end

    end # LockingMethods
  end # Builder
end # StateGate
