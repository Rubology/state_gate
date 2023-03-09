# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Engine Errator" do
  let!(:eng) do
    StateGate::Engine.new('EngineTest', :status) do
      state :pending
      state :active
      state :suspended
      state :archived
    end
  end

  it "#_cerr returns a ConfigurationError" do
    expect{eng.send(:_cerr, :prefix_type_err)}
      .to raise_error StateGate::ConfigurationError
  end

  it "#_rerr returns a RuntimeError" do
    expect{eng.send(:_rerr, :klass_type_err)}
      .to raise_error RuntimeError
  end

  it "#_aerr returns an ArgumentError" do
    expect{eng.send(:_aerr, :klass_type_err)}
      .to raise_error ArgumentError
  end


  context "#_invalid_state_error" do
    it "returns a formated error for 'nil'" do
      expect{eng.send(:_invalid_state_error, nil)}
        .to raise_error ArgumentError, "'nil' is not valid state for EngineTest#status."
    end

    it "returns a formated error for a Symbol" do
      expect{eng.send(:_invalid_state_error, :dummy)}
        .to raise_error ArgumentError, ":dummy is not valid state for EngineTest#status."
    end

    it "returns a formated error for a String" do
      expect{eng.send(:_invalid_state_error, 'dummy')}
        .to raise_error ArgumentError, "'dummy' is not valid state for EngineTest#status."
    end
  end
end # "Engine Errator"
