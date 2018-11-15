---
author: "Paul Wilson"
title: "Elixir nested modules, imports, and aliases"
description: "Module nesting in Elixir is syntactic sugar with some unexpected (undocumented) alias and import behaviours"
tags: elixir, today_i_learned
date: 2018/11/15
---


Elixir dotted namespacing is not sophisticated. As in Erlang, a module name is just an [`atom`](https://elixir-lang.org/getting-started/basic-types.html#atoms). A namespaced module name like `Nesting.Nested` is really just an alias to the atom `:"Elixir.Nesting.Nested"`; the namespacing is a convention rather than something built into the language.

One exception is the teaspoon of syntactic sugar that sweetens defining a module within a module.

```elixir
defmodule Nesting do
  defmodule Nested do
    # The Nested module is really Nesting.Nested
    def inner_hello, do: :inner_hello
  end
  # There is an implicit
  # alias Nesting.Nested here
  def outer_to_inner_hello, do: Nested.inner_hello()
end
```

The sugar has given us the automatic "namespacing" of `Nested` and the implicit alias of `Nesting.Nested` to `Nested` within the rest of the module.

This is all [documented](https://hexdocs.pm/elixir/Kernel.html#defmodule/2). It is also the extent of the sugar: the code below does not compile.

```elixir

defmodule Deep.Nesting do
  def outer, do: :outer

  defmodule Nested do
    # WILL NOT COMPILE: Deep.Nesting would need to be directly
    # referenced or aliased
    def inner_outer, do: Nesting.outer()

    # ALSO INVALID. We would not really expect
    # Deep.Nesting functions to be imported
    def inner_outer2, do: outer()
  end
end
```

Ok, I lied. There are some other surprising aspects to nested modules: 

* While the outer module's functions are not imported to the inner, any imports to the outer module are also available to the inner one. 
* While the outer module is not implicitly aliased in the inner module, any modules aliased in the outer module are also aliased in the inner.

```elixir
defmodule Namespace.InNamespace do
  def a_thing, do: :thing
end

defmodule Nesting do
  alias Namespace.InNamespace
  import Enum, only: [map: 2]

  defmodule Nested do
    # Enum import is available
    def inner_map, do: map([1, 2, 3], &(&1 * 2))

    # Alias also available
    def inner_thing, do: InNamespace.a_thing()
  end
end
```

I can not find this behaviour documented anywhere but it may be worth knowing, especially if trying to figure out import or alias clashes.




