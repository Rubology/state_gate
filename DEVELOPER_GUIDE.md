# Developer Guide

## Setup

1. [Fork the project](https://help.github.com/articles/about-forks/)
2. Clone your new fork: `git clone git@github.com:[USERNAME]/state_gate.git`
3. Change your working directory: `cd state_gate`
4. Change to the most recent version of Ruby
5. Install the most recent Bundler: `gem install bundler`
6. Install the most recent Rake: `gem install rake`
7. Install the gems: `rake install` (this will take a while!)
8. Ensure all the tests are passing: `rake test_all`



## Ruby Versions

With Ruby versions below `3.0.0`, `rake test_all` will test every version of ActiveRecord
from `5.0.0` onwards.

With Ruby version `3.0.0` and above, `rake test_all` will test all ActiveRecord versions
from `6.1.0`onwards.



## Adding a New Feature

1. Create your feature branch `git checkout -b new-feature-branch`
2. Write tests for your new feature
3. Write your feature code
4. Run the tests against the most recent ActiveRecord version `rake test_latest`
5. Check your new code is 100% tested: `rake coverage`
6. Run the tests against all versions of ActiveRecord `rake test_all`
7. Check your coding style passes: `rake rubo`
8. Check your documentation reads well: `rake docs`
9. Check that all the test pass with the latest version of Ruby
10. Check that all the test pass with Ruby 2.5
11. Commit your changes `git commit -am 'My New Feature'`



## Sending the Changes

1. Push the new branch to GitHub `git push origin new-feature-branch`
2. Create a new [Pull Request](https://help.github.com/articles/creating-a-pull-request/)



## Versioning Tests

Some versions of ActiveRecord require changes in how tests are written, or even
if they are include at all.

For example: in ActiveRecord 6.1.0.rc1 the method `:update_attributes` was removed.
This does not impact the gem in any way, but test written for previous versions
will now fail.

We can selectively restrict the `:update_attributes` tests to only those versions
prior to 6.1.0.rc1 with:

```ruby
  if ActiveRecord.gem_version < Gem::Version.new('6.1.0.rc1')
    .....
  end
```



## Single Tests

To run individual tests, add the `:test` tag to each definition...

```
  it "raises an error for an invalid :to_state", :test do
    ...
  end
```

...then run `rake test_tagged`


Alternatively, if you want full control, you will need the rspec command that
instructs Appraisal to use the latest ActiveRecord version...

```
  rake spec_command #=> "bundle exec appraisal active-record-6-1-0-rc1 rspec spec/"
```

...and then use it to run any test you wish:

```
  bundle exec appraisal active-record-6-1-0-rc1 rspec spec/builder/state_methods_spec:29
```



## ActiveRecord Versions

We use [Appraisal](http://github.com/thoughtbot/appraisal) to run tests
against each individual version of ActiveRecord that the gem supports.




## Bundling

We test with the latest minor version of every Ruby from 2.5 onwards. As some gems are only
available for certain Ruby versions, we need to use seperate Gemfiles for each version.

The task `rake install` will automatically select the correct gemfile to use and install the gems.
It also adds the `x86_64-linux` platform to the lockfile.



## Coverage

We use [SimpleCov](https://github.com/simplecov-ruby/simplecov) to ensure
test coverage for every line of code. Ensure your test coverage is at 100%
before submitting a Pull request.

The coverage report can be generated and opened with: `rake coverage`



## SDoc

We use [SDoc](https://github.com/zzak/sdoc) to produce the documentation.
Ensure your method comments match the existing style.

Documentation can be generated and opened with: `rake docs`



## RuboCop

We use [RuboCop](https://rubocop.org) to enforce a consistent style
in the codebase. Reading through the exisitng code first is a great way to
get started.

Cops can be run with: `rake rubo`




## Rake Tasks

> Run tests against the latest ActiveRecord version.

`rake test_latest` or `rake`


> Run tests against all ActiveRecord versions.

`rake test_all`


> Run tagged tests against the latest ActiveRecord version.

`rake test_tagged`


> Display the command to use for running individual tests.

`rake spec_command`


> Install Appraisal dependencies.

`rake install`


> Run test coverage and open report.

`rake coverage`


> Generate documentation and open in browser.

`rake doc`


> Run RuboCop.

`rake rubo`



