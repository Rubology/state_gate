# ==================================================================================
# =  Tag an individual test with `:test` then run with `rspec spec --tag test`
# ==================================================================================

require 'spec_helper'

RSpec.describe "RubyVersion" do

	describe ':current' do
		it 'return a Gem::Version' do
			current = RubyVersion.current
			expect(current.is_a?(Gem::Version)).to be_truthy
		end

		it "set the version to the MAJOR.MINBOR of the current version of Ruby" do
			expect(RubyVersion.current.to_s).to eq RUBY_VERSION.split('.')[0..1].join('.')
		end
	end



	describe ":latest?" do 
		it 'returns true with the latest version of ruby' do 
			allow(RubyVersion).to receive(:latest_version){ Gem::Version.new(1.2)}
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion.latest?).to be_truthy
		end

		it 'returns false with an invalid version of ruby' do 
			allow(RubyVersion).to receive(:latest_version){ Gem::Version.new(1.2)}
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.3)}
			expect(RubyVersion.latest?).to be_falsy
		end
	end



	describe ':is?' do
		context 'returns true' do
			it 'with the current version as a string' do
				expect(RubyVersion.is?(RubyVersion.current.to_s)).to be_truthy
			end

			it 'with the current version as a number' do
				expect(RubyVersion.is?(RubyVersion.current.to_s.to_f)).to be_truthy
			end

			it 'with the current version as a Gem::Version' do
				expect(RubyVersion.is?(RubyVersion.current)).to be_truthy
			end
		end

		context 'returns false' do
			before(:each){ allow(RubyVersion).to receive(:refined){ Gem::Version.new(1.2)} }

			it 'with an invalid version as a string' do
				expect(RubyVersion.is?(RubyVersion.current.to_s)).to be_falsy
			end

			it 'with an invalid version as a number' do
				expect(RubyVersion.is?(RubyVersion.current.to_s.to_f)).to be_falsy
			end

			it 'with an invalid version as a Gem::Version' do
				expect(RubyVersion.is?(RubyVersion.current)).to be_falsy
			end
		end
	end



	describe ":==" do 
		it 'returns false with a higher version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion == Gem::Version.new(1.3)).to be_falsy
		end

		it 'returns true with an equal version' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion == Gem::Version.new(1.2)).to be_truthy
		end

		it 'returns false with a lower version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion == Gem::Version.new(1.1)).to be_falsy
		end
	end



	describe ":>=" do 
		it 'returns false with a higher version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion >= Gem::Version.new(1.3)).to be_falsy
		end

		it 'returns true with an equal version' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion >= Gem::Version.new(1.2)).to be_truthy
		end

		it 'returns true with a lower version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion >= Gem::Version.new(1.1)).to be_truthy
		end
	end



	describe ":>" do 
		it 'returns false with a higher version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion > Gem::Version.new(1.3)).to be_falsy
		end

		it 'returns false with an equal version' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion > Gem::Version.new(1.2)).to be_falsy
		end

		it 'returns true with a lower version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion > Gem::Version.new(1.1)).to be_truthy
		end
	end



	describe ":<=" do 
		it 'returns true with a higher version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion <= Gem::Version.new(1.3)).to be_truthy
		end

		it 'returns true with an equal version' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion <= Gem::Version.new(1.2)).to be_truthy
		end

		it 'returns false with a lower version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion <= Gem::Version.new(1.1)).to be_falsy
		end
	end



	describe ":<" do 
		it 'returns true with a higher version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion < Gem::Version.new(1.3)).to be_truthy
		end

		it 'returns false with an equal version' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion < Gem::Version.new(1.2)).to be_falsy
		end

		it 'returns false with a lower version of ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion < Gem::Version.new(1.1)).to be_falsy
		end
	end


	describe ':gemfile' do 
		it 'returns the correct gemfile filename for the given version of Ruby' do 
			allow(RubyVersion).to receive(:current){ Gem::Version.new(1.2)}
			expect(RubyVersion.gemfile).to eq 'ruby_1_2.gemfile'
		end
	end
end
