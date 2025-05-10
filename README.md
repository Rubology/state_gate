
[//]: # "###################################################"
[//]: # "#####                 HEADER                  #####"
[//]: # "###################################################"


# [StateGate](https://github.com/Rubology/state_gate)



[//]: # "############################################"
[//]: # "#####             BADGES               #####"
[//]: # "############################################"

### Current Status
![ruby 4.0](https://github.com/Rubology/state_gate/actions/workflows/ruby_4_0.yml/badge.svg?branch=main)

![ruby 3.0](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_0.yml/badge.svg?branch=main)
![ruby 3.1](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_1.yml/badge.svg?branch=main)
![ruby 3.2](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_2.yml/badge.svg?branch=main)
![ruby 3.3](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_3.yml/badge.svg?branch=main)
![ruby 3.4](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_4.yml/badge.svg?branch=main)

![ruby 2.6](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_6.yml/badge.svg?branch=main)
![ruby 2.7](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_7.yml/badge.svg?branch=main) 

![100% Test Coverage](https://github.com/Rubology/state_gate/actions/workflows/code_coverage.yml/badge.svg?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](#license)
[![Gem Version](https://badge.fury.io/rb/state_gate.svg)](https://badge.fury.io/rb/state_gate)



[//]: # "###################################################"
[//]: # "#####                  INDEX                  #####"
[//]: # "###################################################"


## Index

- [state management for ActiveRecord](#state_gate)
- [requirements](#requirements)
- [installation](#installation)
- [change log](CHANGELOG.md)
- [summary](#summary)
- [wiki - how to do anything](https://github.com/Rubology/state_gate/wiki)
- [Minitest test helpers](#minitest-test-helpers)
- [RSpec test helpers](#rspec-test-helpers)
- [contributing](#contributing)
- [code of conduct](#code-of-conduct)
- [license](#license)


---


[//]: # "###################################################"
[//]: # "#####               DESCRIPTION               #####"
[//]: # "###################################################"


<a name='state_gate'></a>
## Simple State Management for ActiveRecord!

> The state, the whole state and nothing but the state!

### Why StateGate?
StateGate is built on the belief that ActiveRecord is already great at managing state 
via validations. We provide the 'gate' to ensure valid transitions, without the 
overhead of event DSLs and complex guard logic.

| Feature                  | Description                                                                     |
|--------------------------|---------------------------------------------------------------------------------|
| **Strict States**        | only defined states can be set                                                  |
| **Strict Transitions**   | only defined transitions are allowed                                            |
| **No Guarding**          | **_ActiveRecord Validations_** are better than guard clauses                    |
| **No Eventing**          | simply change state within normal model methods                                 |
| **Fast Fail**            | exceptions are raised **_before_** accessing the DB or triggering any callbacks |
| **No Ambiguous Result**  | state changes succeed, or raise an exception - no need to check the response    |
| **Easy Testing**         | built-in matchers for RSpec & Minitest make testing much easier                 |
| **Simple to Implement** | with a simple DSL, **StateGate** is intuitive and easy to use                   |

---

[//]: # "###################################################"
[//]: # "#####               REQUIREMENTS              #####"
[//]: # "###################################################"


<a name='requirements'></a>
## Requirements

- Ruby 2.6+
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
[//]: # "#####            RSP
[//]: # "###################################################"
[//]: # "#####                 HEADER                  #####"
[//]: # "###################################################"


# [StateGate](https://github.com/Rubology/state_gate)



[//]: # "############################################"
[//]: # "#####             BADGES               #####"
[//]: # "############################################"

### Current Status
![ruby 4.0](https://github.com/Rubology/state_gate/actions/workflows/ruby_4_0.yml/badge.svg?branch=main)

![ruby 3.0](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_0.yml/badge.svg?branch=main)
![ruby 3.1](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_1.yml/badge.svg?branch=main)
![ruby 3.2](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_2.yml/badge.svg?branch=main)
![ruby 3.3](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_3.yml/badge.svg?branch=main)
![ruby 3.4](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_4.yml/badge.svg?branch=main)

![ruby 2.6](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_6.yml/badge.svg?branch=main)
![ruby 2.7](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_7.yml/badge.svg?branch=main)

![100% Test Coverage](https://github.com/Rubology/state_gate/actions/workflows/code_coverage.yml/badge.svg?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](#license)
[![Gem Version](https://badge.fury.io/rb/state_gate.svg)](https://badge.fury.io/rb/state_gate)



[//]: # "###################################################"
[//]: # "#####                  INDEX                  #####"
[//]: # "###################################################"


## Index

- [state management for ActiveRecord](#state_gate)
- [requirements](#requirements)
- [installation](#installation)
- [change log](CHANGELOG.md)
- [summary](#summary)
- [wiki - how to do anything](https://github.com/Rubology/state_gate/wiki)
- [RSpec test helpers](#rspec-test-helpers)
- [contributing](#contributing)
- [code of conduct](#code-of-conduct)
- [license](#license)


---


[//]: # "###################################################"
[//]: # "#####               DESCRIPTION               #####"
[//]: # "###################################################"


<a name='state_gate'></a>
## Simple State Management for ActiveRecord!

> The state, the whole state and nothing but the state!

### Why StateGate?
StateGate is built on the belief that ActiveRecord is already great at managing state
via validations. We provide the 'gate' to ensure valid transitions, without the
overhead of event DSLs and complex guard logic.

| Feature                  | Description                                                                     |
|--------------------------|---------------------------------------------------------------------------------|
| **Strict States**        | only defined states can be set                                                  |
| **Strict Transitions**   | only defined transitions are allowed                                            |
| **No Guarding**          | **_ActiveRecord Validations_** are better than guard clauses                    |
| **No Eventing**          | simply change state within normal model methods                                 |
| **Fast Fail**            | exceptions are raised **_before_** accessing the DB or triggering any callbacks |
| **No Ambiguous Result**  | state changes succeed, or raise an exception - no need to check the response    |
| **Easy Testing**         | built-in matchers for RSpec & Minitest make testing much easier                 |
| **Simple to Implement** | with a simple DSL, **StateGate** is intuitive and easy to use                   |

---

[//]: # "###################################################"
[//]: # "#####               REQUIREMENTS              #####"
[//]: # "###################################################"


<a name='requirements'></a>
## Requirements

- Ruby 2.6+
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

[//]: # "######################################################"
[//]: # "#####            MINITEST TEST HELPERS           #####"
[//]: # "######################################################"


<a name='minitest-test-helpers'></a>
## Testing with Minitest

> - [...testing states](https://github.com/Rubology/state_gate/wiki/testing-States-with-Minitest)
> - [...testing transitions](https://github.com/Rubology/state_gate/wiki/Testing-Transitions-with-Minitest)


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
EC TEST HELPERS           #####"
[//]: # "###################################################"


<a name='rspec-test-helpers'></a>
## Testing with RSpec

> - [...testing states](https://github.com/Rubology/state_gate/wiki/testing-states-with-rspec)
> - [...testing transitions](https://github.com/Rubology/state_gate/wiki/testing-transitions-with-rspec)


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
