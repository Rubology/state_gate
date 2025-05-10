require "test_helper"

module StateGateTests
  class AssertionsTest < Minitest::Spec
    
    before do
      Object.send(:remove_const, :TesterClass) if Object.const_defined?(:TesterClass)
      
      Object.const_set(:TesterClass, Class.new(ActiveRecord::Base))
      ::TesterClass.class_eval do
        self.table_name = 'minitest_examples'
        include StateGate
        
        state_gate :status do
          state :pending,   transitions_to: [:active], human: 'Pending Activation'
          state :active,    transitions_to: [:locked, :suspended, :archived]
          state :locked,    transitions_to: [:active, :suspended, :archived]
          state :suspended, transitions_to: [:active, :archived]
          state :archived,  transitions_to: [:active]
        end
      end
    end

    after do
      Object.send(:remove_const, :TesterClass) if Object.const_defined?(:TesterClass)
    end
    
    
    describe 'status' do
      describe "states" do
        it "has the expected states" do
          assert_has_states ::TesterClass, :status, :pending, :active, :locked, :suspended, :archived
        end

        it "does not have unexpected states" do
          refute_has_states ::TesterClass, :status, :deleted, :banned
        end

        it "accepts an instance as the source object" do
          assert_has_states ::TesterClass.new, :status, %w[pending active locked suspended archived]
        end
      end # states

      describe "state assertion failures" do
        it "reports defined state that was not expected" do
          error = assert_raises(Minitest::Assertion) do
            assert_has_states ::TesterClass, :status, :pending, :active, :locked, :suspended
          end
          assert_equal ":archived is also a valid state for #status.",
                       error.message
        end

        it "reports defined states that were not expected" do
          error = assert_raises(Minitest::Assertion) do
            assert_has_states ::TesterClass, :status, :pending, :active
          end
          assert_equal ":locked, :suspended, and :archived are also valid states for #status.",
                       error.message
        end

        it "reports expected state that was not defined" do
          error = assert_raises(Minitest::Assertion) do
            assert_has_states ::TesterClass, :status, :pending, :active, :locked,
                              :suspended, :archived, :deleted
          end
          assert_equal ":deleted is not a valid state for #status.", error.message
        end

        it "reports expected states that are not defined" do
          error = assert_raises(Minitest::Assertion) do
            assert_has_states ::TesterClass, :status, :pending, :active, :locked,
                              :suspended, :archived, :deleted, :uprooted
          end
          assert_equal ":deleted and :uprooted are not valid states for #status.", error.message
        end

        it "reports a found state for a negated assertion" do
          error = assert_raises(Minitest::Assertion) do
            refute_has_states ::TesterClass, :status, :active
          end
          assert_equal ":active is a valid state for #status.", error.message
        end

        it "reports found states for a negated assertion" do
          error = assert_raises(Minitest::Assertion) do
            refute_has_states ::TesterClass, :status, :active, :archived
          end
          assert_equal ":active and :archived are valid states for #status.", error.message
        end

        it "reports a missing attribute" do
          error = assert_raises(Minitest::Assertion) do
            assert_has_states ::TesterClass, nil, :active
          end
          assert_equal "missing the <attribute> to be tested.", error.message
        end

        it "reports an attribute with no state machine" do
          error = assert_raises(Minitest::Assertion) do
            assert_has_states ::TesterClass, :name, :active
          end
          assert_equal "no state machine is defined for #name.", error.message
        end

        it "reports a class with no state machines" do
          error = assert_raises(Minitest::Assertion) do
            assert_has_states AssertionsTest, :status, :active
          end
          assert_equal "no state machines are defined for StateGateTests::AssertionsTest.", error.message
        end
      end # state assertion failures

      describe "transitions" do
        it "allows the expected transitions" do
          assert_allows_transitions ::TesterClass, :status, from: :pending,   to: :active
          assert_allows_transitions ::TesterClass, :status, from: :active,    to: [:locked, :suspended, :archived]
          assert_allows_transitions ::TesterClass, :status, from: :locked,    to: [:active, :suspended, :archived]
          assert_allows_transitions ::TesterClass, :status, from: :suspended, to: %w[active archived]
          assert_allows_transitions ::TesterClass, :status, from: :archived,  to: :active
        end

        it "does not allow unexpected transitions" do
          refute_allows_transitions ::TesterClass, :status, from: :pending,  to: [:locked, :suspended, :archived]
          refute_allows_transitions ::TesterClass, :status, from: :archived, to: [:locked, :suspended]
        end

        it "accepts an instance as the source object" do
          assert_allows_transitions ::TesterClass.new, :status, from: :suspended, to: [:active, :archived]
        end
      end # transitions

      describe "transition assertion failures" do
        it "reports allowed transitions that were not expected" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, from: :active, to: :locked
          end
          assert_equal "#status also transitions from :active to :suspended and :archived.",
                       error.message
        end

        it "reports expected transitions that are not allowed" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, from: :archived, to: [:active, :locked]
          end
          assert_equal "#status does not transition from :archived to :locked.", error.message
        end

        it "reports missing and extra transitions together" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, from: :active, to: [:locked, :pending]
          end
          assert_equal "#status also transitions from :active to :suspended and :archived. " \
                       "#status does not transition from :active to :pending.",
                       error.message
        end

        it "reports allowed transitions for a negated assertion" do
          error = assert_raises(Minitest::Assertion) do
            refute_allows_transitions ::TesterClass, :status, from: :active, to: [:pending, :locked, :archived]
          end
          assert_equal ":active is allowed to transition to :locked and :archived.", error.message
        end

        it "reports a missing :from state" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, to: :active
          end
          assert_equal "missing the <from:> state.", error.message
        end

        it "reports missing :to states" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, from: :active
          end
          assert_equal "missing the <to:> states.", error.message
        end

        it "reports an invalid :from state" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, from: :deleted, to: :active
          end
          assert_equal ":deleted is not a valid state for TesterClass#status.", error.message
        end

        it "reports a single invalid :to state" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, from: :active, to: [:locked, :deleted]
          end
          assert_equal ":deleted is not a valid #status state.", error.message
        end

        it "reports multiple invalid :to states" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, from: :active, to: [:deleted, :banned]
          end
          assert_equal ":deleted and :banned are not valid #status states.", error.message
        end

        it "reports an attribute with no state machine" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :name, from: :active, to: :locked
          end
          assert_equal "no state machine is defined for #name.", error.message
        end

        it "reports an unusable state name" do
          error = assert_raises(Minitest::Assertion) do
            assert_allows_transitions ::TesterClass, :status, from: "not a state", to: :active
          end
          assert_equal "\"not a state\" is not a valid state name.", error.message
        end
      end # transition assertion failures

    end # status
  end
end
