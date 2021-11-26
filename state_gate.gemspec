# frozen_string_literal: true

require_relative 'version'

Gem::Specification.new do |spec|
  spec.platform    = Gem::Platform::RUBY

  spec.name        = 'state_gate'
  spec.version     = StateGate.gem_version
  spec.summary     = 'State management for ActiveRecord.'

  spec.description = %(
    State management for ActiveRecord, with states; transitions; and
    just the right amount of syntactic sugar.
  ).gsub("\n", ' ')

  spec.author   = 'CodeMeister'
  spec.email    = 'state_gate@codemeister.dev'
  spec.homepage = 'https://github.com/Rubology/state_gate'
  spec.license  = 'MIT'

  spec.files         = Dir.glob('lib/**/*', File::FNM_DOTMATCH)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = 'https://github.com/Rubology/state_gate/blob/master/CHANGELOG.md'

  spec.add_runtime_dependency 'activerecord', '>= 5.0.0.beta1'
end # Gem::Specification.new
