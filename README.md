
[//]: # "###################################################"
[//]: # "#####                 HEADER                  #####"
[//]: # "###################################################"


# [StateGate](https://github.com/Rubology/state_gate)



[//]: # "############################################"
[//]: # "#####             BADGES               #####"
[//]: # "############################################"


[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](#license)
[![Gem Version](https://badge.fury.io/rb/state_gate.svg)](https://badge.fury.io/rb/state_gate)
[![Space Metric](https://rubology.testspace.com/spaces/191451/metrics/298753/badge?token=5a5b5231d853f991aebc6bcb66ff6b9f763158a4)](https://rubology.testspace.com/spaces/191451/current/Code%20Coverage?utm_campaign=badge&utm_medium=referral&utm_source=coverage "Code Coverage (lines)")

![ruby 3.2](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_2.yml/badge.svg?branch=main)
![ruby 3.1](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_1.yml/badge.svg?branch=main)
![ruby 3.0](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_0.yml/badge.svg?branch=main) 
![ruby 2.7](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_7.yml/badge.svg?branch=main)
![ruby 2.6](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_6.yml/badge.svg?branch=main)
![ruby 2.5](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_5.yml/badge.svg?branch=main)




[//]: # "###################################################"
[//]: # "#####                  INDEX                  #####"
[//]: # "###################################################"


## Index

- [state management for ActiveRecord](#state_gate)
- [requirements](#requirements)
- [installation](#installation)
- [change log](CHANGELOG.md)
- [summary](#summary)
- [wiki - full reference](https://github.com/Rubology/state_gate/wiki)
- [RSpec test helpers](#rspec-test-helpers)
- [contributing](#contributing)
- [code of conduct](#code-of-conduct)
- [license](#license)


---


[//]: # "###################################################"
[//]: # "#####               DESCRIPTION               #####"
[//]: # "###################################################"


<a name='state_gate'></a>
## State Management for ActiveRecord!

> The state, the whole state and nothing but the state!

Designed for use with ActiveRecord, **StateGate** has a single responsibility:

-  **_to only allow a valid state to be set._**
-  **_to only allow a valid transition from one state to another._**

With a simple DSL and a sprinkling of syntactic sugar, StateGate is intuitive 
and easy to use.

> No guard clauses?

Nope! ActiveRecord *validations* are the best way to keep everything in order.

> No events?

Nope! Changing state is often the smallest part of an event. Events often 
access other attributes or associations, and are the responsibility of the 
model, not the **StateGate**.

> Is it opinionated?

Very! Any attempt to set an invalid state or transition will raise an exception. 
Exceptions are raised **_before_** accessing the database or triggering 
any callbacks.



---

[//]: # "###################################################"
[//]: # "#####               REQUIREMENTS              #####"
[//]: # "###################################################"


<a name='requirements'></a>
## Requirements

- Ruby 2.5+
- ActiveRecord 5.0+



---

[//]: # "###################################################"
[//]: # "#####              INSTALLATION               #####"
[//]: # "###################################################"


<a name='installation'></a>
## Installation

Add this line to your Gemfile:

`gem 'state_gate'`



---

[//]: # "##################################"
[//]: # "#####         SUMMARY        #####"
[//]: # "##################################"


<a name='summary'></a>
## Summary

A quick list of StateGate's creation, configuration, class & instance methods. 
Each method links to a more in-depth explanation within the 
[Wiki](https://github.com/Rubology/state_gate/wiki).


#### ...creation

> Creating a StateGate on the :status attribute with states of :draft, :pending, :published & :archived.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft,     transitions_to: :pending
    state :pending,   transitions_to: [:published, :archived], human: 'Pending Approval'
    state :published, transitions_to: :archived
    state :archived
  end
end
```

#### ...configuration options

- [state](https://github.com/Rubology/state_gate/wiki/creating-a-stategate)
  - [transitions_to](https://github.com/Rubology/state_gate/wiki/what-is-a-transition)
  - [human](https://github.com/Rubology/state_gate/wiki/specifying-a-human-display-name)
- [default](https://github.com/Rubology/state_gate/wiki/specifying-a-default-state)
- [prefix](https://github.com/Rubology/state_gate/wiki/namespace-with-prefix-&-suffix)
- [postfix](https://github.com/Rubology/state_gate/wiki/namespace-with-prefix-&-suffix)
- [no_scopes](https://github.com/Rubology/state_gate/wiki/scopes)
- [make_sequential](https://github.com/Rubology/state_gate/wiki/sequential-transitions)
  - [one_way](https://github.com/Rubology/state_gate/wiki/sequential-transitions)
  - [loop](https://github.com/Rubology/state_gate/wiki/sequential-transitions)


#### ...class methods

- [#statuses](https://github.com/Rubology/state_gate/wiki/class-methods-for-states)
- [#human_statuses](https://github.com/Rubology/state_gate/wiki/class-methods-for-states)
- [#status_transitions](https://github.com/Rubology/state_gate/wiki/class-methods-for-transitions)
- [#status_transitions_for(:draft | :pending | :published | :archived)](https://github.com/Rubology/state_gate/wiki/class-methods-for-transitions)
- [#statuses_for_select, #statuses_for_select(:sorted)](https://github.com/Rubology/state_gate/wiki/class-methods-for-transitions)


#### ...scope methods

- [#draft](https://github.com/Rubology/state_gate/wiki/scopes)
- [#pending](https://github.com/Rubology/state_gate/wiki/scopes)
- [#published](https://github.com/Rubology/state_gate/wiki/scopes)
- [#archived](https://github.com/Rubology/state_gate/wiki/scopes)
- [#not_draft](https://github.com/Rubology/state_gate/wiki/scopes)
- [#not_pending](https://github.com/Rubology/state_gate/wiki/scopes)
- [#not_published](https://github.com/Rubology/state_gate/wiki/scopes)
- [#not_archived](https://github.com/Rubology/state_gate/wiki/scopes)


#### ...instance methods

- [.statuses](https://github.com/Rubology/state_gate/wiki/instance-methods-for-states)
- [.human_statuses](https://github.com/Rubology/state_gate/wiki/instance-methods-for-states)
- [.human_status](https://github.com/Rubology/state_gate/wiki/instance-methods-for-states)
- [.force_draft, .force_published, :force_archived](https://github.com/Rubology/state_gate/wiki/forcing-a-state-change)
- [.draft?, .pending?, .published?, .archived?](https://github.com/Rubology/state_gate/wiki/instance-methods-for-states)
- [.not_draft?, .not_pending?, .not_published?, .not_archived?](https://github.com/Rubology/state_gate/wiki/instance-methods-for-states)
- [.status_transitions](https://github.com/Rubology/state_gate/wiki/instance-methods-for-transitions)
- [.status_transitions_to?(:draft | :pending | :published | :archived)](https://github.com/Rubology/state_gate/wiki/instance-methods-for-transitions)
- [.statuses_for_select, .statuses_for_select(:sorted)](https://github.com/Rubology/state_gate/wiki/instance-methods-for-states)



---

[//]: # "###################################################"
[//]: # "#####            RSPEC TEST HELPERS           #####"
[//]: # "###################################################"


<a name='rspec-test-helpers'></a>
## Testing with RSpec

> - [...testing states](https://github.com/Rubology/state_gate/wiki/testing-states-with-rspec)
> - [...testing transitions](https://github.com/Rubology/state_gate/wiki/testing-transitions-with-rspec)


---

[//]: # "###################################################"


<a name='contributing'></a>
## Contributing

> - [Security issues](#security-issues)
> - [Reporting issues](#reporting-issues)
> - [Pull requests](#pull-requests)

In all cases please respect our [Contributor Code of Conduct](CODE_OF_CONDUCT.md).


<a name='security-issues'></a>
### Security issues

If you have found a security related issue, please follow our 
[Security Policy](SECURITY.md).


<a name='reporting-issues'></a>
### Reporting issues

Please try to answer the following questions in your bug report:

- What did you do?
- What did you expect to happen?
- What happened instead?

Make sure to include as much relevant information as possible, including:

- Ruby version.
- StateGate version.
- ActiveRecord version.
- OS version.
- The steps needed to replicate the issue.
- Any stack traces you have are very valuable.


<a name='pull-requests'></a>
### Pull Requests

We encourage contributions via GitHub pull requests.

Our [Developer Guide](DEVELOPER_GUIDE.md) details how to fork the project;
get it running locally; run the tests; check the documentation;
check your style; and submit a pull request.



---

[//]: # "###################################################"
[//]: # "#####              CODE OF CONDUCT            #####"
[//]: # "###################################################"


<a name='code-of-conduct'></a>
## Code of Conduct

We as members, contributors, and leaders pledge to make participation in our
community a harassment-free experience for everyone, regardless of age, body
size, visible or invisible disability, ethnicity, sex characteristics, gender
identity and expression, level of experience, education, socio-economic status,
nationality, personal appearance, race, religion, or sexual identity
and orientation.


Read the full details in our [Contributor Code of Conduct](CODE_OF_CONDUCT.md).



---

[//]: # "###################################################"
[//]: # "#####                  LICENSE                #####"
[//]: # "###################################################"


<a name='license'></a>
## License

The MIT License (MIT)

Copyright (c) 2020 CodeMeister

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


