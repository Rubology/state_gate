# frozen_string_literal: true

require_relative  'state_gate/builder'


I18n.load_path << File.expand_path('state_gate/locale/engine_en.yml', __dir__)
I18n.load_path << File.expand_path('state_gate/locale/builder_en.yml', __dir__)
I18n.load_path << File.expand_path('state_gate/locale/state_gate_en.yml', __dir__)


##
# = StateGate
#
# Builds and attaches a _StateGate::Engine_  to the desired ActiveRecord String
# attribute.
#
# _States_ and _transitions_ are provided within a configuration block, enabling
# the _state-gate_ to ensure that only defined _states_ are accepted as values
# for the attribute, and that _states_ may only transition to other allowed _states_.
#
#   Class User
#     include StateGate
#
#     state_gate :attribute_name do
#       ... configuration ...
#     end
#   end
#
#
# == The Attribute Name
#
# The +attribute_name+ *must* be:
# - a Symbol
# - the name of a database String column attribute
# - not an aliased attribute name
#
#
# == Configuration Options
#
# The configuration defines the state names, allowed transitions and a number of
# options to help customise the _state-gate_ to your exact preference.
#
# Options include:
#
# [state]
#   Required name for the new state, supplied as a Symbol. The `state-gate` requires
#   a minimum of two states to be defined.
#     state :state_name
#
#
#   **_:transitions_to_**
#     An optional list of the other state that this state is allowed to change to.
#       state :state_1, transtions_to: [:state_2, :state_3, :state_4]
#       state :state_2, transtions_to: :state_4
#       state :state_3, transtions_to: :any
#       state :state_4
#
#   **_:human_**
#     An optional String name to used when displaying gthe state in a view. If no
#     name is specified, it will default to +:state.titleized+.
#       state :state_1, transtions_to: [:state_2, :state_3], human: "My State"
#
#
# [default]
#   Optional setting to specify the default state for a new object. The state name
#   is given as a Symbol.
#       default :state_name
#
#
# [prefix]
#   Optional setting to add a given Symbol before each state name when using Class Scopes.
#   This helps to differential between multiple attributes that have similar state names.
#       prefix :before  #=> Class.before_active
#
#
# [suffix]
#   Optional setting to add a given Symbol after each state name when using Class Scopes.
#   This helps to differential between multiple attributes that have similar state names.
#       suffix :after  #=> Class.active_after
#
#
# [make_sequential]
#   Optional setting to automatically add transitions from each state to both the
#   preceeding and following states.
#       make_sequential
#
#   **_:one_way_**
#     Option to restrict the generated transitions to one directtion only: from each
#     state to the follow state.
#       make_sequential :one_way
#
#   **_:loop_**
#     Option to add transitions from the last state to the first and, unless +:one_way+
#     is specified, also from the first state to the last.
#       make_sequential :one_way, :loop
#
#
# [no_scopes]
#   Optional setting to disable the generation of Class Scope helpers methods.
#       no_scopes
#
module StateGate

  ##
  # Configuration Error for reporting an invalid configuration when
  # building a new _state-gate_
  #
  class ConfigurationError < StandardError
  end



  ##
  # Conflict Error for reporting a generated method name
  # conflicting with an existing method name
  #
  class ConflictError < StandardError
  end


  # ======================================================================
  #   Model Public Singleton Methods
  # ======================================================================

  ##
  # Returns the Symbol version of the provided value as long as it responds to
  # _#to_s_ and has no included whitespace in the resulting String.
  #
  # @param [String, #to_s] val
  #   the string to convert in to a Symbol
  #
  # @return [Symbol]
  #   the converted string
  #
  # @return [nil]
  #   if the string cannot be converted
  #
  # @example
  #   StateGate.symbolize('Test')    #=> :test
  #
  #   StateGate.symbolize(:Test)     #=> :test
  #
  #   StateGate.symbolize('My Test') #=> nil
  #
  #   StateGate.symbolize('')        #=> nil
  #
  def self.symbolize(val)
    return nil if     val.blank?
    return nil unless val.respond_to?(:to_s)
    return nil unless val.to_s.remove(/\s+/) == val.to_s

    val.to_s.downcase.to_sym
  end



  # ======================================================================
  #   Module Private Singleton methods
  # ======================================================================

  class << self


    #   Private
    # ======================================================================
    private



    ##
    # When StateGate is included within a Class, check ActiveRecord is
    # an ancestor and add the 'state_gate' method to the including Class
    #
    # @param [Class]
    #   the Class that is including this module
    #
    def included(base)
      ar_included = base.ancestors.include?(::ActiveRecord::Base)
      fail I18n.t('state_gate.included_err', base: base.name) unless ar_included

      _generate_state_gate_method_for(base)
    end
    private_class_method :included



    ##
    # Raise an exception when StateGate is 'extend' by another Class, to let
    # the user know that it should be 'included'.
    #
    # @param [Class]
    #   the Class that is extending this module
    #
    # @raise [RuntimeErrror]
    #   this module should _never_ be added through extension
    #
    def extended(base)
      fail I18n.t('state_gate.extended_err', base: base.name)
    end



    ##
    # Calls an instance of StateGate::Builder to generate the
    # _state_gate_ for the Klass attribute.
    #
    # @param [Class]
    #   the Class the _state-gate_ is being attached to
    #
    def _generate_state_gate_method_for(klass)
      klass.define_singleton_method(:state_gate) do |attr_name = nil, &block|
        # Note: the builder does all it's work on initialize, so nothing more
        # to do here.
        StateGate::Builder.new(self, attr_name, &block)
      end
    end

  end # class << self

end # module StateGate
