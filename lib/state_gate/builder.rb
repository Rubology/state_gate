# frozen_string_literal: true

require_relative  'engine'
require_relative  'type'
Dir[File.join(__dir__, 'builder', '*.rb')].sort.each { |file| require file }

module StateGate
  ##
  # = Description
  #
  # Responsible for generating the state gate engine, along
  # with the Class and Instance helper methods for the submitted Klass. Everything is
  # generated from +#initialize+ when a new instance is created.
  #
  # Both Class and Instance methods are generated for:
  #
  # - state interaction
  # - state sequences
  # - state scopes
  # - transition interaction
  # - transition validation
  #
  class Builder

    include StateMethods
    include ScopeMethods
    include TransitionMethods
    include ConflictDetectionMethods
    include TransitionValidationMethods
    include DynamicModuleCreationMethods



    #  Private
    # ======================================================================
    private

    ##
    # Initialize the Builder, creating the state gate and generating all the
    # Class and Instace helper methods on the sumbitted klass.
    #
    # @param [Class] klass
    #   The class containing the attribute to be cast as a state gate
    #
    # @param [Symbol] attribute_name
    #   The name of the database attribute to use for the state gate
    #
    # @block config
    #   The configuration block for the state gate.
    #
    # @example
    #   StateGate::Builder.new(Klass, :attribute_name) do
    #       ... configuration ...
    #   end
    #
    def initialize(klass = nil, attribute_name = nil, &config)
      @klass     = klass
      @attribute = attribute_name
      @alias     = nil

      # assert the input is valid
      _assert_klass_is_valid_for_state_gate
      _parse_atttribute_name_for_alias
      _assert_no_existing_state_gate_for_attribute
      _assert_attribute_name_is_a_database_string_column

      # build the engine and cast the attribute
      _build_state_gate_engine(&config)
      _cast_attribute_as_state_gate

      # generate the helper methods
      generate_helper_methods
    end



    # Generate the helper methods
    #
    def generate_helper_methods
      # add the helper methods
      generate_scope_methods
      generate_state_methods
      generate_transition_methods
      generate_transition_validation_methods

      # warn if any state gate attribute methods are redefined
      _generate_method_redefine_detection
    end



    ##
    # Validate the klass to ensure it is a 'Class' and derived from ActiveRecord,
    # raising an error if not.
    #
    def _assert_klass_is_valid_for_state_gate
      err(:non_class_err, klass: true) unless @klass.is_a?(Class)
      err(:non_ar_err, klass: true) unless @klass.ancestors.include?(::ActiveRecord::Base)
    end



    ##
    # Parse the attribute name to ensure it is a valid input value and
    # detect if it's an attribute_alias.
    #
    # = meta
    #
    # - ensure it exists
    # - ensure it's a Symbol, to avoid string whitespace issues
    # - check is it's a registere attribute
    #   - update @attribute & @alias
    #
    def _parse_atttribute_name_for_alias
      if @attribute.nil?
        err :missing_attribute_err, klass: true

      elsif !@attribute.is_a?(Symbol)
        err :attribute_type_err

      elsif @klass.attribute_aliases[@attribute.to_s]
        @alias     = @attribute
        @attribute = @klass.attribute_aliases[@attribute.to_s].to_sym
      end
    end



    ##
    # Validate we don't already have a state gate defined for the attribute,
    # raising an error if not.
    #
    def _assert_no_existing_state_gate_for_attribute
      return unless @klass.methods(false).include?(:stateables)
      return unless @klass.stateables.keys.include?(@attribute)

      err :existing_state_gate_err, kattr: true
    end # parse_attribute_name



    ##
    # Validate the attribute is a database String attribute,
    # raising an error if not.
    #
    # = meta
    #
    # - ensure it's mapped to a database column
    # - ensure it's a :string databse type
    #
    def _assert_attribute_name_is_a_database_string_column
      if @klass.column_names.exclude?(@attribute.to_s)
        err :non_db_attr_err, kattr: true

      elsif @klass.columns_hash[@attribute.to_s].type != :string
        err :non_string_column_err, kattr:     true,
                                    attr_type: @klass.columns_hash[@attribute.to_s].type
      end
    end # parse_attribute_name



    ##
    # Builds a StateGate::Engine for the given attribute and add it to
    # the :stateables repository.
    #
    # @block config
    #   the user generated configuration for the engine, including states,
    #           transitions and optional settings
    #
    def _build_state_gate_engine(&config)
      _initialize_state_gate_repository
      @engine = StateGate::Engine.new(@klass.name, @attribute, &config)
      @klass.stateables[@attribute] = @engine # rubocop:disable Layout/ExtraSpacing
    end



    ##
    # Adds a :stateables class_attribute if it doesn't already exist and
    # initializes it to an empty Hash.
    #
    # :stateables contains is a repository for the state gate engines
    # created when generating state gates. The state gate attribute name is used
    # as the key.
    #
    # @example
    #     Klass.stateables #=> {
    #                                         status:   <StateGate::Engine>,
    #                                         account:  <StateGate::Engine>
    #                                       }
    #
    # @note
    #   The default empty Hash is set after the attribute is created to accommodate
    #   ActiveRecord 5.0, even though ActiveRecord 6.0 allows it to be set within
    #   the .class_attribute method.
    #
    def _initialize_state_gate_repository
      return if @klass.methods(false).include?(:stateables)

      @klass.class_attribute(:stateables, instance_writer: false)
      @klass.stateables = {}
    end



    ##
    # Builds a StateGate::Type with the custom states for the attribute,
    # then casts the attribute.
    #
    # This ensures that regardless of the setter method used to set a new state, even
    # if transition validations are disabled, an invalid state should never reach the
    # database.
    #
    # meta
    #
    # - retrieve the root attribute name if the supplied attribute is an alias.
    # - create a StateGate::Type with attributes states.
    # - overwrite the attribute, casting the type as the new StateGate::Type
    #
    def _cast_attribute_as_state_gate
      states    = @engine.states
      attr_type = StateGate::Type.new(@klass.name, @attribute, states)
      @klass.attribute(@attribute, attr_type, default: @engine.default_state)
    end



    ##
    # Raise an ArgumentError for the given error, using I18n for the message.
    #
    # @param [Symbol] err
    #   the Symbol key for the I18n message
    #
    # @param [Hash] args
    #   Hash of attributes to pass to the message string.
    #
    # @option args :klass
    #   When present, args[:klass] will be updated with the 'KlassName'.
    # @option args :kattr
    #   When true, args[:kattr] will be updated with 'KlassName#attribute'.
    #
    # @example
    #     err(:invalid_attribute_type_err, kattr: true)
    #
    def err(err, **args)
      args[:klass] = @klass                    if args.dig(:klass) == true
      args[:kattr] = "#{@klass}##{@attribute}" if args.dig(:kattr) == true

      fail ArgumentError, I18n.t("state_gate.builder.#{err}", **args)
    end

  end # class Builder
end # module StateGate
