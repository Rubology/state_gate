# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "Dynamic Modules" do
  describe "multi-class modules" do
    before(:all) do
      class PostTest < ActiveRecord::Base
        self.table_name = 'examples'
        include StateGate

        state_gate :status do
          state :pending,   transitions_to: :active
          state :active,    transitions_to: [:suspended, :archived]
          state :suspended, transitions_to: [:active, :archived]
          state :archived
        end
      end

      module DMTest_1
        class PostTest < ActiveRecord::Base
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

      module DMTest_2
        class PostTest < ActiveRecord::Base
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
    end

    after(:all) do
      Object.send(:remove_const, :PostTest)
      DMTest_1.send(:remove_const, :PostTest)
      Object.send(:remove_const, :DMTest_1)
      DMTest_2.send(:remove_const, :PostTest)
      Object.send(:remove_const, :DMTest_2)
    end


    it 'creates a unique helper module for each class' do
      id_array = [ PostTest.ancestors[2].object_id,
                   DMTest_1::PostTest.ancestors[2].object_id,
                   DMTest_2::PostTest.ancestors[2].object_id]

      expect(PostTest.ancestors[2].name).to eq "PostTest::StateGate_HelperMethods"
      expect(DMTest_1::PostTest.ancestors[2].name).to eq "DMTest_1::PostTest::StateGate_HelperMethods"
      expect(DMTest_2::PostTest.ancestors[2].name).to eq "DMTest_2::PostTest::StateGate_HelperMethods"

      expect(id_array.uniq.size).to eq 3
    end

    it 'creates a unique validation module for each class' do
      id_array = [ PostTest.ancestors[0].object_id,
                   DMTest_1::PostTest.ancestors[0].object_id,
                   DMTest_2::PostTest.ancestors[0].object_id]

      expect(PostTest.ancestors[0].name).to eq "PostTest::StateGate_ValidationMethods"
      expect(DMTest_1::PostTest.ancestors[0].name).to eq "DMTest_1::PostTest::StateGate_ValidationMethods"
      expect(DMTest_2::PostTest.ancestors[0].name).to eq "DMTest_2::PostTest::StateGate_ValidationMethods"

      expect(id_array.uniq.size).to eq 3
    end
  end # "multi-class modules"
end # "Dynamic Modules"
