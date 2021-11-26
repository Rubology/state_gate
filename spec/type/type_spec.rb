# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "StateGate::Type" do

  subject { StateGate::Type.new('TypeTest', :attr_name, [:pending, :active]) }

  it "initializes the type, converting states to strings" do
    expect(subject.instance_variable_get(:@klass)).to  eq 'TypeTest'
    expect(subject.instance_variable_get(:@name)).to   eq :attr_name
    expect(subject.instance_variable_get(:@states)).to eq ['pending', 'active']
  end


  context '.cast' do
    it 'returns a downcased string' do
      expect(subject.cast("ACTIVE")).to eq 'active'
    end

    it "returns a downcased state name when forced" do
      expect(subject.cast("FoRcE_AcTiVe")).to eq 'active'
    end

    it "fails with an invalid state" do
      expect{subject.cast('dummy')}.to raise_error ArgumentError,
                                      "'dummy' is not a valid state for TypeTest#attr_name."
    end
  end


  context ".deserialize" do
    it 'deserializes the value' do
      expect(subject.deserialize(:active)).to eq 'active'
    end
  end


  context '.serialize' do
    it 'returns a downcased string' do
      expect(subject.serialize("ACTIVE")).to eq 'active'
    end

    it "returns a downcased state name when forced" do
      expect(subject.serialize("FoRcE_AcTiVe")).to eq 'active'
    end

    it "fails with an invalid state" do
      expect{subject.serialize(:dummy)}.to raise_error ArgumentError,
                                      ":dummy is not a valid state for TypeTest#attr_name."
    end
  end


  context ".serializable" do
    it "returns TRUE for any value that respond to to_s" do
      expect(subject.serializable?(Date.today)).to be_truthy
    end

    it "returns FALSE for any value that does not respond to to_s" do
      expect(subject.serializable?(BasicObject.new)).to be_falsy
    end
  end


  context ".assert_valid_value" do
    it "succeeds with a valid state" do
      expect{subject.assert_valid_value('active')}.not_to raise_error
    end

    it 'fails with a non-serializable value' do
      allow(subject).to receive(:serializable?){ false }
      expect{subject.assert_valid_value('active')}.to raise_error ArgumentError,
                                  "'active' is not a valid state for TypeTest#attr_name."
    end

    it 'fails with a non-state value' do
      expect{subject.assert_valid_value('dummy')}.to raise_error ArgumentError,
                                  "'dummy' is not a valid state for TypeTest#attr_name."
    end

    it 'reports the correct error for a nil value' do
      expect{subject.assert_valid_value(nil)}.to raise_error ArgumentError,
                                  "'nil' is not a valid state for TypeTest#attr_name."
    end

    it 'reports the correct error for a string value' do
      expect{subject.assert_valid_value('dummy')}.to raise_error ArgumentError,
                                  "'dummy' is not a valid state for TypeTest#attr_name."
    end

    it 'reports the correct error for a symbol value' do
      expect{subject.assert_valid_value(:dummy)}.to raise_error ArgumentError,
                                  ":dummy is not a valid state for TypeTest#attr_name."
    end
  end


  context "==" do
    it "returns TRUE when eqal" do
      other = StateGate::Type.new('TypeTest', :attr_name, [:pending, :active])
      expect(subject == other).to be_truthy
    end

    it "returns FALSE when the other has a different class" do
      other = StateGate::Type.new('TypeTest2', :attr_name, [:pending, :active])
      expect(subject == other).to be_falsy
    end

    it "returns FALSE when the other has a different attribute" do
      other = StateGate::Type.new('TypeTest', :attr_name2, [:pending, :active])
      expect(subject == other).to be_falsy
    end

    it "returns FALSE when the other has different states" do
      other = StateGate::Type.new('TypeTest', :attr_name, [:pending, :active, :suspended])
      expect(subject == other).to be_falsy
    end
  end


  context ".eql?" do
    it "returns TRUE when eqal" do
      other = StateGate::Type.new('TypeTest', :attr_name, [:pending, :active])
      expect(subject.eql?(other)).to be_truthy
    end

    it "returns FALSE when the other has a different class" do
      other = StateGate::Type.new('TypeTest2', :attr_name, [:pending, :active])
      expect(subject.eql?(other)).to be_falsy
    end

    it "returns FALSE when the other has a different attribute" do
      other = StateGate::Type.new('TypeTest', :attr_name2, [:pending, :active])
      expect(subject.eql?(other)).to be_falsy
    end

    it "returns FALSE when the other has different states" do
      other = StateGate::Type.new('TypeTest', :attr_name, [:pending, :active, :suspended])
      expect(subject.eql?(other)).to be_falsy
    end
  end


  context ".hash" do
    it "returns a hash value" do
      expect(subject.hash).to be_truthy
    end

    it "returns a unique hash value" do
      other = StateGate::Type.new('TypeTest2', :attr_name, [:pending, :active])
      expect(subject.hash).not_to eq other.hash
    end
  end
end # StateGate::Type
