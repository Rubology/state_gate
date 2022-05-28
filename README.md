
[//]: # "###################################################"
[//]: # "#####                 HEADER                  #####"
[//]: # "###################################################"


# [StateGate](https://github.com/Rubology/state_gate)



<!-- [//]: # "###################################################"
[//]: # "#####             MASTER BADGES               #####"
[//]: # "###################################################"

[![Space Metric](https://rubology.testspace.com/spaces/159275/metrics/208004/badge?token=f49998769fb94b193c6c14032ca62d1353f8d282)](https://rubology.testspace.com/spaces/159275/current/Code%20Coverage?utm_campaign=badge&utm_medium=referral&utm_source=coverage "Code Coverage (lines)")
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](#license)

![ruby 2.5](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_5.yml/badge.svg?branch=dev)
![ruby 2.6](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_6.yml/badge.svg?branch=dev)
![ruby 2.7](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_7.yml/badge.svg?branch=dev)
![ruby 3.0](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_0.yml/badge.svg?branch=dev)
![ruby 3.1](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_1.yml/badge.svg?branch=dev)
 -->



[//]: # "###################################################"
[//]: # "#####               DEV BADGES                #####"
[//]: # "###################################################"

[![Space Metric](https://rubology.testspace.com/spaces/159275/metrics/208004/badge?token=f49998769fb94b193c6c14032ca62d1353f8d282)](https://rubology.testspace.com/spaces/159275/current/Code%20Coverage?utm_campaign=badge&utm_medium=referral&utm_source=coverage "Code Coverage (lines)")
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](#license)

![ruby 2.5](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_5.yml/badge.svg?branch=dev)
![ruby 2.6](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_6.yml/badge.svg?branch=dev)
![ruby 2.7](https://github.com/Rubology/state_gate/actions/workflows/ruby_2_7.yml/badge.svg?branch=dev)
![ruby 3.0](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_0.yml/badge.svg?branch=dev)
![ruby 3.1](https://github.com/Rubology/state_gate/actions/workflows/ruby_3_1.yml/badge.svg?branch=dev)



[//]: # "###################################################"
[//]: # "#####                  INDEX                  #####"
[//]: # "###################################################"


## Index

- [state management for ActiveRecord](#state_gate)
- [requirements](#requirements)
- [installation](#installation)
- [change log](CHANGELOG.md)
- [summary](#summary)
- [full reference](#reference)
  - [creating a StateGate](#creating-a-state-state)
  - [defining states](#defining-states)
  - [specifying transitions](#specifying-transitions)
  - [sequential transitions](#sequential-transitions)
  - [scopes](#scopes)
  - [namespacing to avoid state collisions](#namespacing-to-avoid-state-collisions)
  - [method return values](#method-return-values)
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

Designed specifically for ActiveRecord, **StateGate** has a single responsibility
and does it really _really_ well:

-  **_it will not allow an invalid state._**
-  **_it will not allow an invalid transition from one state to another._**

With a simple DSL and just the right amount of syntactic sugar, **StateGate** 
is intuitive and easy to use.

> No guard clauses?

Nope! ActiveRecord *validations* are the best way to keep everything in order.

> No events?

Nope! State changes rarely happen in isolation. They're usually just one part
of a larger process, often in Service Objects, Domain Objects or other 
PORO wrappers. But if you really need a simple event in the model itself, 
simply add a method for it.

> Is it opinionated?

Very! States are so crucial to any model, that **StateGate** will 
raise an exception on an invalid state or transition; 
even with direct setters like `:update_columns`. Most importantly, it raises 
these exceptions _**before**_ it hits the database or any callbacks are triggered. 
It will even raise an exeption if an invalid state is loaded from the database.



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

> - [creation](#creation-summary)
> - [class methods](#c-methods-summary)
> - [scope methods](#scope-summary)
> - [instance methods](#i-methods-summary)

A quick list of StateGate's creation, class & instance methods. Each method links to
a more in-depth explanation within the [Reference](#reference) section.


<a name='creation-summary'></a>
#### ...creation options

> [creating a basic StateGate](#creating-a-state-state), [defining states](#defining-states) 
  & [specifying transitions](#specifying-transitions).

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

> An advanced StateGate with [prefix, suffix](#namespacing-to-avoid-state-collisions), 
  no [scopes](#scopes) and [sequential transitions](#sequential-transitions).

```ruby
class UKTrafficLight < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :green
    state :yellow
    state :red
    state :red_and_yellow

    default :red

    prefix :traffic
    suffix :light

    no_scopes

    make_sequential :one_way, :loop
  end
end
```



<a name='c-methods-summary'></a>
#### ...class methods

> With a StateGate on the :status attribute and states of :draft, ;published & :archived.

- [#statuses](#class-helper-methods)
- [#human_statuses](#class-helper-methods)
- [#status_transitions](#c-transition-methods)
- [#status_transitions_for(:draft | :published | :archived)](#c-transition-methods)
- [#statuses_for_select, #statuses_for_select(:sorted)](#class-helper-methods)



<a name='scope-summary'></a>
#### ...scope methods

- [#draft](#scopes)
- [#published](#scopes)
- [#archived](#scopes)
- [#not_draft](#scopes)
- [#not_published](#scopes)
- [#not_archived](#scopes)



<a name='i-methods-summary'></a>
#### ...instance methods

> With a StateGate on the :status attribute with states :draft, ;published & :archived.

- [.statuses](#i-state-methods)
- [.human_statuses](#i-state-methods)
- [.human_status](#i-state-methods)
- [.force_draft, .force_published, :force_archived](#i-state-methods)
- [.draft?, .published?, .archived?](#i-state-methods)
- [.not_draft?, .not_published?, .not_archived?](#i-state-methods)
- [.status_transitions](#i-transition-methods)
- [.status_transitions_to?(:draft | :published | :archived)](#i-transition-methods)
- [.statuses_for_select, .statuses_for_select(:sorted)](#i-state-methods)

---

[//]: # "##################################"
[//]: # "#####        Reference       #####"
[//]: # "##################################"


<a name='reference'></a>
## Reference
This section is a full reference for how to use StateGate in your application.

- [Creating a StateGate](#creating-a-state-state)
- [Defining States](#defining-states)
- [Specifying Transitions](#specifying-transitions)
- [Sequential Transitions](#sequential-transitions)
- [Scopes](#scopes)
- [Namespacing to avoid state collisions](#namespacing-to-avoid-state-collisions)
- [Method Return Values](#method-return-values)


---

[//]: # "################################################"
[//]: # "#####         CREATING A STATE GATE        #####"
[//]: # "################################################"


<a name='creating-a-state-state'></a>
### Creating a StateGate
This example creates a minimal state-gate on the `:status` attribute of the Post class,
allowing any state to transition to any other state without restriction.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived
  end
end

Post.new.status  #=> 'draft'

```



---

[//]: # "###################################################"
[//]: # "#####             DEFINING STATES             #####"
[//]: # "###################################################"


<a name='defining-states'></a>
### Defining States

> - [...with unrestricted transitions](#with-unrestricted-transitions)
> - [...with a specified default](#with-a-specified-default)
> - [...with a human display name](#with-a-human-display-name)
> - [...class helper methods](#class-helper-methods)
> - [...instance helper methods](#i-state-methods)



<a name='with-unrestricted-transitions'></a>
#### ...with unrestricted transitions.
> When only states and no transitions are defined, then each state can transition to
any other state without restriction.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived
  end
end

my_post = Post.new
my_post.status                      #=> 'draft'
my_post.update(status: :published)  #=> 'published'
my_post.status = 'archived'         #=> 'archived'
my_post.status = :draft             #=> 'draft'
my_post.status = :revoked           #=> <ArgumentError>
```


<a name='with-a-specified-default'></a>
#### ...with a specified default.
> By default, the status of a new instance is set to the first defined state.
  This can be changed with the `default` option.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived
  end
end

Post.new.status #=> 'draft'
```

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived

    default :published
  end
end

Post.new.status #=> 'published'
```



<a name='with-a-human-display-name'></a>
#### ...with a human display name.
> The value used for a state is frequently a shortened, more succinct, version of the
status displayed to a user. The `human_name` option attaches a String phrase for
an individual state. By default, each state's human name will be its titleized symbol name.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending, human: 'Pending Approval'
    state :published
    state :archived

    default :published
  end
end

Post.human_statuses #=> ['Draft', 'Pending Activation', 'Published', 'Archived']
```


<a name='class-helper-methods'></a>
#### ...class helper methods.


- **#attrs**
  - Returns an Array of the Symbol names for each state, in the order each state was defined.
- **#human_attrs**
  - Returns an Array of the String display names for each state, in the order each
    state was defined.
- **#attrs_for_select**
  - While it's bad practice to set a state directly from user input, it's quite
    common to allow the user to search, or filter, by a specific state.  This method
    returns an Array of Arrays, each containing both the String display name and Symbol
    name for each state, suitable for use in a form `select` field.
  - By default, results are in the order the states were defined, but passing
    `:sorted` will re-order them alphabetically by human name.



```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending, human: 'Pending Approval'
    state :published
    state :archived
  end
end

Post.statuses                     #=> [:draft, :pending, :published, :archived]

Post.human_statuses               #=> ['Draft', 'Pending Activation', 'Published', 'Archived']

Post.statuses_for_select          #=> [ ['Draft', :draft],
                                  #=>   ['Pending Activation', :pending],
                                  #=>   ['Published', :published],
                                  #=>   ['Archived', :archived] ]

Post.statuses_for_select(:sorted) #=> [ ['Archived', :archived] ],
                                  #=>   ['Draft', :draft],
                                  #=>   ['Pending Activation', :pending],
                                  #=>   ['Published', :published] ]

```



<a name='i-state-methods'></a>
#### ...instance helper methods.

- **.attrs**
  - Returns an Array of the Symbol names for each state, in the order each
state was added.
- **.human_attrs**
  - Returns an Array of the String display names for each state, in the order each
state was defined.
- **.human_attr**
  - Returns a String with the display name for the attributes current state.
- **.attrs_for_select**
  - This method returns an Array of Arrays, each containing both the String display name 
    and Symbol name for each state, suitable for use in a form `select` field.
  - By default, results are in the order that each state was added, but passing `:sorted`
    will re-order them alphabetically by human name.
- **.state?**
  - Each state has a predicate method that will return `true` if the state is set,
    and `false` if not.
- **.not_state?**
  - Each state has a predicate method that will return `true` if the state is *not* set,
    and `false` if it is.


```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending, human: 'Pending Approval'
    state :published
    state :archived
  end
end

Post.new.statuses #=> [:draft, :pending, :published, :archived]

Post.new.human_statuses           #=> ['Draft', 'Pending Activation', 'Published', 'Archived']

post.status = :pending            #=> true
post.human_status                 #=> 'Pending Approval'

post.statuses_for_select          #=> [ ['Draft', :draft],
                                  #=>   ['Pending Activation', :pending],
                                  #=>   ['Published', :published],
                                  #=>   ['Archived', :archived] ]

post.statuses_for_select(:sorted) #=> [ ['Archived', :archived] ],
                                  #=>   ['Draft', :draft],
                                  #=>   ['Pending Activation', :pending],
                                  #=>   ['Published', :published] ]

post.draft?                       #=> false
post.pending?                     #=> true
post.published?                   #=> false
post.archived?                    #=> false

post.not_draft?                   #=> true
post.not_pending?                 #=> false
post.not_published?               #=> true
post.not_archived?                #=> true


```


---

[//]: # "###################################################"
[//]: # "#####         SPECIFYING TRANSITIONS          #####"
[//]: # "###################################################"


<a name='specifying-transitions'></a>
### Specifying Transitions

> - [...what is a transition?](#what-is-a-transition)
> - [...forcing a state change](#forcing-a-state-change)
> - [...class helper methods](#c-transition-methods)
> - [...instance helper methods](#i-transition-methods)

<a name='what-is-a-transition'></a>
#### ...what is a transition?
Changing from one state to another is called a transition. The `transitions_to`
option limits which other states each individual state may transition to.

A state can can transition to:

- another single state
- one of many states
- no state at all


```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft,     transitions_to: :pending
    state :pending,   transitions_to: [:published, :draft]
    state :published, transitions_to: :archived
    state :archived
  end
end

post = Post.new
post.status                 #=> 'draft'
post.status = :pending      #=> 'pending'
post.status = :draft        #=> 'draft'
post.status = :pending      #=> 'pending'
post.status = :published    #=> 'published'
post.status = 'archived'    #=> 'archived'
post.status = :published    #=> <ArgumentError>
```



<a name='forcing-a-state-change'></a>
#### ...forcing a state change.
> There are occasions when it's beneficial to be able to force the change from
one state to another:

> - When unit testing transitions, it's enourmously helpful to be able to set
the initial state.
- In production, it occasionally happens that an individual record needs to be
manually updated. Being able to set the state directly allows updating from the
console, rather than the databse.
- When demonstrating a new feature, scenario walkthroughs can be easily configred
in real time.


<a name='i-force-state'></a>
#### :force_state

> Prepending the state name with `force_` will by-pass transition checking and
set the new state.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft,     transitions_to: :pending
    state :pending,   transitions_to: [:published, :draft]
    state :published, transitions_to: :archived
    state :archived
  end
end

post = Post.new
post.status                      #=> 'draft'
post.status = :published         #=> <ArgumentError>
post.status = :force_published   #=> 'published'
```



<a name='c-transition-methods'></a>
#### ...class helper methods.

- **#attr_transitions**
  - Returns a Hash of all states and the transitions they are allowed.
- **#attr_transitions_for(`state`)**
  - Returns an Array of all states the supplied state may transition to.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft,     transitions_to: :pending
    state :pending,   transitions_to: [:published, :draft]
    state :published, transitions_to: :archived
    state :archived
  end
end

Post.status_transitions #=> { draft:     [:pending],
                        #=>   pending:   [:draft, :published],
                        #=>   published: [:archived],
                        #=>   archived:  [] }

Post.status_transitions_for(:draft)    #=> [:pending]
Post.status_transitions_for(:pending)  #=> [:draft, :published]
Post.status_transitions_for(:archived) #=> []
```


<a name='i-transition-methods'></a>
#### ...instance helper methods.

- **.attr_transitions**
  - Returns an Array of the states the attribute may transition to, based on its
current value.
- **.attr_transitions_to?**
  - Returns `true` the attribute may transition from its current value to a given state.


```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft,     transitions_to: :pending
    state :pending,   transitions_to: [:published, :draft]
    state :published, transitions_to: :archived
    state :archived
  end
end

post = Post.new
post.status                   #=> 'draft'
post.status_transitions       #=> [:pending]
post.status = :pending        #=> 'pending'
post.status_transitions       #=> [:draft, :published]
post.status = :force_archived #=> 'archived'
post.status_transitions       #=> []

post.status = :force_draft              #=> 'draft'
post.status_transitions_to?(:pending)   #=> true
post.status_transitions_to?('pending')  #=> true
post.status_transitions_to?(:publised)  #=> false
```



---

[//]: # "###################################################"
[//]: # "#####          SEQUENTIAL TRANSITIONS         #####"
[//]: # "###################################################"


<a name='sequential-transitions'></a>
### Sequential Transitions

#### ...what are sequential transitions?

Sequential transitions, where each state can transition to the previous and/or
next state is a common implementation within both form and service objects.
The `make_sequential` option is included to simplify the configuration.

> In this example, both attributes `:status` and `status_test` have the same
transitions.


```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft,     transitions_to: :pending
    state :pending,   transitions_to: [:draft, :published]
    state :published, transitions_to: [:pending, :archived]
    state :archived,  transitions_to: :published
  end

  state_gate :status_test do
    state :draft
    state :pending
    state :published
    state :archived

    make_sequential
  end
end


Post.status_transitions      #=> { draft:     [:pending],
                             #=>   pending:   [:draft, :published],
                             #=>   published: [:pending, :archived],
                             #=>   archived:  [:published] }


Post.status_Test_transitions #=> { draft:     [:pending],
                             #=>   pending:   [:draft, :published],
                             #=>   published: [:pending, :archived],
                             #=>   archived:  [:published] }
```




#### ...one-way only.

> The `:one_way` parameter will restrict transition to 'next state' only.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft,     transitions_to: :pending
    state :pending,   transitions_to: [:draft, :published]
    state :published, transitions_to: [:pending, :archived]
    state :archived,  transitions_to: :published

    make_sequential :one_way
  end
end


Post.status_transitions      #=> { draft:     [:pending],
                             #=>   pending:   [:published],
                             #=>   published: [:archived],
                             #=>   archived:  [] }

```



#### ...closing the loop.

> The `:loop` parameter will allow the first and last states to transition
to each other, taking into account the `:one_way` option.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived

    make_sequential :loop
  end


  state_gate :status_test do
    state :draft
    state :pending
    state :published
    state :archived

    make_sequential :one_way, :loop
  end
end


Post.status_transitions      #=> { draft:     [:archived, :pending],
                             #=>   pending:   [:draft, :published],
                             #=>   published: [:pending, :archived],
                             #=>   archived:  [:published, :draft] }


Post.status_Test_transitions #=> { draft:     [:pending],
                             #=>   pending:   [:published],
                             #=>   published: [:archived],
                             #=>   archived:  [:draft] }
```



---

[//]: # "###################################################"
[//]: # "#####                  SCOPES                 #####"
[//]: # "###################################################"


<a name='scopes'></a>
### Scopes

#### ...default scopes.

By default two ActiveRecord::Scope are created for each state, making searching
by state super easy.

> One scope will select all records that match the state...

```ruby
scope :draft, ~>{ where(status: 'draft') }
```

> ...and the other will select all records that do __not__ match the state.

```ruby
scope :not_draft, ~>{ where.not(status: 'draft') }
```


```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived
  end
end

draft_post     = Post.create
published_post = Post.create(status: :force_published)

Post.draft.include?(draft_post)          #=> true
Post.draft.include?(published_post)      #=> false

Post.not_draft.include?(draft_post)      #=> false
Post.not_draft.include?(published_post)  #=> true
```
</details>


#### ...no scopes.

> Scopes can be turned off with the `no_scopes` option

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived

    no_scopes
  end
end

Post.draft  #=> <NoMethodError>
```


---

[//]: # "###################################################"
[//]: # "#####  NAMESPACING TO AVOID STATE COLLISIONS  #####"
[//]: # "###################################################"


<a name='namespacing-to-avoid-state-collisions'></a>
### Namespacing to avoid state collisions

#### ...what collisions?

When two attributes within the same model each have a state with the same name,
there will be conflicts when creating scope and predicate methods. The
`prefix` and `postfix` options provide a mechanism to namespace states, avoiding
this issue.

> In this example the class scope `#draft` and the instance predicate `.draft?`
will be created as normal for the `:status` state_gate, but will raise an
exception when creating the `:invoice_status` state_gate.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived
  end

  state_gate :invoice_status do
    state :draft
    state :finalised
    state :paid
  end
end

<StateGate::ConflictError>
```


#### ...prefix & suffix

> The `prefix` option prepends each state with the given name, while the 
  `suffix` option appends it to the end of each state.

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived
  end

  state_gate :job_status do
    state :queued
    state :processing
    state :completed

    prefix :job
  end

  state_gate :invoice_status do
    state :draft
    state :issued
    state :paid

    suffix :invoice
  end
end

Post.draft           #=> <ArctiveRecord::Relation>
Post.pending         #=> <ArctiveRecord::Relation>
Post.published       #=> <ArctiveRecord::Relation>
Post.archived        #=> <ArctiveRecord::Relation>

Post.job_queued      #=> <ArctiveRecord::Relation>
Post.job_processing  #=> <ArctiveRecord::Relation>
Post.job_archived    #=> <ArctiveRecord::Relation>

Post.draft_invoice   #=> <ActiveRecord::Relation>
Post.issued_invoice  #=> <ActiveRecord::Relation>
Post.paid_invoice    #=> <ActiveRecord::Relation>
```


---

[//]: # "###################################################"
[//]: # "#####           METHOD RETURN VALUES          #####"
[//]: # "###################################################"


<a name='method-return-values'></a>
### Method Return Values

#### ...perdicate methods.

> Predicate methods, those that end with a question mark, will always return
`true` or `false`. They will never return any other value or raise any exceptions.

```ruby
post.draft?     #=> true
post.archived?  #=> false
```


#### ...getter methods.

> Getter methods, those that expect a value to be returned, will always return
a 'truthy' value such as a `String`, `Symbol`, `Array` or `Hash`, as specified
in the documentation above. They will never return `nil`, `false` nor
raise any exceptions.

```ruby
Post.status_transitions  #=> { draft:     [:archived, :pending],
                         #=>   pending:   [:draft, :published],
                         #=>   published: [:pending, :archived],
                         #=>   archived:  [:published, :draft] }
```



#### ...setter methods.

> Setter methods, those that make changes, will always return
the expected `ActiveRecord` response if successfull. If the new state is invalid
or the transition is not allowed, an `ArgumentError` exception will be raised.

**Note:** the exception is raised even if the change is not being persisted to
the database.

```ruby
post.state = :dummy                 #=> <ArgumentError>
post.update(state: :dummy)          #=> <ArgumentError>
post.update_column :state, :dummy   #=> <ArgumentError>
```


---

[//]: # "###################################################"
[//]: # "#####            RSPEC TEST HELPERS           #####"
[//]: # "###################################################"


<a name='rspec-test-helpers'></a>
## Testing with RSpec

> - [...testing states](#testing-states)
> - [...testing transitions](#testing-transitions)


<a name='testing-states'></a>
#### ...testing states.

Rspec matcher `have_states` tests the defined states for a given attribute.


> With the follow configuration...

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
  end
end
```

> ...it passes with the correct states and attribute.

```ruby
expect(Post).to have_states(:draft, :pending).for(:status)
#=> success
```

> ...it fails with a missing state.

```ruby
expect(Post).to have_states(:pending).for(:status)
#=> fails: ':draft is also a valid state for #status.'
```

> ...it fails with a non-defined state.

```ruby
expect(Post).to have_states(:draft, :pending, :dummy).for(:status)
#=> fails: ':dummy is not a valid state for #status.'
```


> ...it fails with the wrong attribute.

```ruby
expect(Post).to have_states(:draft, :pending).for(:category)
#=> fails: 'no state_gate is defined for #category.'
```


<a name='testing-transitions'></a>
#### ...testing transitions.

Rspec matcher `allow_transitions_on` tests the transitions for a given
attribute state.


> With the follow configuration...

```ruby
class Post < ActiveRecord::Base
  include StateGate

  state_gate :status do
    state :draft
    state :pending
    state :published
    state :archived

    make_sequential
  end
end
```

> ...it passes with the correct transitions for the state.

```ruby
expect(Post).to allow_transitions_on(:status).from(:draft).to(:pending)
#=> success

expect(Post).to allow_transitions_on(:status).from(:pending).to(:draft, :Published)
#=> success
```

> ...it fails with a missing transition.

```ruby
expect(Post).to allow_transitions_on(:status).from(:pending).to(:Published)
#=> fails: ':pending is allowed to transition from :pending to :draft.'
```

> ...it fails with a non-defined transition.

```ruby
expect(Post).to allow_transitions_on(:status).from(:draft).to(:pending, :dummy)
#=> fails: '#status does not transition from :draft to :dummy.'
```


> ...it fails with the wrong attribute.

```ruby
expect(Post).to allow_transitions_on(:dummy).from(:pending).to(:draft, :Published)
#=> fails: 'no state_gate is defined for #dummy.'
```



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


