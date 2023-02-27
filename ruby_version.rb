##
# Methods to work with the current ruby version at the MAJOR.MINOR level
#
module RubyVersion
	class << self

		# Returns the latest known version of Ruby
		def latest_version
			Gem::Version.new('3.2')
		end

		

		# Returns true if the current verion of Ruby is as defined
		def latest?
			is?(latest_version)
		end


		# Returns tru if the current version of Ruby matches the expected version
		#
		# expected: anything that can be stringified with String(xxx)
		#
		def is?(expected = nil)
			expected = refined(expected)
			expected == current
		end	


		# Return a Gem::Version of the current Ruby version twith only MJOR.MINOR segments
		def current
			@current_version ||= refined RUBY_VERSION
		end



		def ==(other)
			current == refined(other)
		end



		def >(other)
			current > refined(other)
		end



		def >=(other)
			current >= refined(other)
		end



		def <(other)
			current < refined(other)
		end



		def <=(other)
			current <= refined(other)
		end



		# Returns the string filename for the current ruby version gemfile
		def gemfile
			"ruby_#{current.to_s.gsub('.','_')}.gemfile"
		end


    # ======================================================================
    # = Private
    # ======================================================================
 		
 		# Return a Gem::Version from the given version refined down to MAJOR.MINOR segments
 		#
 		# version: anything that can be stringified with String(xxx)
 		#
		def refined(version)
			version         = String(version)
			refined_version = Gem::Version.new(version).release.segments[0..1].join('.')
			Gem::Version.new(refined_version)
		end
	end
end	
