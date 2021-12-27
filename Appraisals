  # frozen_string_literal: true

appraise 'active-record-7-0-0' do
  gem 'sqlite3', '~> 1.4.1'
  gem 'activerecord', '7.0.0'
end

appraise 'active-record-6-1-4-4' do
  gem 'sqlite3', '~> 1.4.1'
  gem 'activerecord', '6.1.4.4'
end


# ======================================================================
#  For Ruby versions below 3.0.0
# ======================================================================

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.0.0')

  appraise 'active-record-6-0-4-4' do
    gem 'sqlite3', '~> 1.4.0'
    gem 'activerecord', '6.0.4.4'
  end

  appraise 'active-record-5-2-6' do
    gem 'sqlite3', '~> 1.3.3'
    gem 'activerecord', '5.2.6'
  end

  appraise 'active-record-5-1-7' do
    gem 'sqlite3', '~> 1.3.3'
    gem 'activerecord', '5.1.7'
  end

  appraise 'active-record-5-0-7-2' do
    gem 'sqlite3', '~> 1.3.3'
    gem 'activerecord', '5.0.7.2'
  end
end # if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.0.0')
