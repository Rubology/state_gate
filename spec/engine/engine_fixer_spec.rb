# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "engine fixer" do
  let!(:eng) do
    StateGate::Engine.new('EngineTest', :status) do
      state :pending
      state :active
      state :suspended
      state :archived
    end
  end

  context '#state_prefix' do
    it "returns the value of @prefix" do
      eng.instance_variable_set(:@prefix, 'test_prefix')
      expect(eng.state_prefix).to eq 'test_prefix'
    end
  end

  context '#state_suffix' do
    it "returns the value of @suffix" do
      eng.instance_variable_set(:@suffix, 'test_suffix')
      expect(eng.state_suffix).to eq 'test_suffix'
    end
  end

end # "engine fixer"
