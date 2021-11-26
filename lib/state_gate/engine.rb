# frozen_string_literal: true

Dir[File.join(__dir__, 'engine', '*.rb')].sort.each { |file| require file }

module StateGate
  ##
  # = Description
  #
  # Contains a list of the _state-gate_ defined states, allowed transitions and configuration
  # options.
  #
  # The engine is queried by all helper methods to validate states and allowed transitions.
  #
  class Engine

    include Configurator
    include Transitioner
    include Sequencer
    include Errator
    include Scoper
    include Stator
    include Fixer



    # ======================================================================
    # = Private
    # ======================================================================
    private

    # Initialize the engine, setting the Class and attribute for the new engine
    # and parsing the provided configuration.
    #
    #   StateGate::Engine.new(MyKlass, :status) do
    #     ... configuration ...
    #   end
    #
    def initialize(klass, attribute, &config)
      aerror(:klass_type_err)            unless klass.respond_to?(:to_s)
      aerror(:attribute_type_err)        unless attribute.is_a?(Symbol)
      aerror(:missing_config_block_err)  unless block_given?

      @klass     = klass
      @attribute = StateGate.symbolize(attribute)

      set_defaults

      parse_configuration(&config)
    end



    # Set the class variables with default values
    def set_defaults
      @states         = {}
      @default        = nil
      @prefix         = nil
      @suffix         = nil
      @scopes         = true
      @sequential     = false
      @transitionless = false
    end

  end # Engine
end # StateGate
