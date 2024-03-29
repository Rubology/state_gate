# frozen_string_literal: true

module StateGate
  class Engine
    ##
    # = Description
    #
    # Adds error reporting methods to a StateMachine::Engine
    # - all error messages are I18n configured
    # - method names are deliberately short to encourage code readability with
    #   if/unless one-liners
    module Errator

      #  Private
      # ======================================================================
      private

      ##
      # Format the given value and report an ArgumentError
      #
      # @param [String]
      #   the error message
      #
      # @raise [ArgumentError]
      #
      def _invalid_state_error(val)
        case val
        when NilClass
          _aerr :invalid_state_err, val: "'nil'", kattr: true
        when Symbol
          _aerr :invalid_state_err, val: ":#{val}", kattr: true
        else
          _aerr :invalid_state_err, val: "'#{val&.to_s}'", kattr: true
        end
      end



      ##
      # Report a ConfigurationError, including the Klass#attr variable.
      #
      # @param [Symbol] err
      #   the I18n error message key
      #
      # @param [Hash] args
      #   arguments to be included in the error
      #
      # @raise [ConfigurationError]
      #
      def _cerr(err, **args)
        args[:kattr] = "#{@klass}##{@attribute}" if args[:kattr] == true
        key          = "state_gate.engine.config.#{err}"
        fail ConfigurationError, I18n.t(key, **args)
      end



      ##
      # Report a RuntimeError, including the Klass#attr variable.
      #
      # @param [Symbol] err
      #   the I18n error message key
      #
      # @param [Hash] args
      #   arguments to be included in the error
      #
      # @raise [RuntimeError]
      #
      def _rerr(err, **args)
        args[:kattr] = "#{@klass}##{@attribute}" if args[:kattr] == true
        key          = "state_gate.engine.#{err}"
        fail I18n.t(key, **args)
      end



      ##
      # Report an ArgumentError, including the Klass#attr variable.
      #
      # @param [Symbol] err
      #   the I18n error message key
      #
      # @param [Hash] args
      #   arguments to be included in the error
      #
      # @raise [ArgumentError]
      #
      def _aerr(err, **args)
        args[:kattr] = "#{@klass}##{@attribute}" if args[:kattr] == true
        key          = "state_gate.engine.#{err}"
        fail ArgumentError, I18n.t(key, **args)
      end

    end # Errator
  end # Engine
end # StateGate
