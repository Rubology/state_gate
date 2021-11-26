# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Sequence Methods" do
  context "when sequential" do
    before(:all) do
      class SequenceTest < ActiveRecord::Base
        self.table_name = 'examples'

        include StateGate

        state_gate :status do
          state :pending
          state :active
          state :suspended
          state :archived
          make_sequential
       end
     end # class
    end

    after(:all) { Object.send(:remove_const, :SequenceTest) }

    describe "transitions" do
      subject { SequenceTest.new }

      it "each state can transition to the correct previous state" do
        expect(subject.status_transitions).not_to include(:archived)
        subject.status = :active
        expect(subject.status_transitions).to include(:pending)
        subject.status = :suspended
        expect(subject.status_transitions).to include(:active)
        subject.status = :archived
        expect(subject.status_transitions).to include(:suspended)
      end

      it "each state can transition to the correct next state" do
        expect(subject.status_transitions).to include(:active)
        subject.status = :active
        expect(subject.status_transitions).to include(:suspended)
        subject.status = :suspended
        expect(subject.status_transitions).to include(:archived)
        subject.status = :archived
        expect(subject.status_transitions).not_to include(:pending)
      end
    end # "transitions"
  end # when sequential



  # ======================================================================
  # = Sequenctial with Loop
  # ======================================================================

  context "when sequential with Loop" do
    before(:all) do
      class SequenceTest < ActiveRecord::Base
        self.table_name = 'examples'

        include StateGate

        state_gate :status do
          state :pending
          state :active
          state :suspended
          state :archived
          make_sequential :loop
       end
     end # class
    end

    after(:all) { Object.send(:remove_const, :SequenceTest) }

    describe "transitions" do
      subject { SequenceTest.new }

      it "each state can transition to the correct previous state" do
        expect(subject.status_transitions).to include(:archived)
        subject.status = :active
        expect(subject.status_transitions).to include(:pending)
        subject.status = :suspended
        expect(subject.status_transitions).to include(:active)
        subject.status = :archived
        expect(subject.status_transitions).to include(:suspended)
      end

      it "each state can transition to the correct next state" do
        expect(subject.status_transitions).to include(:active)
        subject.status = :active
        expect(subject.status_transitions).to include(:suspended)
        subject.status = :suspended
        expect(subject.status_transitions).to include(:archived)
        subject.status = :archived
        expect(subject.status_transitions).to include(:pending)
      end
    end # "transitions"
  end # when sequential with loop



  # ======================================================================
  # = Sequenctial with :one_way
  # ======================================================================

  context "when sequential with :one_way" do
    before(:all) do
      class SequenceTest < ActiveRecord::Base
        self.table_name = 'examples'

        include StateGate

        state_gate :status do
          state :pending
          state :active
          state :suspended
          state :archived
          make_sequential :one_way
       end
     end # class
    end

    after(:all) { Object.send(:remove_const, :SequenceTest) }

    describe "transitions" do
      subject { SequenceTest.new }

      it "each state cannot transition to previous state" do
        expect(subject.status_transitions).not_to include(:archived)
        subject.status = :active
        expect(subject.status_transitions).not_to include(:pending)
        subject.status = :suspended
        expect(subject.status_transitions).not_to include(:active)
        subject.status = :archived
        expect(subject.status_transitions).not_to include(:suspended)
      end

      it "each state can transition to the correct next state" do
        expect(subject.status_transitions).to include(:active)
        subject.status = :active
        expect(subject.status_transitions).to include(:suspended)
        subject.status = :suspended
        expect(subject.status_transitions).to include(:archived)
        subject.status = :archived
        expect(subject.status_transitions).not_to include(:pending)
      end
    end # "transitions"
  end # when sequential with :one_way

end #  "Sequence Methods"
