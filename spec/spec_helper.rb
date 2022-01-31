# frozen_string_literal: true

# ======================================================================
# = Includes
# ======================================================================

require 'rspec/expectations'
require 'active_record'
require 'byebug'
require 'amazing_print'
require 'database_cleaner/active_record'


# Only calculate coverage if we're using the latest version of active_record
latest         = `bundle exec appraisal list`.split("\n").first
latest_version = latest.gsub('active-record-', '').gsub('-', '.')

if latest_version == ActiveRecord.gem_version.to_s
  require 'simplecov'

  SimpleCov.configure do
    # exclude tests
    add_filter 'spec'
  end

  # set output to Coberatura XML if using Testspace analysis
  if ENV['FOR_TESTSPACE']
    require 'simplecov-cobertura'
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end

  # start it up
  SimpleCov.start
end


# require AFTER simpleCOv has started to ensure inclusion in metrics
require_relative '../lib/state_gate'
require_relative '../lib/state_gate/rspec'

# ======================================================================
#  Report the Version
# ======================================================================

current_ruby = Gem::Version.new(RUBY_VERSION)
msg          = "ActiveRecord: #{ActiveRecord.gem_version} (#{current_ruby})"

puts "\n\n"
puts '=' * (msg.size + 4)
puts "\n  #{msg}\n\n"
puts '=' * (msg.size + 4)
puts "\n\n"



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
    create_table :examples do |t|
      t.string    :status
      t.string    :speed
      t.string    :category
      t.integer   :counter
    end
  end

end

# Create the tables
CreateExampleTable.migrate(:up)



# ======================================================================
# = Configure RSpec
# ======================================================================

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end


  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end


  config.shared_context_metadata_behavior = :apply_to_host_groups


  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
