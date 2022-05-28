# frozen_string_literal: true

current_ruby = Gem::Version.new(RUBY_VERSION).release
ruby_2_5     = Gem::Version.new('2.5')
ruby_2_6     = Gem::Version.new('2.6')
ruby_2_7     = Gem::Version.new('2.7')
ruby_3_0     = Gem::Version.new('3.0')
ruby_3_1     = Gem::Version.new('3.1')


# ActiveRecord 7.0
if current_ruby >= ruby_2_7
  appraise 'active-record-7-0-3' do
    gem 'sqlite3', '~> 1.4.0'
    gem 'activerecord', '7.0.3'
    gem 'database_cleaner-active_record'
    gem 'rubocop'
  end
end


# ActiveRecord 6.1
if current_ruby >= ruby_2_5
  appraise 'active-record-6-1-6' do
    gem 'activerecord', '6.1.6'
    gem 'sqlite3', '~> 1.4.0'
    gem 'database_cleaner-active_record'

    if current_ruby < ruby_2_6
      gem 'rubocop-ast', '~>1.17.0'
      gem 'rubocop',     '~>1.28.0'
    else
      gem 'rubocop'
    end
  end
end


# ActiveRecord 6.0
if current_ruby >= ruby_2_5 and current_ruby < ruby_3_0
  appraise 'active-record-6-0-5' do
    gem 'activerecord', '6.0.5'
    gem 'sqlite3', '~> 1.4.0'
    gem 'database_cleaner-active_record'

    if current_ruby < ruby_2_6
      gem 'rubocop-ast', '~>1.17.0'
      gem 'rubocop',     '~>1.28.0'
    else
      gem 'rubocop'
    end
  end
end


# ActiveRecord 5.2
if current_ruby >= ruby_2_5 and current_ruby < ruby_3_0
  appraise 'active-record-5-2-8' do
    gem 'activerecord', '5.2.8'
    gem 'sqlite3', '~> 1.3.3'
    gem 'database_cleaner-active_record'

    if current_ruby < ruby_2_6
      gem 'rubocop-ast', '~>1.17.0'
      gem 'rubocop',     '~>1.28.0'
    else
      gem 'rubocop'
    end
  end
end


# ActiveRecord 5.1
if current_ruby >= ruby_2_5 and current_ruby < ruby_3_0
  appraise 'active-record-5-1-7' do
    gem 'activerecord', '5.1.7'
    gem 'sqlite3', '~> 1.3.3'
    gem 'database_cleaner-active_record'

    if current_ruby < ruby_2_6
      gem 'rubocop-ast', '~>1.17.0'
      gem 'rubocop',     '~>1.28.0'
    else
      gem 'rubocop'
    end
  end
end


# ActiveRecord 5.0
if current_ruby >= ruby_2_5 and current_ruby < ruby_3_0
  appraise 'active-record-5-0-7-2' do
    gem 'activerecord', '5.0.7.2'
    gem 'sqlite3', '~> 1.3.3'
    gem 'database_cleaner-active_record'

    if current_ruby < ruby_2_6
      gem 'rubocop-ast', '~>1.17.0'
      gem 'rubocop',     '~>1.28.0'
    else
      gem 'rubocop'
    end
  end
end

