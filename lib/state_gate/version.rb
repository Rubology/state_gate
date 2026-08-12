# frozen_string_literal: true

##
# Version for StateGate
#
module StateGate

  ##
  # Returns the gem version.
  #
  # @return [Gem::Version]
  #
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  ##
  # EncodedToken::VERSION
  #
  #   This module represent the current version.
  #
  module VERSION

    MAJOR = 2
    MINOR = 0
    TINY  = 1
    # MICRO = ''

    STRING = [MAJOR, MINOR, TINY].compact.join(".")
    # STRING = [MAJOR, MINOR, TINY, MICRO].compact.join(".")

  end

end
