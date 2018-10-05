---
title: "Rails 3: Validation Reflection"
author: Mark Connell
description: A recent addition to `ActiveModel` is the introduction of a couple of methods for validation reflection.
tags: ruby
date: 2010/02/22
---

A recent addition to `ActiveModel` is the introduction of a couple of methods for validation reflection.

Say we have a sample `Person` class which includes the `ActiveModel::Validations` module so we can validate a couple of attributes:

```ruby
require 'active_model'

class Person
  include ActiveModel::Validations
  attr_accessor :name, :age
  validates :name, :presence => true
  validates :age,  :presence => true, :numericality => true
end
```

New to `ActiveModel::Validations` is the class method `validators`, which returns an array of `Validator` objects associated with the model:

```ruby
Person.validators
#> [#<ActiveModel::Validations::PresenceValidator:0x101565cc8 @attributes=[:age], @options={}>,
#   #<ActiveModel::Validations::NumericalityValidator:0x101562640 @attributes=[:age],
#       @options={:only_integer=>false, :allow_nil=>false}>,
#   #<ActiveModel::Validations::PresenceValidator:0x1015691c0 @attributes=[:name], @options={}>]
```

Another addition is the class method `validators_on`, which provides a convenient way of accessing the validators that are associated with a particular attribute on the model:

```ruby
Person.validators_on(:name)
#> [#<ActiveModel::Validations::PresenceValidator:0x1015691c0 @attributes=[:name], @options={}>]

Person.validators_on(:age)
#> [#<ActiveModel::Validations::PresenceValidator:0x101565cc8 @attributes=[:age], @options={}>,
#   #<ActiveModel::Validations::NumericalityValidator:0x101562640 @attributes=[:age],
#       @options={:only_integer=>false, :allow_nil=>false}>]
```

## Notes
* The `validators` and `validators_on` methods are only found in activemodel-3.0.0.beta1.gem onwards.
* The specific commit that introduces these methods can be found here: [http://github.com/rails/rails/commit/8f97e9d19abf02b33c5f7c0c1f1d5daf13e28893](http://github.com/rails/rails/commit/8f97e9d19abf02b33c5f7c0c1f1d5daf13e28893)
