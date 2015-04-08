---
title: "Ruby constant resolution"
author: Paul Wilson
descrption: "Module and class nesting is how Ruby does namespacing, but it's not always that well known how constants are resolved"
---

Module and class nesting is how Ruby does namespacing, but it's not always that well known how constants are resolved when we're not using the fully qualified names. Bearing in mind that Ruby classes and modules are themselves constant, it's quite handy to know this stuff.

First of all here are the unsurprising rules:

## Obvious rule: constants defined in outer modules ere available in nested modules, all the way down

```
module A
  MyConst = "I'm a string"
  module B
    p [:at_b, MyConst]
    module C
      p [:at_c, MyConst]
    end
  end
end
```

If you run the above, it all works. Unqualifed ```MyConst``` works all the way down.

```
module A
  MyConst = "I'm at A"
  p [:at_a, MyConst]
  module B
    MyConst = "I'm at B"
    p [:at_b, MyConst]
    module C
      p [:at_c, MyConst]
    end
  end
end

```
No big surprise that the first matching constant when searching up the nesting hierarchy is used. So the output to the above is

```
[:at_a, "I'm at A"]
[:at_b, "I'm at B"]
[:at_c, "I'm at B"]
```

## Obvious rule: inheriting a class or mixing in a module, makes its constants available

```
module A
  MyConst = "I'm in A"
end

module D
  include A
  p MyConst
end
```

```
class A
  MyConst = "I'm in A"
end

class D < A
  p MyConst
end
```

## Surprising rule: including a module (or inheriting a class) does not make that class's constants available to nested modules

```
module A
  MyConst = "I'm a string"
end

module B
  include A
  p [:in_a, MyConst] # this works
  module C
    p [:in_c, MyConst] # this fails
  end
end
```

MyConst is unavailable to module ```C```, even though the inluded module ```B``` is nested within ```A```.

```
uninitialized constant B::C::MyConst (NameError)
```

The following weird looking code does, however, runs fine.

```
module A
  MyConst = "I'm a string"
end

module B
  include A
  MyConst = MyConst  
  module C
    p [:in_c, MyConst]
  end
end
```


## Surprising rule: it all depends on how you write your module or class definition

Let's revisit the first obvious rule.

```
module A
  MyConst = "I'm a string"
end

module A
  module B
    p MyConst
  end
end
```

Still no big surprise here. Re-opening modue ```A``` to define nested ```B``` still works fine.

However:-

```
module A
  MyConst = "I'm a string"
end

module A::B
  p MyConst
end
```

This seemingly equivalent code falls right over.

```
uninitialized constant A::B::MyConst (NameError)
```

What a shocker! Using the shorter ```A::B``` syntax to define your module (or class - try it) truncates your constant resolution. I bet that whole "it's available in the module I included, but not in 

## The explanations

There's a more complete writeup of constant resoulution [here](https://valve.github.io/blog/2013/10/26/constant-resolution-in-ruby/), but briefly the ordered search path for constants is defined by:-

```
[Module.nesting + Module.ancestors]
```

When trying to resolve a constant, first the interpreter searches up the list of enclosing modules and then searches the _current_ module's ancestors; the first match wins. The ancestors of of modules that enclose the current module do not get involved. 

```Module.nesting``` is affectd by how it is defined in the current context. When it is done in the shorter ```A::B::C``` style the enclosing modules are not included.

```
module A
  module B
    module C
      p [:longhand_nesting, Module.nesting]
    end
  end
end

module A::B::C
  p [:shorthand_nesting, Module.nesting]
end
```

Running the above outputs:-

```
[:longhand_nesting, [A::B::C, A::B, A]]
[:shorthand_nesting, [A::B::C]]
```
