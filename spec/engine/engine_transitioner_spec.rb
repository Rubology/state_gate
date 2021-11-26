# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Engine Transitioner" do
  let!(:eng) do
    StateGate::Engine.new('EngineTest', :status) do
      state :pending,   transitions_to: :active, human: 'Pending Activation'
      state :active,    transitions_to: [:suspended, :archived]
      state :suspended, transitions_to: [:active, :archived],   human: 'Suspended by Admin'
      state :archived
    end
  end


  context "#transitionless?" do
    it "returns TRUE when @transitionless" do
      eng.instance_variable_set(:@transitionless, true)
      expect(eng.transitionless?).to be_truthy
    end

    it "returns FALSE when not @transitionless" do
      eng.instance_variable_set(:@transitionless, false)
      expect(eng.transitionless?).to be_falsy
    end
  end


  context "#transitions" do
    it "returns a Hash of the allows states & transitions" do
      transitions = { pending:   [:active],
                      active:    [:suspended, :archived],
                      suspended: [:active, :archived],
                      archived:  []}

      expect(eng.transitions).to eq transitions
    end
  end


  context "#transtitions_for_state(<state>)" do
    it "has the expected transitions for each defined state" do
      expect(eng.transitions_for_state(:pending)).to   eq [:active]
      expect(eng.transitions_for_state(:active)).to    eq [:suspended, :archived]
      expect(eng.transitions_for_state(:suspended)).to eq [:active, :archived]
      expect(eng.transitions_for_state(:archived)).to  eq []
    end

    it "raises an error with an unknown state" do
      msg = ":dummy is not valid state for EngineTest#status."
      expect{eng.transitions_for_state(:dummy)}.to raise_error ArgumentError, msg
    end
  end


  context "#assert_valid_transition(<from_state>, <to_state>)" do
    it "return TRUE for allowed transitions" do
      expect(eng.assert_valid_transition!(:pending,   :active)).to    be_truthy
      expect(eng.assert_valid_transition!(:active,    :suspended)).to be_truthy
      expect(eng.assert_valid_transition!(:active,    :archived)).to  be_truthy
      expect(eng.assert_valid_transition!(:suspended, :suspended)).to be_truthy
      expect(eng.assert_valid_transition!(:suspended, :archived)).to  be_truthy
    end

    it "returns TRUE if the <to_state> starts with 'force_" do
      msg = ":dummy is not valid state for EngineTest#status."
      expect(eng.assert_valid_transition!(:archived, :force_pending)).to be_truthy
    end

    it "raises an error for an invalid :from_state" do
      msg = ":dummy is not valid state for EngineTest#status."
      expect{eng.assert_valid_transition!(:dummy, :pending)}.to raise_error ArgumentError, msg
    end

    it "raises an error for an invalid :to_state" do
      msg = ":dummy is not valid state for EngineTest#status."
      expect{eng.assert_valid_transition!(:pending, :dummy)}.to raise_error ArgumentError, msg
    end

    it "raises an error for an invalid transition" do
      msg = "EngineTest#status cannot transition from :archived to :pending."
      expect{eng.assert_valid_transition!(:archived, :pending)}.to raise_error ArgumentError, msg
    end
  end # ":assert_valid_transition(<from_state>, <to_state>)"

end # "Engine Transitioner"
