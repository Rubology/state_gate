##
# Methods to work with the current ruby version at the MAJOR.MINOR level
#
module RubyVersion
  require 'open-uri'
  require 'rubygems'
  
  class << self

    # Returns the latest known version of Ruby
    def latest_version
      @latest_version ||= begin
                            Gem::Version.new(latest_ruby_lang_version)
                          rescue
                            Gem::Version.new("4.0")
                          end
    end



    # Returns true if the current verion of Ruby is as defined
    def latest?
      is?(latest_version)
    end


    # Returns true if the current version of Ruby matches the expected version
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
			"ruby_gemfiles/ruby_#{current.to_s.gsub('.','_')}.gemfile"
    end
    
    # Returns the string filename for the current ruby version appraisals file
		def appraisal_file
			"appraisals/appraisals_ruby_#{current.to_s.gsub('.','_')}"
    end
    
    # Returns the string filename for the current ruby version appraisals root folder
		def appraisal_gemfiles_root
			"appraisals/gemfiles_ruby_#{current.to_s.gsub('.','_')}"
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
  

  def latest_ruby_version
    ruby_lang_url = 'https://cache.ruby-lang.org/pub/ruby/index.txt'
    content = URI.open(ruby_lang_url, &:read)

    versions = content.lines.filter_map do |line|
        # Each line looks like: "ruby-3.3.0.tar.gz  3.3.0 ..."
        if line =~ /\bruby-(\d+\.\d+\.\d+)/
            Gem::Version.new($1)
        end
    end

    refined(versions.max.to_s)
  end
end
