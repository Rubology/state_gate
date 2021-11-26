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
# *States* and *transitions* are provided within a configuration block, enabling
# the _state_gate_ to ensure that only defined *states* are accepted as values
# for the attribute, and that *states* may only transition to allowed *states*.
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
# == Attribute Name
#
# The +attribute_name+ *must* be:
# * a Symbol
# * the name of a database String column attribute
# * not an aliased attribute name
#
#
# == Configuration Options
#
# The configuration defines the state names, allowed transitions and a number of
# options to help customise the _state-gate_ to your exact preference.
#
# Options include:
#
# === | state
# Required name for the new state, supplied as a Symbol. The +state-gate+ requires
# a minimum of two states to be defined.
#     state :state_name
#
#
# [:transitions_to]
#   An optional list of the other state that this state is allowed to change to.
#     state :state_1, transtions_to: [:state_2, :state_3, :state_4]
#     state :state_2, transtions_to: :state_4
#     state :state_3, transtions_to: :any
#     state :state_4
#
# [:human]
#   An optional String name to used when displaying gthe state in a view. If no
#   name is specified, it will default to +:state.titleized+.
#     state :state_1, transtions_to: [:state_2, :state_3], human: "My State"
#
#
# === | default
# Optional setting to specify the default state for a new object. The state name
# is given as a Symbol.
#     default :state_name
#
#
# === | prefix
# Optional setting to add a given Symbol before each state name when using Class Scopes.
# This helps to differential between multiple attributes that have similar state names.
#     prefix :before  # => Class.before_active
#
#
# === | suffix
# Optional setting to add a given Symbol after each state name when using Class Scopes.
# This helps to differential between multiple attributes that have similar state names.
#     suffix :after  # => Class.active_after
#
#
# === | make_sequential
# Optional setting to automatically add transitions from each state to both the
# preceeding and following states.
#     make_sequential
#
# [:one_way]
#   Option to restrict the generated transitions to one directtion only: from each
#   state to the follow state.
#     make_sequential :one_way
#
# [:loop]
#   Option to add transitions from the last state to the first and, unless +:one_way+
#   is specified, also from the first state to the last.
#     make_sequential :one_way, :loop
#
#
# === | no_scopes
# Optional setting to disable the generation of Class Scope helpers methods.
#     no_scopes
#
module StateGate

  ##
  # Configuration Error for reporting issues with the configuration when
  # building a new state machine
  class ConfigurationError < StandardError # :nodoc:
  end

  ##
  # Conflict Error for reporting when a generated method name
  # conflicts with an existing method name
  class ConflictError < StandardError # :nodoc:
  end


  # ======================================================================
  #   Model Public Singleton Methods
  # ======================================================================

  ##
  # Returns the Symbol version of the provided value as long as it responds to
  # +#to_s+ and has no included whitespace in the resulting String.
  #
  # Returns +nil+ if the coversion fails.
  #
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



    # When StateGate is included within a Class, check ActiveRecord is
    # an ancestor and add the 'state_gate' method to the includeing Class
    #
    def included(base) #:nodoc:
      ar_included = base.ancestors.include?(::ActiveRecord::Base)
      fail I18n.t('state_gate.included_err', base: base.name) unless ar_included

      generate_state_gate_method_for(base)
    end
    private_class_method :included



    # Raise an exception when StateGate is 'extend' by another Class, to let
    # the user know that it should be 'included'.
    #
    def extended(base) #:nodoc:
      fail I18n.t('state_gate.extended_err', base: base.name)
    end



    # Calls an instance of StateGate::Builder to generate the
    # 'state_gate' for the Klass attribute.
    #
    def generate_state_gate_method_for(klass)
      klass.define_singleton_method(:state_gate) do |attr_name = nil, &block|
        # Note: the builder does all it's work on initialize, so nothing more
        # to do here.
        StateGate::Builder.new(self, attr_name, &block)
      end
    end

  end # class << self

end # module StateGate
