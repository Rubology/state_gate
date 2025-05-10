require './ruby_version'

envs = [ "RUBY_VERSION=#{RubyVersion.current}",
         "BUNDLE_GEMFILE=#{RubyVersion.gemfile}",
         "APPRAISAL_FILE=#{RubyVersion.appraisal_file}",
         "APPRAISAL_GEMFILES_ROOT=#{RubyVersion.appraisal_gemfiles_root}",
         "APPRAISAL_JOBS=1"].join(' ')


desc "Default task for 'rake', runs 'rspec spec' on latest active_record version."
task :default do
  Rake::Task["test_latest"].invoke
end



desc "Runs 'rspec spec' on latest active_record version."
task :test_latest do
  puts "\n\n\n"
  puts "=====================================\n"
  puts " Testing Latest ActiveRecord Version"
  puts "=====================================\n"

  latest = `#{envs} bundle exec appraisal list`.split("\n").first
  system "WITH_COVERAGE=true #{envs} bundle _2.3.26_ exec appraisal #{latest} rspec spec"
end



desc "Runs 'rspec spec' on latest active_record version."
task :latest do
  Rake::Task["test_latest"].invoke
end



desc "Runs 'rspec spec' on every version of active_record."
task :test_all do
  # hide deprecation warnings
  cmd = ["HIDE_DEPRECATIONS=true",
           envs,
          "bundle _2.3.26_ exec appraisal rspec spec"].join(' ')

  system cmd
  system "ruby -Ilib:test test/state_gate_assertions_test.rb"
end



desc "Runs 'rspec spec' on every version of active_record."
task :all do
  puts "\n\n\n"
  puts "===================================\n"
  puts " Testing All ActiveRecord Versions"
  puts "===================================\n\n"

  Rake::Task["test_all"].invoke
end



desc "Runs minispec to test assertions helper."
task :minitest do
  system "ruby -Ilib:test test/state_gate_assertions_test.rb"
end

desc "Runs 'rspec spec --tag test' on latest active_record version."
task :test_tagged do
  latest = `#{emvs} bundle exec appraisal list`.split("\n").first
  system "#{envs} bundle _2.3.26_ exec appraisal #{latest} rspec spec --tag test"
end


desc "Runs 'rspec spec --tag test' on latest active_record version."
task :tagged do
  Rake::Task["test_tagged"].invoke
end



desc "Installs the gems and gemfiles for each version of active_record within 'appraisals'."
task :bundle do
  puts "\n\n"
  puts "==================\n"
  puts " Updating Bundler"
  puts "==================\n"
  system "gem install bundler:2.3.26"

  puts "\n\n"
  puts "=================\n"
  puts " Installing Gems"
  puts "=================\n"
  puts "Using '#{RubyVersion.gemfile}'\n\n"
  system "#{envs} bundle _2.3.26_ install"
  system "#{envs} bundle _2.3.26_ lock --add-platform x86_64-linux"

  puts "\n\n"
  puts "======================\n"
  puts " Installing Appraisal"
  puts "======================\n"
  system "#{envs} bundle _2.3.26_ exec appraisal generate-install"
  puts "\n\n"
  
  if RubyVersion.latest?
    puts "\n\n"
    puts "=========================\n"
    puts " Installing Console Gems"
    puts "=========================\n"
    system "BUNDLE_GEMFILE=ruby_gemfiles/console.gemfile bundle _2.3.26_ install"
    system "BUNDLE_GEMFILE=ruby_gemfiles/console.gemfile bundle _2.3.26_ lock --add-platform x86_64-linux"
  end
end



desc "Runs bundle outdated for the current version of ruby."
task :outdated do
  puts "Checking outdated for '#{RubyVersion.gemfile}'"
  system("#{envs} bundle outdated")
end



desc "Runs bundle update for the current version of ruby."
task :update do
  puts "Updating for '#{RubyVersion.gemfile}'"
  system("#{envs} bundle outdated")
  system("#{envs} bundle update")
end



desc "Outputs the terminal command to run 'rspec spec' on the latest version of active_record."
task :spec_command do
  latest = `bundle _2.3.26_ exec appraisal list`.split("\n").first
  puts "\n#{envs} bundle _2.3.26_ exec appraisal #{latest} rspec spec/\n\n"
end



desc "Generates the Yard documentation & opens it in the default browser."
task :doc do
  unless RubyVersion.latest?
    fail "\nDocs only available in Ruby #{RubyVersion.latest_version}\n\n"
  end

  `yardoc`
  `open doc/index.html`
end



desc "Generates the Yard documentation & opens it in the default browser. (alias for :doc)"
task :docs do
  Rake::Task["doc"].invoke
end



desc "Opens the coverage results in the default brwoser."
task :coverage do
  Rake::Task["test_latest"].invoke
  
  system "WITH_COVERAGE=true ruby -Ilib:test test/state_gate_assertions_test.rb"

  unless ENV['GITHUB_ACTION']
    `open coverage/index.html`
  end
end



desc "Runs 'rubocop' on the 'lib' directory, auto-correcting appropved cops."
task :rubo do
  corrections = [
                  'Layout/TrailingWhitespace',
                  'Layout/EmptyLinesAroundClassBody',
                  'Layout/EmptyLinesAroundModuleBody',
                  'Layout/EmptyLineBetweenDefs'
                ]
  system "#{envs} bundle _2.3.26_ exec rubocop --auto-correct --only #{corrections.join(',')} lib/"
end



desc "Validate the .codecov.yml file"
task :validate_codecov do
  system "cat .codecov.yml | curl --data-binary @- https://codecov.io/validate"
end



desc "Return the commnad needed to run bundler for the current gemfile"
task :bundler do
  puts "\n\n"
  puts "=================\n"
  puts " Bundler Command"
  puts "=================\n\n"
  puts  "#{envs} bundle _2.3.26_ "
  puts "\n\n"
end
