# frozen_string_literal: true

module StateGate
  class Builder
    ##
    # = Description
    #
    # Multiple private methods enabling StateGate::Builder to dynamically
    # generate module, instance and class helper methods.
    #
    module DynamicModuleCreationMethods

      #  Private
      # ======================================================================
      private



      # = Dynamic Module Creation
      # ======================================================================

      ##
      # Dynamically generated module to hold the StateGate helper methods. This
      # keeps a clear distinction between the state machine helper methods and the klass'
      # own methods.
      #
      # The module is named after the class and is created if needed, or reused if exisitng.
      #
      # @note
      #   the module is named "<klass>::StateGate_HelperMethods"
      #
      def _helper_methods_module
        @_helper_methods_module ||= begin
          if @klass.const_defined?('StateGate_HelperMethods')
            "#{@klass}::StateGate_HelperMethods".constantize
          else
            @klass.const_set('StateGate_HelperMethods', Module.new)
            mod = "#{@klass}::StateGate_HelperMethods".constantize
            @klass.include mod
            mod
          end
        end
      end


      #   Method Re-defined Detection
      # ======================================================================


      ##
      # Adds the hook method :method_added to the Klass, detecting any new method
      # definitions for an attribute already defined as a StateGate.
      #
      # If a matching method is discoverd, it adds a warning to logger, if defined,
      # otherwise it outputs the warning to STDOUT via `puts`
      #
      # method_name - the name of the newly defined method.
      #
      # @note
      #   This method is added last so it does not trigger when StateGate adds
      #   the attribute methods.
      #
      # meta
      #
      # - loop though each state machine attribute.
      #   - does the new defined method use 'attr' or 'attr='?
      #     - if so then record an error logger if denied, othewise use `puts`
      #
      def _generate_method_redefine_detection # rubocop:disable Metrics/MethodLength
        @klass.instance_eval(%(
          def method_added(method_name)
            stateables.keys.each do |attr_name|
              if method_name&.to_s == attr_name ||
                 method_name&.to_s == "\#{attr_name}="

                msg  = "WARNING! \#{self.name}#\#{attr_name} is a defined StateGate and"
                msg += " redefining :\#{method_name} may cause conflict."

                logger ? logger.warn(msg) : puts("\n\n\#{msg}\n\n")
              end

              super(method_name)
            end
          end
        ), __FILE__, __LINE__ - 15)
      end



      #   Method Creation
      # ======================================================================

      ##
      # Add an Class helper method to the _helper_methods_module
      #
      # @param [String] method_name
      #   name for the method to check for conflicts
      #
      # @param [String] file
      #   file name for error reporting
      #
      # @param [String,Integer] line
      #   line number for error reporting
      #
      # @param [String] method_body
      #   a String to be evaluated in the module
      #
      def _add__klass__helper_method(method_name, file, line, method_body)
        _detect_class_method_conflict!(method_name)
        @klass.instance_eval(method_body, file, line)
      end



      ##
      # Add an instance helper method to the _helper_methods_module
      #
      # @param [String] method_name
      #   name for the method to check for conflicts
      # @param [String] file
      #   file name for error reporting
      # @param [String] line
      #   line number for error reporting
      # @param [String] method_body
      #   a String to bhe evaluates in the module
      #
      def _add__instance__helper_method(method_name, file, line, method_body)
        _detect_instance_method_conflict!(method_name)
        _helper_methods_module.module_eval(method_body, file, line)
      end

    end # DynamicModuleCreationMethods
  end # Builder
end # StateGate
