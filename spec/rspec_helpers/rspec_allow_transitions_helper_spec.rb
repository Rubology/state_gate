# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe 'Specifying the Attribute' do

  before(:all) do
    class RspecTransitionTest_Valid < ActiveRecord::Base
      self.table_name = 'examples'

      include StateGate

      state_gate :status do
        state :pending,   transitions_to: :active
        state :active,    transitions_to: [:suspended, :archived]
        state :suspended, transitions_to: [:active, :archived]
        state :archived
      end
    end # class

    class RspecTransitionTest_NoRsm < ActiveRecord::Base
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
            expect(RspecTransitionTest_NoRsm).to \
              allow_transitions_on(:status).from(:pending).to(:suspended)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'no state machines are defined for RspecTransitionTest_NoRsm.'
        end

        it "fails when there are no state machine for the given attribute" do
          expect{
            expect(RspecTransitionTest_Valid).to \
              allow_transitions_on(:speed).from('pending').to('suspended')
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'no state machine is defined for #speed.'
        end

        it "fails with an invalid state for the given attribute" do
          expect{
            expect(RspecTransitionTest_Valid).to \
              allow_transitions_on(:status).from(:test).to('suspended')
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':test is not a valid state for RspecTransitionTest_Valid#status.'
        end

        it "fails with a missing '.from(<state>)'" do
          expect{
            expect(RspecTransitionTest_Valid).to allow_transitions_on(:status).to(:suspended)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'missing ".from(<state>)".'
        end

        it "fails with a missing '.to(<states>)'" do
          expect{
            expect(RspecTransitionTest_Valid).to allow_transitions_on(:status).from(:pending)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'missing ".to(<states>)".'
        end

        it "fails with a non-valid transition state" do
          expect{
            expect(RspecTransitionTest_Valid).to \
              allow_transitions_on(:status).from(:pending).to(:test_state)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':test_state is not a valid #status state.'
        end

        it "fails with multiple non-valid transition states" do
          expect{
            expect(RspecTransitionTest_Valid).to \
              allow_transitions_on(:status).from(:pending).to(:test_state, :fail_state)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':test_state and :fail_state are not valid #status states.'
        end
      end # "on failure"
    end # "with positive expectations"



    # = with negative expectation
    # ======================================================================
    context "with negative expectations" do
      context "on failure" do
        it "fails when there are no state machines defined" do
          expect{
            expect(RspecTransitionTest_NoRsm).not_to \
              allow_transitions_on(:status).from(:pending).to(:suspended)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'no state machines are defined for RspecTransitionTest_NoRsm.'
        end

        it "fails when there are no state machine for the given attribute" do
          expect{
            expect(RspecTransitionTest_Valid).not_to \
              allow_transitions_on(:speed).from(:pending).to(:suspended)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'no state machine is defined for #speed.'
        end

        it "fails with an invalid state for the given attribute" do
          expect{
            expect(RspecTransitionTest_Valid).not_to \
              allow_transitions_on(:status).from(:test).to(:suspended)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':test is not a valid state for RspecTransitionTest_Valid#status.'
        end

        it "fails with a missing '.from(<state>)'" do
          expect{
            expect(RspecTransitionTest_Valid).not_to allow_transitions_on(:status).to(:suspended)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'missing ".from(<state>)".'
        end

        it "fails with a missing '.to(<states>)'" do
          expect{
            expect(RspecTransitionTest_Valid).not_to allow_transitions_on(:status).from(:pending)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           'missing ".to(<states>)".'
        end

        it "fails with a non-valid transition state" do
          expect{
            expect(RspecTransitionTest_Valid).not_to \
              allow_transitions_on(:status).from(:pending).to(:test_state)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':test_state is not a valid #status state.'
        end

        it "fails with multiple non-valid transition states" do
          expect{
            expect(RspecTransitionTest_Valid).not_to \
              allow_transitions_on(:status).from(:pending).to(:test_state, :fail_state)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':test_state and :fail_state are not valid #status states.'
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
        it "passes with the correct attribute and transition states for the class" do
          expect(RspecTransitionTest_Valid).to \
            allow_transitions_on(:status).from(:pending).to(:active)
        end

        it "passes with the correct attribute and transition states for the model" do
          expect(RspecTransitionTest_Valid.new).to \
            allow_transitions_on(:status).from(:pending).to(:active)
        end

        it "passes with multiple individual transitions" do
          expect(RspecTransitionTest_Valid.new).to \
            allow_transitions_on(:status).from(:active).to(:suspended, :archived)
        end

        it "passes with an array of transitions" do
          expect(RspecTransitionTest_Valid.new).to \
            allow_transitions_on(:status).from(:active).to([:suspended, :archived])
        end
      end # "on success"


      context "on failure" do
        it "fails with an addition non-valid state" do
          expect{
            expect(RspecTransitionTest_Valid).to \
              allow_transitions_on(:status).from(:pending).to(:archived)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           '#status does not transition from :pending to :archived.'
        end

        it "fails with a missing valid state" do
          expect{
            expect(RspecTransitionTest_Valid).to \
              allow_transitions_on(:status).from(:active).to(:suspended)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           '#status also transitions from :active to :archived.'
        end
      end  # "on failure"
    end # "with positive expectations"



    # = with negative expectation
    # ======================================================================
    context "with negative expectations" do
      context "on success" do
        it "passes with the correct attribute and transition states for the class" do
          expect(RspecTransitionTest_Valid).not_to \
            allow_transitions_on(:status).from(:pending).to(:archived)
        end

        it "passes with the correct attribute and transition states for the model" do
          expect(RspecTransitionTest_Valid.new).not_to \
            allow_transitions_on(:status).from(:pending).to(:suspended)
        end

        it "passes with multiple individual transitions" do
          expect(RspecTransitionTest_Valid.new).not_to allow_transitions_on(:status)
                                              .from(:active).to(:pending)
        end

        it "passes with an array of transitions" do
          expect(RspecTransitionTest_Valid.new).not_to allow_transitions_on(:status)
                                              .from(:archived).to([:suspended, :pending])
        end
      end # "on success"


      context "on failure" do
        it "fails with all valid states" do
          expect{
            expect(RspecTransitionTest_Valid).not_to allow_transitions_on(:status)
                                            .from(:active).to(:suspended, :archived)
          }.to raise_error RSpec::Expectations::ExpectationNotMetError,
                           ':active is allowed to transition to :suspended and :archived.'
        end
      end  # "on failure"
    end # "with negative expectations"
  end # "expectation logic"
end # 'Specifying the Attribute'
