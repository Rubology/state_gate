# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'


RSpec.describe "Transition Validation Methods" do

  #   With state_gate transitions
  # ======================================================================

  context "with state_gate transitions, validations are included" do
    before(:all) do
      class SetterTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          state :pending,   transitions_to: :active
          state :active,    transitions_to: [:suspended, :archived]
          state :suspended, transitions_to: [:active, :archived]
          state :archived
        end
      end
    end

    after(:all) {  Object.send(:remove_const, :SetterTest) }

    subject { SetterTest.new }

    context ":force_<attr> by-passes transition validation" do
      it 'on :<attr>=' do
        expect{subject.status = :archived}.to raise_error ArgumentError
        expect{subject.status = :force_archived}.not_to raise_error
      end

      it "on :update" do
        subject.save
        expect{subject.update(status: :archived)}.to raise_error ArgumentError
        expect{subject.update(status: :force_archived)}.not_to raise_error
      end

      it "on :write_attribute" do
        subject.save
        expect{subject.write_attribute(:status, :archived)}.to raise_error ArgumentError
        expect{subject.write_attribute(:status, :force_archived)}.not_to raise_error
      end

      it "on :update_column" do
        subject.save
        expect{subject.update_column(:status, :archived)}.to raise_error ArgumentError
        expect{subject.update_column(:status, :force_archived)}.not_to raise_error
      end
    end # ":force_<attr>_change by-passes transition validtion"


    context "attribute=" do
      it "allows valid transitions" do
        subject.status = :active
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.status = :archived}
          .to raise_error ArgumentError, msg
      end
    end

    context "attributes=" do
      it "allows valid transitions" do
        subject.attributes = {status: :active}
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.attributes = {status: :archived}}
          .to raise_error ArgumentError, msg
      end
    end

    context "assign_attributes" do
      it "allows valid transitions" do
        subject.assign_attributes(status: :active)
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.assign_attributes(status: :archived)}
          .to raise_error ArgumentError, msg
      end
    end

    context "write_attribute" do
      it "allows valid transitions" do
        subject.write_attribute(:status, :active)
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.write_attribute(:status, :archived)}
          .to raise_error ArgumentError, msg
      end
    end

    context "[]=" do
      it "allows valid transitions" do
        subject[:status] = :active
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject[:status] = :archived}
          .to raise_error ArgumentError, msg
      end
    end

    context "update" do
      it "allows valid transitions" do
        subject.update(status: :active)
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.update(status: :archived)}
          .to raise_error ArgumentError, msg
      end
    end

    context "update_attribute" do
      it "allows valid transitions" do
        subject.update_attribute(:status, :active)
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.update_attribute(:status, :archived)}
          .to raise_error ArgumentError, msg
      end
    end

   # :update_attributes was removed in version 6.1.0.rc1
   if ActiveRecord.gem_version < Gem::Version.new('6.1.0.rc1')
      context "update_attributes" do
        it "allows valid transitions" do
          subject.update_attributes(status: :active)
          expect(subject.status).to eq 'active'
        end

        it "fails invalid transitions" do
          msg = "SetterTest#status cannot transition from :pending to :archived."
          expect{subject.update_attribute(:status, :archived)}
            .to raise_error ArgumentError, msg
        end
      end
    end

    context "update_column" do
      it "allows valid transitions" do
        subject.save
        subject.update_column(:status, :active)
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        subject.save
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.update_column(:status, :archived)}
          .to raise_error ArgumentError, msg
      end
    end

    context "update_columns" do
      it "allows valid transitions" do
        subject.save
        subject.update_columns(status: :active)
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        subject.save
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.update_columns(status: :archived)}
          .to raise_error ArgumentError, msg
      end
    end

    context "Class.new" do
      it "fails with an invalid transition from the default state" do
        msg = ":status may not be included in the parameters for a new SetterTest." \
              "  Create the new instance first, then transition :status as required."
        expect{SetterTest.new(status: :archived)}
          .to raise_error ArgumentError, msg
      end

      context 'when unlocked' do
        it "allows a valid state to be set when forced" do
          expect{SetterTest.new(status: :force_archived)}.not_to raise_error 
        end
      end

      context "when locked" do 
        before(:all) do
          class SetterTest2 < ActiveRecord::Base
            self.table_name = 'examples'
            include StateGate

            state_gate :status do
              state :pending,   transitions_to: :active
              state :active,    transitions_to: [:suspended, :archived]
              state :suspended, transitions_to: [:active, :archived]
              state :archived
            end
          end
        end

        after(:all) {  Object.send(:remove_const, :SetterTest2) }

        it "allows a valid state to be set when forced" do
          expect{SetterTest2.new(status: :force_archived)}.not_to raise_error 
        end
      end
    end

    context "Class.create" do
      it "fails with an invalid transition from the default state" do
        msg = ":status may not be included in the parameters for a new SetterTest." \
              "  Create the new instance first, then transition :status as required."
        expect{SetterTest.create(status: :archived)}
          .to raise_error ArgumentError, msg
      end

      it "allows a valid state to be set when forced" do
        expect{SetterTest.new(status: :force_archived)}.not_to raise_error 
      end
    end

    context "Class.update" do
      it "allows valid transitions" do
        subject.save
        SetterTest.update(subject.id, status: :active)
        expect(subject.reload.status).to eq 'active'
      end

      it "fails invalid transitions" do
        subject.save
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{SetterTest.update(subject.id, status: :archived)}
          .to raise_error ArgumentError, msg
      end

      it "allows a valid state to be set when forced" do
        subject.save
        expect{SetterTest.update(subject.id, status: :force_archived)}
          .not_to raise_error 
      end
    end
  end # context with state_gate attributes



  #   With no state_gate transition
  # ======================================================================

  context "with no state_gate transitions, validations are not included" do
    before(:all) do
      class SetterTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          state :pending
          state :active
          state :suspended
          state :archived
        end
      end
    end

    after(:all) {  Object.send(:remove_const, :SetterTest) }

    subject { SetterTest.new }

    context "attribute=" do
      it "allows valid transitions" do
        subject.status = :active
        expect(subject.status).to eq 'active'
      end

      it "fails invalid transitions" do
        msg = "SetterTest#status cannot transition from :pending to :archived."
        expect{subject.status = :archived}
          .not_to raise_error
      end
    end
  end # woth no state attributes, but lockable
end # "Transition Validation Methods"
