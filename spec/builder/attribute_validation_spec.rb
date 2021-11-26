# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Attribute Validation" do
  before(:each) do
    class AttributeTest < ActiveRecord::Base;
      self.table_name = 'examples'

      attr_accessor :dummy
    end
  end

  after(:each) { Object.send(:remove_const, :AttributeTest) }

  describe "validating the attribute" do
    it "passes with a valid attribute" do
      expect {
        StateGate::Builder.new(AttributeTest, :status) do
          state :pending
          state :active
        end
      }.not_to raise_error
    end

    it "fails with a missing attribute" do
      expect {
        StateGate::Builder.new(AttributeTest)
      }.to raise_error ArgumentError, "Missing attribute name when using" \
                                      " 'state_gate' in class 'AttributeTest'."
    end

    it "fails with a non-Symbol attribute" do
      expect {
        StateGate::Builder.new(AttributeTest, 'status')
      }.to raise_error ArgumentError, "StateGate <attr> must be a Symbol."
    end

    it "fails with a non-database attribute" do
      expect {
        StateGate::Builder.new(AttributeTest, :dummy)
      }.to raise_error ArgumentError, "AttributeTest#dummy is not a database attribute."
    end


    it "fails with an attribute for a non-string column type" do
      expect {
        StateGate::Builder.new(AttributeTest, :counter)
      }.to raise_error ArgumentError, "StateGate requires AttributeTest#counter"\
                                      " to be a database :string type."
    end

    it "fails if a state machine is defined twice for the same attribute" do
      expect {
        StateGate::Builder.new(AttributeTest, :status) do
          state :pending
          state :active
        end
        StateGate::Builder.new(AttributeTest, :status)
      }.to raise_error ArgumentError, "An StateGate has already been defined" \
                                      " for AttributeTest#status."
    end
  end # specifying the attribute

end # "Attribute Validation"
