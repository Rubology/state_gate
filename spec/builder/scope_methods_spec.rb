# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Scope Methods" do

  # ======================================================================
  # = Adding the scopes
  # ======================================================================

  describe "adding the scopes for each state" do
    context "when scopes are enabled" do
      before(:all) do
        class ScopeTest < ActiveRecord::Base
          self.table_name = 'examples'
          include StateGate

          state_gate :status do
            state :pending
            state :active
            state :archived
          end

          state_gate :speed do
            state :ascending
            state :descending
          end
        end
      end

      after(:all) {  Object.send(:remove_const, :ScopeTest) }

      let!(:example_1) { ScopeTest.create }
      let!(:example_2) { ScopeTest.create.tap{|e| e.update(status: :active)}}
      let!(:example_3) { ScopeTest.create }
      let!(:example_4) { ScopeTest.create.tap{|e| e.update(speed: :descending)}}

      it "adds the correct scopes for :pending" do
        expect(ScopeTest.pending.count).to eq 3
        expect(ScopeTest.pending).to include example_1
        expect(ScopeTest.pending).not_to include example_2
        expect(ScopeTest.pending).to include example_3
        expect(ScopeTest.pending).to include example_4

        expect(ScopeTest.not_pending.count).to eq 1
        expect(ScopeTest.not_pending).not_to include example_1
        expect(ScopeTest.not_pending).to include example_2
        expect(ScopeTest.not_pending).not_to include example_3
        expect(ScopeTest.not_pending).not_to include example_4
      end

      it "adds the correct scopes for :active" do
        expect(ScopeTest.active.count).to eq 1
        expect(ScopeTest.active).not_to include example_1
        expect(ScopeTest.active).to include example_2
        expect(ScopeTest.active).not_to include example_3
        expect(ScopeTest.active).not_to include example_4

        expect(ScopeTest.not_active.count).to eq 3
        expect(ScopeTest.not_active).to include example_1
        expect(ScopeTest.not_active).not_to include example_2
        expect(ScopeTest.not_active).to include example_3
        expect(ScopeTest.not_active).to include example_4
      end

      it "adds the correct scopes for :ascending" do
        expect(ScopeTest.ascending.count).to eq 3
        expect(ScopeTest.ascending).to include example_1
        expect(ScopeTest.ascending).to include example_2
        expect(ScopeTest.ascending).to include example_3
        expect(ScopeTest.ascending).not_to include example_4

        expect(ScopeTest.not_ascending.count).to eq 1
        expect(ScopeTest.not_ascending).not_to include example_1
        expect(ScopeTest.not_ascending).not_to include example_2
        expect(ScopeTest.not_ascending).not_to include example_3
        expect(ScopeTest.not_ascending).to include example_4
      end

      it "adds the correct scopes for :descending" do
        expect(ScopeTest.descending.count).to eq 1
        expect(ScopeTest.descending).not_to include example_1
        expect(ScopeTest.descending).not_to include example_2
        expect(ScopeTest.descending).not_to include example_3
        expect(ScopeTest.descending).to include example_4

        expect(ScopeTest.not_descending.count).to eq 3
        expect(ScopeTest.not_descending).to include example_1
        expect(ScopeTest.not_descending).to include example_2
        expect(ScopeTest.not_descending).to include example_3
        expect(ScopeTest.not_descending).not_to include example_4
      end
    end # adding the scope


    it "fails if a method with the scope name already exists" do
      msg  = "StateGate for ScopeTest_2#status will generate a class"
      msg += " method 'pending', which is already defined by ScopeTest_2."

      expect {
        class ScopeTest_2 < ActiveRecord::Base
          self.table_name = 'examples'
          include StateGate

          scope :pending, ->{ where( category: nil ) }

          state_gate :status do
            state :pending
            state :active
          end
        end
      }.to raise_error StateGate::ConflictError, msg

      Object.send(:remove_const, :ScopeTest_2)
    end
  end # context "when scopes are enabled"


  context "when scopes are disbaled" do
    before(:all) do
      class ScopeTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          state :pending
          state :active

          no_scopes
        end

        state_gate :speed do
          state :ascending
          state :descending
        end
      end
    end

    after(:all) { Object.send(:remove_const, :ScopeTest) }

    it "has no scopes for any states when disabled" do
      expect(ScopeTest.respond_to?(:pending)).to be_falsy
      expect(ScopeTest.respond_to?(:active)).to be_falsy
    end

    it "has expected scopes for all states when enabled" do
      expect(ScopeTest.respond_to?(:ascending)).to be_truthy
      expect(ScopeTest.respond_to?(:descending)).to be_truthy
    end
  end # context "when scopes are disbaled"

end # "Scope Methods"
