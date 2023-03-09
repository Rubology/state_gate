# frozen_string_literal: true

module StateGate
  class Builder
    ##
    # = Description
    #
    # Multiple private methods providing error handling functionality for
    # StateGate::Builder.
    #
    module ConflictDetectionMethods

      #  Private
      # ======================================================================
      private

      ##
      # Check if a class method is already defined. Checks are made:
      # 1 --> is it an ActiveRecord dangerous method?
      # 2 --> is it an ActiveRecord defined class method?
      # 3 --> is it a singleton method of the klass?
      # 4 --> is it defined within any of the klass ancestors?
      #
      # @param [Symbol] method_name
      #   the class method name to test for conclict
      #
      # @raise [ConflictError]
      #   if the method name has already been defined
      #
      def detect_class_method_conflict!(method_name)
        defining_klass = _active_record_protected_method?(method_name) ||
                         _klass_singleton_method?(method_name) ||
                         _klass_ancestor_singleton_method?(method_name)

        return unless defining_klass

        raise_conflict_error method_name, type: 'a class', source: defining_klass
      end



      ##
      # Check an instance method is already defined. Checks are made:
      # 1 --> is it an ActiveRecord dangerous method?
      # 2 --> is it an ActiveRecord defined instance method?
      # 3 --> is it an instance method of the klass?
      # 4 --> is it defined within any of the klass ancestors?
      #
      # @param [Symbol] method_name
      #   the instance method name to test for conclict
      #
      # @raise [ConflictError]
      #   if the method name has already been defined
      #
      def detect_instance_method_conflict!(method_name)
        defining_klass = _active_record_protected_method?(method_name) ||
                         _klass_instance_method?(method_name) ||
                         _klass_ancestor_instance_method?(method_name)

        return unless defining_klass

        raise_conflict_error method_name, source: defining_klass
      end



      # Raise a StateGate::ConflictError with a details message of the problem
      #
      # @param [Symbol] method_name
      #   the method name
      #
      # @param [String] type
      #   the optional definition of which type of errors this is: instance or class
      #
      # @param [String] source
      #   the optional class name
      #
      # @raise [ConflictError]
      #   with the message:
      #     StateGate for Klass#attribute will generate a class
      #     method 'statuses', which is already defined by ActiveRecord.
      #
      def raise_conflict_error(method_name, type: 'an instance', source: 'ActiveRecord')
        fail StateGate::ConflictError, I18n.t('state_gate.builder.conflict_err',
                                              klass:       @klass,
                                              attribute:   @attribute,
                                              type:        type,
                                              method_name: method_name,
                                              source:      source)
      end



      ##
      # Check if the method is an ActiveRecord dangerous method name
      #
      # @param [Symbol] method_name
      #   the method name
      #
      def _active_record_protected_method?(method_name)
        'ActiveRecord' if _dangerous_method_names.include?(method_name)
      end



      ##
      # Check if the method is a singleton method of the klass
      #
      # @param [Symbol] method_name
      #   the method name
      #
      def _klass_singleton_method?(method_name)
        @klass.name if @klass.singleton_methods(false).include?(method_name.to_sym)
      end



      ##
      # Check if the method is an ancestral singleton method of the klass
      #
      # @param [Symbol] method_name
      #   the method name
      #
      def _klass_ancestor_singleton_method?(method_name)
        return nil unless @klass.respond_to?(method_name)

        @klass.singleton_class
              .ancestors
              .select { |a| a.instance_methods(false).include?(method_name.to_sym) }
              .first
      end



      ##
      # Check if the method an instance method of the klass
      #
      # @param [Symbol] method_name
      #   the method name
      #
      def _klass_instance_method?(method_name)
        @klass.instance_methods(false).include?(method_name.to_sym) ? @klass.name : nil
      end



      ##
      # Check if the method is an ancestral singleton method of the klass
      #
      # @param [Symbol] method_name
      #   the method name
      #
      def _klass_ancestor_instance_method?(method_name)
        return nil unless @klass.instance_methods.include?(method_name.to_sym)

        @klass.ancestors
              .select { |a| a.instance_methods(false).include?(method_name.to_sym) }
              .first
      end



      ##
      # @return [Array[Symbol]]
      #   array of dagerous methods names found in
      #   ActiveRecord::AttributeMethods::RESTRICTED_CLASS_METHODS (which is called
      #   BLACKLISTED_CLASS_METHODS in 5.0 and 5.1)
      #
      def _dangerous_method_names
        %w[private public protected allocate new name parent superclass]
      end

    end # ConflictDetectionMethods
  end # Builder
end # StateGate
