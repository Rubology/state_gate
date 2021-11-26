# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Prefix/Postfix Methods" do

  # = Prefix
  # ======================================================================

  describe "when :prefix is specified" do
    before(:all) do
      class FixTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          prefix :state
          state :pending
          state :active
        end

        state_gate :speed do
          prefix :movement
          state :ascending
          state :descending
        end

        state_gate :category do
          prefix :access
          state :draft
          state :published
        end
      end
    end

    after(:all) {  Object.send(:remove_const, :FixTest) }

    subject { FixTest.new }

    it "generates #<prefix>_<state>? for each state" do
      expect(subject.respond_to?(:state_pending?)).to     be_truthy
      expect(subject.respond_to?(:state_active?)).to      be_truthy
      expect(subject.respond_to?(:movement_ascending?)).to    be_truthy
      expect(subject.respond_to?(:movement_descending?)).to   be_truthy
      expect(subject.respond_to?(:access_draft?)).to       be_truthy
      expect(subject.respond_to?(:access_published?)).to   be_truthy
    end

    it "generates #not_<prefix>_<state>? for each state" do
      expect(subject.respond_to?(:not_state_pending?)).to     be_truthy
      expect(subject.respond_to?(:not_state_active?)).to      be_truthy
      expect(subject.respond_to?(:not_movement_ascending?)).to    be_truthy
      expect(subject.respond_to?(:not_movement_descending?)).to   be_truthy
      expect(subject.respond_to?(:not_access_draft?)).to       be_truthy
      expect(subject.respond_to?(:not_access_published?)).to   be_truthy
    end

    it "generates #<prefix>_<state> scopes for each state" do
      expect(FixTest.respond_to?(:state_pending)).to     be_truthy
      expect(FixTest.respond_to?(:state_active)).to      be_truthy
      expect(FixTest.respond_to?(:movement_ascending)).to    be_truthy
      expect(FixTest.respond_to?(:movement_descending)).to   be_truthy
      expect(FixTest.respond_to?(:access_draft)).to       be_truthy
      expect(FixTest.respond_to?(:access_published)).to   be_truthy
    end

    it "generates #not_<prefix>_<state> scopes for each state" do
      expect(FixTest.respond_to?(:not_state_pending)).to     be_truthy
      expect(FixTest.respond_to?(:not_state_active)).to      be_truthy
      expect(FixTest.respond_to?(:not_movement_ascending)).to    be_truthy
      expect(FixTest.respond_to?(:not_movement_descending)).to   be_truthy
      expect(FixTest.respond_to?(:not_access_draft)).to       be_truthy
      expect(FixTest.respond_to?(:not_access_published)).to   be_truthy
    end
  end # when :prefix is TRUE



  # = Suffix
  # ======================================================================

  describe "when :suffix is specified" do
    before(:all) do
      class FixTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          suffix :state
          state :pending
          state :active
        end

        state_gate :speed do
          suffix :movement
          state :ascending
          state :descending
        end

        state_gate :category do
          suffix :access
          state :draft
          state :published
        end
      end
    end

    after(:all) { Object.send(:remove_const, :FixTest) }

    subject { FixTest.new }

    it "generates #<state>_<suffix>? for each state" do
      expect(subject.respond_to?(:pending_state?)).to     be_truthy
      expect(subject.respond_to?(:active_state?)).to      be_truthy
      expect(subject.respond_to?(:ascending_movement?)).to    be_truthy
      expect(subject.respond_to?(:descending_movement?)).to   be_truthy
      expect(subject.respond_to?(:draft_access?)).to       be_truthy
      expect(subject.respond_to?(:published_access?)).to   be_truthy
    end

    it "generates #not_<state>_<suffix>? for each state" do
      expect(subject.respond_to?(:not_pending_state?)).to     be_truthy
      expect(subject.respond_to?(:not_active_state?)).to      be_truthy
      expect(subject.respond_to?(:not_ascending_movement?)).to    be_truthy
      expect(subject.respond_to?(:not_descending_movement?)).to   be_truthy
      expect(subject.respond_to?(:not_draft_access?)).to       be_truthy
      expect(subject.respond_to?(:not_published_access?)).to   be_truthy
    end

    it "generates #<state>_<suffix> scopes for each state" do
      expect(FixTest.respond_to?(:pending_state)).to     be_truthy
      expect(FixTest.respond_to?(:active_state)).to      be_truthy
      expect(FixTest.respond_to?(:ascending_movement)).to    be_truthy
      expect(FixTest.respond_to?(:descending_movement)).to   be_truthy
      expect(FixTest.respond_to?(:draft_access)).to       be_truthy
      expect(FixTest.respond_to?(:published_access)).to   be_truthy
    end

    it "generates #not_<state>_<suffix> scopes for each state" do
      expect(FixTest.respond_to?(:not_pending_state)).to     be_truthy
      expect(FixTest.respond_to?(:not_active_state)).to      be_truthy
      expect(FixTest.respond_to?(:not_ascending_movement)).to    be_truthy
      expect(FixTest.respond_to?(:not_descending_movement)).to   be_truthy
      expect(FixTest.respond_to?(:not_draft_access)).to       be_truthy
      expect(FixTest.respond_to?(:not_published_access)).to   be_truthy
    end
  end # when :suffix is TRUE



  # = Suffix
  # ======================================================================

  describe "when both :prefix and :suffix are specified" do
    before(:all) do
      class FixTest < ActiveRecord::Base
         self.table_name = 'examples'
         include StateGate

         state_gate :status do
           prefix :has
           suffix :state
           state :pending
           state :active
         end

         state_gate :speed do
           prefix :movement
           suffix :quickly
           state :ascending
           state :descending
         end

         state_gate :category do
           prefix :access
           suffix :content
           state :draft
           state :published
        end
      end
    end

    after(:all) { Object.send(:remove_const, :FixTest) }

    subject { FixTest.new }

    it "generates #<prefix>_<state>_<suffix>? for each state" do
      expect(subject.respond_to?(:has_pending_state?)).to        be_truthy
      expect(subject.respond_to?(:has_active_state?)).to         be_truthy
      expect(subject.respond_to?(:movement_ascending_quickly?)).to   be_truthy
      expect(subject.respond_to?(:movement_descending_quickly?)).to  be_truthy
      expect(subject.respond_to?(:access_draft_content?)).to      be_truthy
      expect(subject.respond_to?(:access_published_content?)).to  be_truthy
    end

    it "generates #not_<prefix>_<state>_<suffix>? for each state" do
      expect(subject.respond_to?(:not_has_pending_state?)).to        be_truthy
      expect(subject.respond_to?(:not_has_active_state?)).to         be_truthy
      expect(subject.respond_to?(:not_movement_ascending_quickly?)).to   be_truthy
      expect(subject.respond_to?(:not_movement_descending_quickly?)).to  be_truthy
      expect(subject.respond_to?(:not_access_draft_content?)).to      be_truthy
      expect(subject.respond_to?(:not_access_published_content?)).to  be_truthy
    end

    it "generates #<prefix>_<state>_<suffix> scopes for each state" do
      expect(FixTest.respond_to?(:has_pending_state)).to        be_truthy
      expect(FixTest.respond_to?(:has_active_state)).to         be_truthy
      expect(FixTest.respond_to?(:movement_ascending_quickly)).to   be_truthy
      expect(FixTest.respond_to?(:movement_descending_quickly)).to  be_truthy
      expect(FixTest.respond_to?(:access_draft_content)).to      be_truthy
      expect(FixTest.respond_to?(:access_published_content)).to  be_truthy
    end

    it "generates #not_<prefix>_<state>_<suffix> scopes for each state" do
      expect(FixTest.respond_to?(:not_has_pending_state)).to        be_truthy
      expect(FixTest.respond_to?(:not_has_active_state)).to         be_truthy
      expect(FixTest.respond_to?(:not_movement_ascending_quickly)).to   be_truthy
      expect(FixTest.respond_to?(:not_movement_descending_quickly)).to  be_truthy
      expect(FixTest.respond_to?(:not_access_draft_content)).to      be_truthy
      expect(FixTest.respond_to?(:not_access_published_content)).to  be_truthy
    end
  end # when both :prefix and :suffix are TRUE



  describe "it fails" do
    it "with a missing :prefix" do
      expect {
       class FixTest < ActiveRecord::Base
         self.table_name = 'examples'
         include StateGate

         state_gate :status do
           prefix
         end
       end # class
      }.to raise_error StateGate::ConfigurationError, \
                                      'prefix for FixTest#status must be a Symbol.'


      Object.send(:remove_const, :FixTest)
    end

    it "with a non-Symbol :prefix" do
      expect {
       class FixTest < ActiveRecord::Base
         self.table_name = 'examples'
         include StateGate

         state_gate :status do
           prefix true
         end
       end # class
      }.to raise_error StateGate::ConfigurationError, \
                                      'prefix for FixTest#status must be a Symbol.'
      Object.send(:remove_const, :FixTest)
    end

    it "with a missing :suffix" do
      expect {
       class FixTest< ActiveRecord::Base
         self.table_name = 'examples'
         include StateGate

         state_gate :status do
           suffix
         end
       end # class
      }.to raise_error StateGate::ConfigurationError, \
                                      'suffix for FixTest#status must be a Symbol.'
      Object.send(:remove_const, :FixTest)
    end

    it "with a non-Symbol :suffix" do
      expect {
       class FixTest < ActiveRecord::Base
         self.table_name = 'examples'
         include StateGate

         state_gate :status do
           suffix false
         end
       end # class
      }.to raise_error StateGate::ConfigurationError, \
                                      'suffix for FixTest#status must be a Symbol.'
      Object.send(:remove_const, :FixTest)
    end
  end # "it fails"

end # "Prefix/Postfix Methods"
