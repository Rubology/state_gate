# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Transition Methods" do
  describe "class methods" do
    before(:all) do
      class TransitionMethodsTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          state :pending, human: 'Pending Activation'
          state :active
          make_sequential
        end

        state_gate :speed do
          state :ascending, human: 'Going UP'
          state :descending, human: 'Going DOWN'
          make_sequential
        end
      end
    end

    after(:all) {  Object.send(:remove_const, :TransitionMethodsTest) }

    it "#<attr>_transitions return a Hash of states and transitions" do
      status_expected = {pending: [:active], active: [:pending]}
      speed_expected = {ascending: [:descending], descending: [:ascending]}
      expect(TransitionMethodsTest.status_transitions).to eq status_expected
      expect(TransitionMethodsTest.speed_transitions).to eq speed_expected
    end

    context "#<attribute>_transitions_for(<state>)" do
      it "returns an array of transitions for the given attribute state" do
         expect(TransitionMethodsTest.status_transitions_for(:pending)).to eq [:active]
         expect(TransitionMethodsTest.speed_transitions_for(:descending)).to eq [:ascending]
      end

      it "fails with an invalid state" do
        msg = ":dummy is not valid state for TransitionMethodsTest#status."
        expect{TransitionMethodsTest.status_transitions_for(:dummy)}
          .to raise_error ArgumentError, msg
      end
    end
  end # class methods



  describe "instance methods" do
    before(:all) do
      class TransitionMethodsTest < ActiveRecord::Base
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

    after(:all) {  Object.send(:remove_const, :TransitionMethodsTest) }

    subject { TransitionMethodsTest.new }

    it "#<attr>_transitions returns an Array of the current state transitions" do
      expect(subject.status_transitions.is_a?(Array)).to be_truthy
      expect(subject.status_transitions).to eq [:active]
      subject.status = :active
      expect(subject.status_transitions).to eq [:pending, :suspended]
    end

    context ":transitions_to?" do
      it "returns TRUE for a valid transition" do
        expect(subject.status).to eq 'pending'
        expect(subject.status_transitions_to?(:active)).to be_truthy
        expect(subject.status_transitions_to?('active')).to be_truthy
      end

      it "returns `FALSE for an invalid transition" do
        expect(subject.status).to eq 'pending'
        expect(subject.status_transitions_to?(:archived)).to be_falsy
        expect(subject.status_transitions_to?('archived')).to be_falsy
      end
    end
  end # instance methods


  describe "multi-attribute transitions" do
    before(:all) do
      class TransitionMethodsTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          state :pending,   transitions_to: :active
          state :active,    transitions_to: [:suspended, :archived]
          state :suspended, transitions_to: [:active, :archived]
          state :archived
        end

        state_gate :speed do
          state :lvl_1
          state :lvl_2
          state :lvl_3
          state :lvl_4
          make_sequential
          suffix :speed
        end
      end
    end

    after(:all) {  Object.send(:remove_const, :TransitionMethodsTest) }

    subject { TransitionMethodsTest.new }

    # = :status
    # ======================================================================
    it ':status has the correct states' do
      expect(subject).to have_states(:pending, :active, :suspended, 'archived').for(:status)
    end

    it 'transitions :status from :pending to :active' do
      expect(subject).to allow_transitions_on(:status).from(:pending).to(:active)
    end

    it 'fails to transition :status from :pending to [:suspended, :archived]' do
      expect(subject).not_to \
        allow_transitions_on('status').from('pending').to(['suspended', 'archived'])
    end


    it 'transitions :status from :active to [:suspended, :archived]' do
      expect(subject).to \
        allow_transitions_on(:status).from(:active).to([:suspended, :archived])
    end

    it 'fails to transition :status from :active to :pending]' do
      expect(subject).not_to \
        allow_transitions_on('status').from('active').to([:pending])
    end


    it 'transitions :status from :suspended to [:active, :archived]' do
      expect(subject).to \
        allow_transitions_on(:status).from(:suspended).to(:active, :archived)
    end

    it 'fails to transition :status from :suspended to :pending' do
      expect(subject).not_to \
        allow_transitions_on('status').from(:suspended).to(:pending)
    end


    it 'transitions :status from :archived to []' do
      expect(subject).to \
        allow_transitions_on(:status).from(:archived).to([])
    end

    it 'fails to transition :status from :archived to [:pending, :active, :suspended]' do
      expect(subject).not_to \
        allow_transitions_on('status').from(:archived).to(:pending, :active, :archived)
    end



    # = :speed
    # ======================================================================
    it ':status has the correct states' do
      expect(subject).to have_states(:lvl_1, :lvl_2, 'lvl_3', :lvl_4).for(:speed)
    end

    it 'transitions :speed from :lvl_1 to :lvl_2' do
      expect(subject).to allow_transitions_on(:speed).from(:lvl_1).to(:lvl_2)
    end

    it 'fails to transition :speed from :lvl_1 to [:lvl_3, :lvl_4]' do
      expect(subject).not_to \
        allow_transitions_on('speed').from(:lvl_1).to(:lvl_3, :lvl_4)
    end


    it 'transitions :speed from :lvl_2 to [:lvl_1, :lvl_3]' do
      expect(subject).to \
        allow_transitions_on(:speed).from(:lvl_2).to([:lvl_1, :lvl_3])
    end

    it 'fails to transition :speed from :lvl_2 to :lvl_4' do
      expect(subject).not_to \
        allow_transitions_on('speed').from(:lvl_2).to(:lvl_4)
    end


    it 'transitions :speed from :lvl_3 to [:lvl_2, :lvl_4]' do
      expect(subject).to \
        allow_transitions_on(:speed).from(:lvl_3).to(:lvl_2, :lvl_4)
    end

    it 'fails to transition :speed from :lvl_3 to :lvl_1' do
      expect(subject).not_to \
        allow_transitions_on('speed').from(:lvl_3).to(:lvl_1)
    end


    it 'transitions :speed from :lvl_4 to :lvl_3' do
      expect(subject).to \
        allow_transitions_on(:speed).from(:lvl_4).to(:lvl_3)
    end

    it 'fails to transition :speed from :lvl_4 to [:lvl_1, :lvl_2]' do
      expect(subject).not_to \
        allow_transitions_on('speed').from(:lvl_4).to(:lvl_1, :lvl_2)
    end
  end # "attribute transitions"
end # "Transition Methods"
