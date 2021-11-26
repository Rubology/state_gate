# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Conflict Detection" do

  context "for class methods" do
    it "detects a dangerous method name" do
      expect{
              class ConflictMethodsTest < ActiveRecord::Base
                self.table_name = 'examples'
                include StateGate

                state_gate :status do
                  state :parent
                  state :active
                end
              end
            }.to raise_error StateGate::ConflictError,
                            "StateGate for ConflictMethodsTest#status will" \
                            " generate a class method 'parent', which is already" \
                            " defined by ActiveRecord."
      Object.send(:remove_const, :ConflictMethodsTest)
    end


    it "detects a class method already define as a singleton method" do
      expect{
              class ConflictMethodsTest < ActiveRecord::Base
                self.table_name = 'examples'
                include StateGate

                scope :active, ->{ where(speed: :active) }

                state_gate :status do
                  state :pending
                  state :active
                end
              end
            }.to raise_error StateGate::ConflictError,
                            "StateGate for ConflictMethodsTest#status will" \
                            " generate a class method 'active', which is already" \
                            " defined by ConflictMethodsTest."
      Object.send(:remove_const, :ConflictMethodsTest)
    end


    it "detects a Class method already define within an Ancerstor class" do
      module ConflictMethodsModuleTest
        def dummy
        end
      end

      expect{
              class ConflictMethodsTest < ActiveRecord::Base
                self.table_name = 'examples'
                include StateGate
                extend ConflictMethodsModuleTest

                state_gate :status do
                  state :dummy
                  state :active
                end
              end
            }.to raise_error StateGate::ConflictError,
                            "StateGate for ConflictMethodsTest#status will" \
                            " generate a class method 'dummy', which is already" \
                            " defined by ConflictMethodsModuleTest."
      Object.send(:remove_const, :ConflictMethodsTest)
      Object.send(:remove_const, :ConflictMethodsModuleTest)
    end
  end # for class methods


  context "for instance methods" do
    it "detects an instance method already defined within the class" do
      expect{
              class ConflictMethodsTest < ActiveRecord::Base
                self.table_name = 'examples'
                include StateGate

                def dummy?
                end

                state_gate :status do
                  state :dummy
                  state :active
                end
              end
            }.to raise_error StateGate::ConflictError,
                            "StateGate for ConflictMethodsTest#status will" \
                            " generate an instance method 'dummy?', which is already" \
                            " defined by ConflictMethodsTest."
      Object.send(:remove_const, :ConflictMethodsTest)
    end


    it "detects an instance method already define within an Ancerstor class" do
      expect{
              class ConflictMethodsTest < ActiveRecord::Base
                self.table_name = 'examples'
                include StateGate

                state_gate :status do
                  state :valid
                  state :active
                end
              end
            }.to raise_error StateGate::ConflictError,
                            "StateGate for ConflictMethodsTest#status will" \
                            " generate an instance method 'valid?', which is already" \
                            " defined by ActiveRecord::Validations."
      Object.send(:remove_const, :ConflictMethodsTest)
    end
  end # for instance methods

end # "States"
