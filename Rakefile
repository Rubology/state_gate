require './ruby_version'


desc "Defaiult task for 'rake', runs 'rspec spec' on latest active_record version."
task :default do
  Rake::Task["test_latest"].invoke
end



desc "Runs 'rspec spec' on latest active_record version."
task :test_latest do
  puts "\n\n"
  puts "=====================================\n"
  puts " Testing Latest ActiveRecord Version"
  puts "=====================================\n"

  latest = `bundle exec appraisal list`.split("\n").first
  system "BUNDLE_GEMFILE=#{RubyVersion.gemfile} bundle exec appraisal #{latest} rspec spec"
end



desc "Runs 'rspec spec' on latest active_record version."
task :latest do
  Rake::Task["test_latest"].invoke
end



desc "Runs 'rspec spec' on every version of active_record."
task :test_all do
  # hide deprecation warnings
  parts = ["HIDE_DEPRECATIONS=true"]

  # set the gemfile for the current vertsion of ruby
  parts << "BUNDLE_GEMFILE=#{RubyVersion.gemfile}"

  # run appraisals
  parts << "bundle exec appraisal rspec spec"

  # runb the command
  system parts.join(' ')
end



desc "Runs 'rspec spec' on every version of active_record."
task :all do
  puts "\n\n"
  puts "===================================\n"
  puts " Testing All ActiveRecord Versions"
  puts "===================================\n"

  Rake::Task["test_all"].invoke
end



desc "Runs 'rspec spec --tag test' on latest active_record version."
task :test_tagged do
  latest = `bundle exec appraisal list`.split("\n").first
  system "BUNDLE_GEMFILE=#{RubyVersion.gemfile} bundle exec appraisal #{latest} rspec spec --tag test"
end


desc "Runs 'rspec spec --tag test' on latest active_record version."
task :tagged do
  Rake::Task["test_tagged"].invoke
end



desc "Installs the gems and gemfiles for each version of active_record within 'appraisals'."
task :install do
  # NOTE: GitHub Actions require ONLY the :test group gems.
  #       so they are loaded first, creating the .lock file, which is then frozen
  #       before loading the :development gems (if using the latest version of Ruby)


  puts "\n\n"
  puts "==================\n"
  puts " Updating Bundler"
  puts "==================\n"
  system "gem update bundler"

  puts "\n\n"
  puts "======================\n"
  puts " Installing Test Gems"
  puts "======================\n"
  system "BUNDLE_GEMFILE=#{RubyVersion.gemfile} bundle install"
  system "BUNDLE_GEMFILE=#{RubyVersion.gemfile} bundle lock --add-platform x86_64-linux"

  if RubyVersion.latest?
    puts "\n\n"
    puts "=============================\n"
    puts " Installing Development Gems"
    puts "=============================\n"
    system "bundle install"
  end

  puts "\n\n"
  puts "======================\n"
  puts " Installing Appraisal"
  puts "======================\n"
  system "BUNDLE_GEMFILE=#{RubyVersion.gemfile} bundle exec appraisal install"
  puts "\n\n"
end



desc "Outputs the terminal command to run 'rspec spec' on the latest version of active_record."
task :spec_command do
  latest = `bundle exec appraisal list`.split("\n").first
  puts "\nbundle exec appraisal #{latest} rspec spec/\n\n"
end



desc "Generates the Sdoc files & opens them in the default browser."
task :doc do
  `sdoc -e "UTF-8" --title 'Sanitized' --main 'README.md' -T 'rails' -x spec -x CHANGELOG.md -x CODE_OF_CONDUCT.md -x DEVELOPER_GUIDE.md -x SECURITY.md`
  `open http://localhost:9292`
end



desc "Generates the Sdoc files & opens them in the default browser. (alias for :doc)"
task :docs do
  Rake::Task["doc"].invoke
end



desc "starts a rackup server for the docs."
task :doc_server do
  `rackup doc_server.ru`
end



desc "Opens the coverage results in the default brwoser."
task :coverage do
  Rake::Task["test_latest"].invoke

  unless ENV['FOR_TESTSPACE']
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
  system "bundle exec rubocop --auto-correct --only #{corrections.join(',')} lib/"
end



desc "Validate the .codecov.yml file"
task :validate_codecov do
  system "cat .codecov.yml | curl --data-binary @- https://codecov.io/validate"
end
