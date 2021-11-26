# frozen_string_literal: true

##
# Version for StateGate
#
module StateGate

  # Returns the version of the currently loaded StateMachine as a <tt>Gem::Version</tt>
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION

    MAJOR = 1
    MINOR = 2
    TINY  = 3
    # MICRO = ''

    STRING = [MAJOR, MINOR, TINY].compact.join(".")
    # STRING = [MAJOR, MINOR, TINY, MICRO].compact.join(".")

  end

end
