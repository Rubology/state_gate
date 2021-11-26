# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Engine Sequencer" do

  let(:i18) { "stateable.engine.%s" }

  let!(:eng) do
    StateGate::Engine.new('EngineTest', :status) do
      state :pending
      state :active
      state :suspended
      state :archived
      make_sequential
    end
  end

  context ":sequentail?" do
    it "returns TRUE if sequential" do
      eng.instance_variable_set(:@sequential, true)
      expect(eng.sequential?).to be_truthy
    end

    it "returns FALSE if not sequential" do
      eng.instance_variable_set(:@sequential, false)
      expect(eng.sequential?).to be_falsy
    end
  end
end # "Engine Sequencer"
