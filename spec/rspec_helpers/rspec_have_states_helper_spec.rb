# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "RSPEC have_states helper" do

  before(:all) do
    class RspecStateTest_Valid < ActiveRecord::Base
      self.table_name = 'examples'

      include StateGate

      state_gate :status do
        state :pending,   transitions_to: :active
        state :active,    transitions_to: [:suspended, :archived]
        state :suspended, transitions_to: [:active, :archived]
        state :archived
      end
    end # class

    class RspecStateTest_NoRsm < ActiveRecord::Base
      self.table_name = 'examples'
    end # class
  end


  # ======================================================================
  # = expectation set-up
  # ======================================================================

  describe "expectation set-up" do

    # = with positive expectation
    # ======================================================================
    context "with positive expectations" do
      context "on failure" do
        it "fails when there are no state machines defined" do
          expect{
            expect(RspecStateTest_NoRsm).to \
              have_states(:pending).for(:status)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'no state machines are defined for RspecStateTest_NoRsm.'
        end

        it "fails when there are no state machine for the given attribute" do
          expect{
            expect(RspecStateTest_Valid).to \
              have_states(:pending).for(:speed)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'no state machine is defined for #speed.'
        end

        it "fails with a missing '.for(<attribute>)'" do
          expect{
            expect(RspecStateTest_Valid).to have_states(:pending)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'missing ".for(<attribute>)".'
        end
      end # "on failure"
    end # "with positive expectations"



    # = with negative expectation
    # ======================================================================
    context "with negative expectations" do
      context "on failure" do
        it "fails when there are no state machines defined" do
          expect{
            expect(RspecStateTest_NoRsm).not_to \
              have_states(:pending).for(:status)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'no state machines are defined for RspecStateTest_NoRsm.'
        end

        it "fails when attribute is not given" do
          expect{
            expect(RspecStateTest_Valid).not_to \
              have_states(:pending)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'missing ".for(<attribute>)".'
        end

        it "fails when there are no state machine for the given attribute" do
          expect{
            expect(RspecStateTest_Valid).not_to \
              have_states(:pending).for(:speed)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'no state machine is defined for #speed.'
        end

        it "fails with a missing '.for(<attribute>)'" do
          expect{
            expect(RspecStateTest_Valid).to have_states(:pending)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'missing ".for(<attribute>)".'
        end
      end # "on failure"
    end # "with negative expectations"
  end # "with the set-up"



  # ======================================================================
  # = Expectation logic
  # ======================================================================
  describe "expectation logic" do

    # = with positive expectation
    # ======================================================================
    context "with positive expectations" do
      context "on success" do
        it "passes with the correct states for the class attribute" do
          expect(RspecStateTest_Valid).to \
            have_states(:pending, :active, :suspended, :archived).for(:status)
        end

        it "passes with the correct states for the model attribute" do
          expect(RspecStateTest_Valid.new).to \
            have_states(:pending, :active, :suspended, :archived).for(:status)
        end

        it "passes with multiple individual states" do
          expect(RspecStateTest_Valid.new).to \
            have_states(:pending, :active, :suspended, :archived).for(:status)
        end

        it "passes with an array of states" do
          expect(RspecStateTest_Valid.new).to \
            have_states([:pending, 'active', :suspended, 'archived']).for(:status)
        end
      end # "on success"


      context "on failure" do
        it "fails with an additional non-valid state" do
          expect{
            expect(RspecStateTest_Valid).to \
              have_states(:pending, :active, :suspended, :archived, :dummy).for(:status)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':dummy is not a valid state for #status.'
        end

        it "fails with multiple additional non-valid states" do
          expect{
            expect(RspecStateTest_Valid).to \
              have_states(:pending, :active, :suspended, :archived, :dummy, :test).for(:status)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':dummy and :test are not valid states for #status.'
        end

        it "fails with a missing valid state" do
          expect{
            expect(RspecStateTest_Valid).to \
              have_states(:pending, :active, :suspended).for(:status)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':archived is also a valid state for #status.'
        end

        it "fails with m ultiple missing valid states" do
          expect{
            expect(RspecStateTest_Valid).to \
              have_states(:pending).for(:status)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                  ':active, :suspended, and :archived are also valid states for #status.'
        end
      end  # "on failure"
    end # "with positive expectations"



    # = with negative expectation
    # ======================================================================
    context "with negative expectations" do
      context "on success" do
        it "passes with a list of invalid states for the class" do
          expect(RspecStateTest_Valid).not_to \
            have_states(:dummy, :test).for(:status)
        end

        it "passes with a list of invalid states for the model" do
          expect(RspecStateTest_Valid.new).not_to \
            have_states(:dummy, :test).for(:status)
        end

        it "passes with multiple individual states" do
          expect(RspecStateTest_Valid.new).not_to \
            have_states(:dummt, :test).for(:status)
        end

        it "passes with an array of invalid states" do
          expect(RspecStateTest_Valid.new).not_to \
            have_states([:dummy, :test]).for(:status)
        end
      end # "on success"


      context "on failure" do
        it "fails with a single valid state" do
          expect{
            expect(RspecStateTest_Valid).not_to \
              have_states(:pending, :test, :dummy).for(:status)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':pending is a valid state for #status.'
        end

        it "fails with multiple valid states" do
          expect{
            expect(RspecStateTest_Valid).not_to \
              have_states(:pending, 'active', :dummy).for(:status)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':pending and :active are valid states for #status.'
        end
      end  # "on failure"
    end # "with negative expectations"
  end # "expectation logic"
end # "RSPEC have_states helper"
