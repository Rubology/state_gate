# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "States" do
  describe "class methods" do
    before(:all) do
      class StateMethodsTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          state :pending, human: 'Pending Activation'
          state :active
        end

        state_gate :speed do
          state :ascending, human: 'Going UP'
          state :descending, human: 'Going DOWN'
        end
      end
    end

    after(:all) {  Object.send(:remove_const, :StateMethodsTest) }


    it "pluralizes the attribute to return an array of states" do
      expect(StateMethodsTest.statuses).to eq [:pending,   :active]
      expect(StateMethodsTest.speeds).to eq [:ascending, :descending]
    end


    it "#human_<attr-pluralized> return an array of human states" do
      expect(StateMethodsTest.human_statuses).to eq ['Pending Activation','Active']
      expect(StateMethodsTest.human_speeds).to eq ['Going UP', 'Going DOWN']
    end


    it "#stateables returns a hash of the model's state machines" do
      expect(StateMethodsTest.stateables.is_a?(Hash)).to be_truthy
      expect(StateMethodsTest.stateables.count).to eq 2
      expect(StateMethodsTest.stateables.keys).to eq [:status, :speed]
    end


    context "#<attrs>_for_select" do
      context "returns a form select Array of human state names & state names" do
        it "in defided order by default" do
          status_expected = [['Pending Activation', 'pending'],['Active', 'active']]
          speed_expected  = [['Going UP', 'ascending'], ['Going DOWN', 'descending']]
          expect(StateMethodsTest.statuses_for_select).to eq status_expected
          expect(StateMethodsTest.speeds_for_select).to eq speed_expected
        end

        it "alphabetised by human name when TRUE is passed as an argument" do
          status_expected = [['Active', 'active'],['Pending Activation', 'pending']]
          speed_expected  = [['Going DOWN', 'descending'],['Going UP', 'ascending']]
          expect(StateMethodsTest.statuses_for_select(true)).to eq status_expected
          expect(StateMethodsTest.speeds_for_select(true)).to eq speed_expected
        end
      end
    end


   it "fails with an invalid state" do
      msg = ":dummy is not valid state for StateMethodsTest#status."
      expect{StateMethodsTest.status_transitions_for(:dummy)}
        .to raise_error ArgumentError, msg
    end

    it "fails if a state method is redefined within the class" do
      msg = "\n\nWARNING! StateMethodsTest#status is a defined StateGate and" \
            " redefining :status= may cause conflict.\n\n"
      expect{
        StateMethodsTest.define_method(:status=) {|val| true }
      }.to output(msg).to_stdout
    end
  end # class methods



  describe "instance methods" do
    before(:all) do
      class StateMethodsTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          state :pending, human: 'Pending Activation'
          state :active
          state :suspended
          state :archived

          make_sequential
        end
      end
    end

    after(:all) {  Object.send(:remove_const, :StateMethodsTest) }

    subject { StateMethodsTest.new }


    # = attribute methods
    # ======================================================================

    describe "attribute methods" do
      it "#<attrs> returns an Array of the states for the attribute" do
        expect(subject.statuses).to eq [:pending,:active,:suspended,:archived]
      end

      it "#human_<attr> return a String with the human states for the attribute" do
       expect(subject.human_status).to eq 'Pending Activation'
      end

      it "#human_<attrs> return an Array of the human states for the attribute" do
        states = ['Pending Activation','Active','Suspended','Archived']
        expect(subject.human_statuses).to eq states
      end


      context "#<attrs>_for_select" do
        context "returns a form select Array of human state names & state names" do
          it "in defided order by default" do
            expected = [["Pending Activation", "pending"], ["Active", "active"],
                        ["Suspended", "suspended"], ["Archived", "archived"]]
            expect(subject.statuses_for_select).to eq expected
          end

          it "alphabetised by human name when TRUE is passed as an argument" do
            expected = [["Active", "active"], ["Archived", "archived"],
                        ["Pending Activation", "pending"], ["Suspended", "suspended"]]
            expect(subject.statuses_for_select(true)).to eq expected
          end
        end
      end
    end # "attribute methods"



    # = state methods
    # ======================================================================

    describe "state methods" do
      it "#<state>? returns TRUE if the attribute is set to the state" do
        expect(subject.pending?).to be_truthy
      end

      it "#<state>? returns FALSE if the attribute is not set to the state" do
        expect(subject.active?).to be_falsy
        expect(subject.suspended?).to be_falsy
        expect(subject.archived?).to be_falsy
      end

      it "#not_<state>? returns FALSE if the attribute is set to the state" do
        expect(subject.not_pending?).to be_falsy
      end

      it "#not_<state>? returns TRUE if the attribute is not set to the state" do
        expect(subject.not_active?).to be_truthy
        expect(subject.not_suspended?).to be_truthy
        expect(subject.not_archived?).to be_truthy
      end
    end # "state methods"

  end # instance methods
end # "States"
