# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Aliased Attribute" do
  before(:all) do
    class AliasMethodsTest < ActiveRecord::Base
      self.table_name = 'examples'
      include StateGate

      alias_attribute :alias_test, :status

      state_gate :alias_test do
        state :pending, human: 'Pending Activation'
        state :active
        state :archived
        make_sequential
      end
    end
  end

  after(:all) {  Object.send(:remove_const, :AliasMethodsTest) }


  #   engine
  # ======================================================================

  describe "engine" do
    it "is attached to the correct non-alias method name" do
      expect(AliasMethodsTest.stateables.keys).to include(:status)
    end

    it "is not attached to the alias method name" do
      expect(AliasMethodsTest.stateables.keys).not_to include(:alias_test)
    end
  end

  #   Class Methods
  # ======================================================================

  describe "alias class methods" do
    it "for the attribute" do
      expect(AliasMethodsTest.respond_to?(:alias_tests)).to be_truthy
      expect(AliasMethodsTest.respond_to?(:human_alias_tests)).to be_truthy
      expect(AliasMethodsTest.respond_to?(:alias_tests_for_select)).to be_truthy
    end


    it "for transitions" do
      expect(AliasMethodsTest.respond_to?(:alias_test_transitions)).to be_truthy
      expect(AliasMethodsTest.respond_to?(:alias_test_transitions_for)).to be_truthy
    end


    it "for scopes" do
      expect(AliasMethodsTest.respond_to?(:with_alias_tests)).to be_truthy
    end
  end # "alias class methods are added for"



  #   Instance Methods
  # ======================================================================

  describe "alias instance methods" do
    subject { AliasMethodsTest.new }

    it "for the attribute" do
      expect(subject.respond_to?(:alias_tests)).to be_truthy
      expect(subject.respond_to?(:human_alias_tests)).to be_truthy
      expect(subject.respond_to?(:alias_tests_for_select)).to be_truthy
    end # states


    it "for the transitions" do
      expect(subject.respond_to?(:alias_test_transitions)).to be_truthy
    end # states
  end #  "alias instance methods"


  #   AliasSetter Methods
  # ======================================================================

  describe "alias setter methods" do
    subject { AliasMethodsTest.new }

    it "attribute= allows valid transitions" do
      subject.alias_test = :active
      expect(subject.alias_test).to eq 'active'
    end

    it "attributes= allows valid transitions" do
      subject.attributes = {alias_test: :active}
      expect(subject.alias_test).to eq 'active'
    end

    it "assign_attributes allows valid transitions" do
      subject.assign_attributes(alias_test: :active)
      expect(subject.alias_test).to eq 'active'
    end

    # Attribute detection on :write_attribute was introduced in 5.2
    if ActiveRecord.gem_version >= Gem::Version .new('5.2.0.beta1')
      it "write_attribute allows valid transitions" do
        subject.write_attribute(:alias_test, :active)
        expect(subject.alias_test).to eq 'active'
      end

      it "[]= allows valid transitions" do
        subject[:alias_test] = :active
        expect(subject.alias_test).to eq 'active'
      end
    end

    it "update allows valid transitions" do
      subject.update(alias_test: :active)
      expect(subject.alias_test).to eq 'active'
    end

    it "update_attribute allows valid transitions" do
      subject.update_attribute(:alias_test, :active)
      expect(subject.alias_test).to eq 'active'
    end

    # :update_attributes was removed in version 6.1.0.rc1
    if ActiveRecord.gem_version < Gem::Version.new('6.1.0.rc1')
      it "update_attributes allows valid transitions" do
        subject.update_attributes(alias_test: :active)
        expect(subject.alias_test).to eq 'active'
      end
    end

    # Attribute detection on :update_column was introduced in 5.2.2
    if ActiveRecord.gem_version >= Gem::Version.new('5.2.2')
      it "update_column allows valid transitions" do
        subject.save
        subject.update_column(:alias_test, :active)
        expect(subject.alias_test).to eq 'active'
      end

      it "update_columns allows valid transitions" do
        subject.save
        subject.update_columns(alias_test: :active)
        expect(subject.alias_test).to eq 'active'
      end
    end

    it "Class.new fails with an invalid transition from the default state" do
      msg = ":alias_test may not be included in the parameters for a new AliasMethodsTest." \
            "  Create the new instance first, then transition :alias_test as required."
      expect{AliasMethodsTest.new(alias_test: :archived)}.to raise_error ArgumentError, msg
    end

    it "Class.create fails with an invalid transition from the default state" do
      msg = ":alias_test may not be included in the parameters for a new AliasMethodsTest." \
            "  Create the new instance first, then transition :alias_test as required."
      expect{AliasMethodsTest.create(alias_test: :archived)}.to raise_error ArgumentError, msg
    end

    it "Class.update allows valid transitions" do
      subject.save
      AliasMethodsTest.update(subject.id, alias_test: :active)
      expect(subject.reload.alias_test).to eq 'active'
    end
  end # describe "alias setter methods"


end # "States"
