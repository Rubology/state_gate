# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Engine Configurator" do
  context "on success with defined transitions" do
    let!(:eng) do
      StateGate::Engine.new('EngineTest', :status) do
        state :pending,   transitions_to: :active, human: 'Pending Activation'
        state :active,    transitions_to: [:suspended, :archived]
        state :suspended, transitions_to: [:active, :archived],   human: 'Suspended by Admin'
        state :archived

        make_sequential :one_way, :loop

        default :active

        prefix :test_prefix
        suffix :test_suffix

        no_scopes
      end
    end


    context "state" do
      it "adds the correct states" do
        expect(eng.raw_states.keys).to eq [:pending, :active, :suspended, :archived]
      end

      it "adds the the corrct human name" do
        expect(eng.raw_states[:pending][:human]).to eq "Pending Activation"
        expect(eng.raw_states[:suspended][:human]).to eq 'Suspended by Admin'
      end

      it "adds the the corrct transitions" do
        expect(eng.raw_states[:pending][:transitions_to]).to eq [:active]
        expect(eng.raw_states[:active][:transitions_to]).to eq [:suspended, :archived]
        expect(eng.raw_states[:suspended][:transitions_to]).to eq [:active, :archived]
        expect(eng.raw_states[:archived][:transitions_to]).to eq [:pending]
      end
    end # state


    context "make_sequential" do
      it "sets the :sequential flag correcty" do
        expect(eng.instance_variable_get(:@sequential)).to eq true
      end

      it "sets the :sequential_one_way flag correctly" do
        expect(eng.instance_variable_get(:@sequential_one_way)).to eq true
      end

      it "sets the :sequential_loop flag correctly" do
        expect(eng.instance_variable_get(:@sequential_loop)).to eq true
      end
    end #  "make_sequential"


    context "default_state" do
      it "sets the correct default state" do
        expect(eng.default_state).to eq :active
      end
    end


    context "prefix" do
      it "set the correct prefix" do
        expect(eng.state_prefix).to eq "test_prefix_"
      end
    end


    context "suffix" do
      it "set the correct suffix" do
        expect(eng.state_suffix).to eq "_test_suffix"
      end
    end


    context "no_scopes" do
      it "clears the :scopes flag" do
        expect(eng.instance_variable_get(:@scopes)).to eq false
      end
    end
  end # "on success with defined transitions"



  context "on success when transitionless" do
    let!(:eng) do
      StateGate::Engine.new('EngineTest', :status) do
        state :pending,   human: 'Pending Activation'
        state :active
        state :suspended, human: 'Suspended by Admin'
        state :archived
      end
    end


    context "state" do
      it "adds the correct states" do
        expect(eng.raw_states.keys).to eq [:pending, :active, :suspended, :archived]
      end

      it "adds the the corrct human name" do
        expect(eng.raw_states[:pending][:human]).to eq "Pending Activation"
        expect(eng.raw_states[:suspended][:human]).to eq 'Suspended by Admin'
      end

      it "adds the the corrct transitions" do
        expect(eng.raw_states[:pending][:transitions_to]).to eq   [:active, :suspended, :archived]
        expect(eng.raw_states[:active][:transitions_to]).to eq    [:pending, :suspended, :archived]
        expect(eng.raw_states[:suspended][:transitions_to]).to eq [:pending, :active, :archived]
        expect(eng.raw_states[:archived][:transitions_to]).to eq  [:pending, :active, :suspended]
      end
    end # state
  end # "on success when transitionless"



  context "on success with :any transitions" do
    let!(:eng) do
      StateGate::Engine.new('EngineTest', :status) do
        state :pending,   transitions_to: :any, human: 'Pending Activation'
        state :active,    transitions_to: :any
        state :suspended, transitions_to: :any, human: 'Suspended by Admin'
        state :archived,  transitions_to: :any
      end
    end


    context "state" do
      it "adds the correct states" do
        expect(eng.raw_states.keys).to eq [:pending, :active, :suspended, :archived]
      end

      it "adds the the corrct human name" do
        expect(eng.raw_states[:pending][:human]).to eq "Pending Activation"
        expect(eng.raw_states[:suspended][:human]).to eq 'Suspended by Admin'
      end

      it "adds the the corrct transitions" do
        expect(eng.raw_states[:pending][:transitions_to]).to eq   [:active, :suspended, :archived]
        expect(eng.raw_states[:active][:transitions_to]).to eq    [:pending, :suspended, :archived]
        expect(eng.raw_states[:suspended][:transitions_to]).to eq [:pending, :active, :archived]
        expect(eng.raw_states[:archived][:transitions_to]).to eq  [:pending, :active, :suspended]
      end
    end # state
  end # "on success with :any transitions"




  #   on failure
  # ======================================================================

  context "on failure" do
    context "with an invalid command" do
      it "raises an exception" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active

            dummy
          end
        }.to raise_error StateGate::ConfigurationError, \
                         "'dummy' is not a valid configuration option."
      end
    end # "with an invalid command"


    context "state" do
      it "raises an exception with a non-Symbol state" do
        allow(StateGate).to receive(:symbolize).with(anything()).and_call_original
        allow(StateGate).to receive(:symbolize).with('pending'){'pending'}
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state 'pending'
          end
        }.to raise_error StateGate::ConfigurationError, \
                         "states for EngineTest#status must be a Symbol."
      end

      it "raises an exception with a duplicate state" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :active
            state :active
          end
        }.to raise_error StateGate::ConfigurationError, \
                         "EngineTest#status:active has been defined multiple times."
      end

      it "raises an exception if the state namne starts with 'not_'" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :not_active
          end
        }.to raise_error StateGate::ConfigurationError, \
                         "EngineTest#status:not_active states cannot begin with 'not_'."
      end

      it "raises an exception if the state namne starts with 'force_'" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :force_active
          end
        }.to raise_error StateGate::ConfigurationError, \
                      "EngineTest#status:force_active states cannot begin with 'force_'."
      end

      it "raises an exception if multiple transitions include :any" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending, transitions_to: :active
            state :active,  transitions_to: [:pending, :any]
          end
        }.to raise_error StateGate::ConfigurationError, \
          "when transitioning to :any on EngineTest#status:active, :any must be the only transition."
      end
    end # state


    context "state options" do
      it "raises an exception when state options has non-Symbol keys" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending, 'transitions_to' => :active
          end
        }.to raise_error StateGate::ConfigurationError, \
                                "options for EngineTest#status:pending must be Symbols."
      end

      it "raises an exception when state transitions are non-Symbols" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending, transitions_to: [:active, 'pending']
          end
        }.to raise_error StateGate::ConfigurationError, \
                              "transitions for EngineTest#status:pending must be Symbols."
      end
    end # state options


    context "default" do
      it "raises an exception when default is missing" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            default
          end
        }.to raise_error StateGate::ConfigurationError, \
                                        "default for EngineTest#status must be a Symbol."
      end

      it "raises an exception when the default is a non-Symbols" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            default 'active'
          end
        }.to raise_error StateGate::ConfigurationError, \
                                        "default for EngineTest#status must be a Symbol."
      end

      it "raises an exception when the default is specified twice" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            default :active
            default :active
          end
        }.to raise_error StateGate::ConfigurationError, \
                        "default for EngineTest#status has been specified multiple times."
      end
    end # default

    context "prefix" do
      it "raises an exception when prefix is missing" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            prefix
          end
        }.to raise_error StateGate::ConfigurationError, \
                                        "prefix for EngineTest#status must be a Symbol."
      end

      it "raises an exception when the prefix is a non-Symbols" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            prefix 'test_prefix'
          end
        }.to raise_error StateGate::ConfigurationError, \
                                        "prefix for EngineTest#status must be a Symbol."
      end

      it "raises an exception when the prefix is specified twice" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            prefix :test_prefix
            prefix :test_prefix
          end
        }.to raise_error StateGate::ConfigurationError, \
                        "prefix for EngineTest#status has been defined multiple times."
      end
    end # prefix


    context "suffix" do
      it "raises an exception when suffix is missing" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            suffix
          end
        }.to raise_error StateGate::ConfigurationError, \
                                        "suffix for EngineTest#status must be a Symbol."
      end

      it "raises an exception when the suffix is a non-Symbols" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            suffix 'test_suffix'
          end
        }.to raise_error StateGate::ConfigurationError, \
                                        "suffix for EngineTest#status must be a Symbol."
      end

      it "raises an exception when the suffix is specified twice" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending
            state :active
            suffix :test_suffix
            suffix :test_suffix
          end
        }.to raise_error StateGate::ConfigurationError, \
                        "suffix for EngineTest#status has been defined multiple times."
      end
    end # suffix


    context "assert_all_transitions_are_states" do
      it "raises an exception with a transition to an invalid state" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending, transitions_to: :active
            state :active,  transitions_to: :archived
          end
        }.to raise_error StateGate::ConfigurationError, \
                         "EngineTest#status transitions from :active to invalid state :archived."
      end
    end # assert_all_transitions_are_states


    context "assert_all_states_are_reachable" do
      it "raises an exception with a non-default state with no transitions leading to it" do
        expect{
          StateGate::Engine.new('EngineTest', :status) do
            state :pending,   transitions_to: :suspended
            state :active,    transitions_to: :suspended
            state :suspended, transitions_to: :archived
            state :archived,  transitions_to: :pending
          end
        }.to raise_error StateGate::ConfigurationError, \
                         "There are no state transitions leading to EngineTest#status :active."
      end
    end # assert_all_states_are_reachable
  end # on failure
end # "Engine Configurator"
