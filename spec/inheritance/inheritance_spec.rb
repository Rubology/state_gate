# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "StateGate" do
  context "included" do
    it "pass with an ActiveRecord ancestor when included" do
      expect{
        class HookTest < ActiveRecord::Base
          self.table_name = 'examples'
          include StateGate
        end
      }.not_to raise_error
      Object.send(:remove_const, :HookTest)
    end

    it "fails if ActiveRecord is not an ancestor of the model" do
      msg  = "StateGate requires HookTest to derive from ActiveRecord."

      expect {
        class HookTest
          include StateGate
        end
      }.to raise_error RuntimeError, msg
      Object.send(:remove_const, :HookTest)
    end
  end # included


  context "extended" do
    it "fails if StateGate is :extended" do
      msg  = "HookTest should use 'include StateGate' and not"
      msg += " 'extend StateGate'."

      expect {
        class HookTest < ActiveRecord::Base
          self.table_name = 'examples'
          extend StateGate
        end
      }.to raise_error RuntimeError, msg
      Object.send(:remove_const, :HookTest)
    end
  end # extended
end # "StateGate"
