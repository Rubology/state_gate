# frozen_string_literal: true

module StateGate
  ##
  # = Description
  #
  # ActiveRecord::Type to cast a model attribute as a StateGate,
  # mapping to a string database column.
  #
  # Ensures that any string written to, or read from, the database is a valid +state+,
  # otherwise it raises an exception.
  #
  # This class is has an internal API for ActiveRecord and is not intended for public use.
  #
  # @private
  #
  class Type < ::ActiveModel::Type::String

    ##
    # ensure the value is a legitimate state and return a downcased string
    #
    def cast(value) # :nodoc:
      assert_valid_value(value)
      cast_value(value)
    end



    ##
    # Return TRUE if the value is serializable, otherwise FASLE.
    #
    # a value is serializable if it can be coerced to a String
    #
    def serializable?(value) # :nodoc:
      value.to_s
    rescue NoMethodError
      false
    end



    ##
    # Return a downcased String of the given value, providing it is a legitimate state.
    #
    def serialize(value) # :nodoc:
      assert_valid_value(value)
      value.to_s.downcase.remove(/^force_/)
    end



    ##
    # Convert a nil DB value to the default state.
    #
    def deserialize(value) # :nodoc:
      return value if value

      klass.constantize.stateables[name].default_state
    end



    ##
    # Raise an exception unless the value is both serializable and a legitimate state
    #
    def assert_valid_value(value) # :nodoc:
      return if serializable?(value) && states.include?(value.to_s.downcase.remove(/^force_/))

      case value
      when NilClass
        fail ArgumentError, "'nil' is not a valid state for #{@klass}##{@name}."
      when Symbol
        fail ArgumentError, ":#{value} is not a valid state for #{@klass}##{@name}."
      else
        fail ArgumentError, "'#{value&.to_s}' is not a valid state for #{@klass}##{@name}."
      end
    end



    ##
    # Returns TRUE if the other class is equal, otherewise FALSE.
    #
    # Equality matches on Class, name and states(in the given order)
    #
    def ==(other) # :nodoc:
      return false unless self.class == other.class
      return false unless klass      == other.send(:klass)
      return false unless name       == other.send(:name)
      return false unless states     == other.send(:states)

      true
    end
    alias eql? ==



    ##
    # Returns a unique hash value
    #
    def hash # :nodoc:
      [self.class, klass, name, states].hash
    end



    # ======================================================================
    # = Private
    # ======================================================================
    private

    attr_reader :klass, :name, :states


    ##
    # initialize and set the class variables
    #
    def initialize(klass, name, states) # :nodoc:
      @klass  = klass
      @name   = name
      @states = states.map(&:to_s)
    end


    ##
    # convert the value to lowercase and remove and 'force_' prefix
    #
    def cast_value(value)
      value.to_s.downcase.remove(/^force_/)
    end
  end # class Type
end # StateGate
