# frozen_string_literal: true

require_relative 'lib/state_gate/version'

Gem::Specification.new do |spec|
  spec.platform    = Gem::Platform::RUBY

  spec.name        = 'state_gate'
  spec.version     = StateGate.gem_version
  spec.summary     = 'State Management for ActiveRecord.'

  spec.description = %(
    State Management for ActiveRecord, with strict states & transitions.
  ).gsub("\n", ' ')

  spec.author   = 'CodeMeister'
  spec.email    = 'state_gate@codemeister.dev'
  spec.homepage = 'https://github.com/Rubology/state_gate'
  spec.license  = 'MIT'

  spec.files         = Dir.glob('lib/**/*', File::FNM_DOTMATCH)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Rubology/state_gate'
  spec.metadata['changelog_uri']   = 'https://github.com/Rubology/state_gate/blob/master/CHANGELOG.md'

  spec.add_runtime_dependency 'activerecord', '>= 5.0.0.beta1'
end # Gem::Specification.new
