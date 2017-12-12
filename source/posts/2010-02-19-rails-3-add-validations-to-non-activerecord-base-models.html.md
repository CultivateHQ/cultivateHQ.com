---
  title: "Rails 3: Add validations to non-ActiveRecord::Base models"
  author: Mark Connell
  description: Prior to Rails 3, if you wanted to add validations to models which didn't inherit from `ActiveRecord::Base`, you'd probably resort to using a gem/plugin that re-implements much of the behaviour or has some dirty hooks into the ActiveRecord private API.
  tags: ruby
---

Prior to Rails 3, if you wanted to add validations to models which didn't inherit from `ActiveRecord::Base`, you'd probably resort to using a gem/plugin that re-implements much of the behaviour or has some dirty hooks into the ActiveRecord private API.

Now, the ActiveRecord internals have been re-written as modules and pushed out into the ActiveModel gem. ActiveRecord still uses these modules, only now, it is relatively straight forward to use the same logic in other classes.

Below is a basic sample you can tryout in an irb session which includes the `ActiveModel::Validations` module:

```ruby
require 'active_model'

class Place
  include ActiveModel::Validations
  validates_presence_of :name
  attr_accessor :name
end

place = Place.new
place.valid?
#> false

place.name = "le pub"
place.valid?
#> true
```

For any applications which require non-persisting models, or even models that don't use ActiveRecord, it's now a whole lot easier to introduce AR conventions without any pain.
