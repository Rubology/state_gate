
# ======================================================================
# = Header
# ======================================================================

puts "\n\n Minitest Assertions\n---------------------\n\n"


# ======================================================================
# = SimpleCov
# ======================================================================

if ENV['WITH_COVERAGE']
  begin
    require 'simplecov'

    # start it up
    SimpleCov.start do
      command_name "Minitest"
      merge_timeout 3600
    end
    
  rescue LoadError
    puts "\n *** Coverage required, but SimpleCov gem not available! ***"

  ensure
    # clear the WITH_COVERAGE environmental variable
    ENV.delete 'WITH_COVERAGE'
  end
end


# ======================================================================
#  Requirements
# ======================================================================

require 'logger'
require 'active_record'
require "minitest/autorun"

require_relative '../lib/state_gate'

include StateGate::Assertions

# ======================================================================
#  Hide Deprecation Warnings
# ======================================================================

# silence all warnings when bulk testing with 'rake all'
if ENV['HIDE_DEPRECATIONS']
  ActiveRecord::Migration.verbose = false

  if ActiveRecord.gem_version >= Gem::Version.new("7.1")
    ActiveRecord.deprecator.behavior = :silence
  else
    ActiveSupport::Deprecation.behavior = :silence
  end
end



# ======================================================================
#  Initialise the DB and ActiveRecord
# ======================================================================

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: ':memory:'
)



# Example table migration
# table for testing class definitions
ar_version = ActiveRecord::VERSION::MAJOR + (ActiveRecord::VERSION::MINOR / 10.0)
class CreateExampleTable < ActiveRecord::Migration[ar_version]

  def up
    create_table :minitest_examples do |t|
      t.string    :status
      t.string    :speed
      t.string    :category
      t.integer   :counter
    end
  end

end

# Create the tables
CreateExampleTable.migrate(:up)
