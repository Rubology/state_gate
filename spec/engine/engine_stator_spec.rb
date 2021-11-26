# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Engine Stator" do

  let!(:eng) do
    StateGate::Engine.new('EngineTest', :status) do
      state :pending,   transitions_to: :active, human: 'Pending Activation'
      state :active,    transitions_to: [:suspended, :archived]
      state :suspended, transitions_to: [:active, :archived],   human: 'Suspended by Admin'
      state :archived
    end
  end


  context "#states" do
    it "returns a Array of the defined states" do
      expect(eng.states).to eq [:pending, :active, :suspended, :archived]
    end
  end


  context "#assert_valid_state!(<state>)" do
    it "returns the Symbol name for a valid state" do
      expect(eng.assert_valid_state!('active')).to eq :active
    end

    it "fails with an invalid state" do
      msg = ":dummy is not valid state for EngineTest#status."
      expect{eng.assert_valid_state!(:dummy)}.to raise_error ArgumentError, msg
    end


    context "when forced" do
      it "returns the Symbol name for a forced valid state" do
        expect(eng.assert_valid_state!(:force_active)).to eq :force_active
      end

      it "fails with a forced invalid state" do
        msg = ":force_dummy is not valid state for EngineTest#status."
        expect{eng.assert_valid_state!(:force_dummy)}.to raise_error ArgumentError, msg
      end
    end
  end # "#assert_valid_state!(<state>)"


  context "#human_states" do
    it "returns a Array of the human names for each state" do
      human_states = ['Pending Activation','Active', 'Suspended by Admin','Archived']
      expect(eng.human_states).to eq human_states
    end
  end


  context "#human_state_for(<state>)" do
    it "returns the human displ;ay name for the given state" do
      expect(eng.human_state_for('pending')).to   eq 'Pending Activation'
      expect(eng.human_state_for(:active)).to     eq 'Active'
      expect(eng.human_state_for(:suspended)).to  eq 'Suspended by Admin'
      expect(eng.human_state_for(:archived)).to   eq 'Archived'
    end

    it "fails with an invalid state" do
      msg = "'dummy' is not valid state for EngineTest#status."
      expect{eng.human_state_for('dummy')}.to raise_error ArgumentError, msg
    end
  end


  context "#states_for_select" do
    context "returns a form select Array of human state names & state names" do
      it "in defided order by default" do
        expected = [['Pending Activation','pending'],
                    ['Active','active'],
                    ['Suspended by Admin','suspended'],
                    ['Archived','archived']]
        expect(eng.states_for_select).to eq expected
      end

      it "alphabetised by human name when TRUE is passed as an argument" do
        expected = [['Active','active'],
                    ['Archived','archived'],
                    ['Pending Activation','pending'],
                    ['Suspended by Admin','suspended']]
        expect(eng.states_for_select(:sorted)).to eq expected
      end
    end
  end


  context "#default_state" do
    it "returns the Symbol default state" do
      expect(eng.default_state).to eq :pending
    end
  end


  context "#raw_states" do
    it "returns the raw states Hash" do
      raw_states = { pending: { human:          'Pending Activation',
                                next_state:     nil,
                                previous_state: nil,
                                scope_name:     'pending',
                                transitions_to: [:active]},

                      active: { human:          'Active',
                                next_state:     nil,
                                previous_state: nil,
                                scope_name:     'active',
                                transitions_to: [:suspended, :archived]},

                   suspended: { human:          'Suspended by Admin',
                                next_state:     nil,
                                previous_state: nil,
                                scope_name:     'suspended',
                                transitions_to: [:active, :archived]},

                    archived: { human:          'Archived',
                                next_state:     nil,
                                previous_state: nil,
                                scope_name:     'archived',
                                transitions_to: []} }


      expect(eng.raw_states).to eq raw_states
    end
  end

end # "Engine Stator"
