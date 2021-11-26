# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Engine Scoper" do
  let!(:eng) do
    StateGate::Engine.new('EngineTest', :status) do
      state :pending
      state :active
      state :suspended
      state :archived

      prefix :my_prefix
      suffix :my_suffix
    end
  end

  context ":include_scopes?" do
    it "returns TRUE when @scopes" do
      eng.instance_variable_set(:@scopes, true)
      expect(eng.include_scopes?).to be_truthy
    end

    it "returns FALSE when not @scopes" do
      eng.instance_variable_set(:@scopes, false)
      expect(eng.include_scopes?).to be_falsy
    end
  end


  context ":scope_name_for_state(<state>)" do
    it "returns the scoped name for the given state" do
      eng.states.each do |state|
        expect(eng.scope_name_for_state(state)).to eq "my_prefix_#{state}_my_suffix"
      end
    end

    it "raises an error with an unknown state" do
      msg = ":dummy is not valid state for EngineTest#status."
      expect{eng.scope_name_for_state(:dummy)}.to raise_error ArgumentError, msg
    end

  end
end # "Engine Scoper"
