---
author: Paul Wilson
title: Using Ecto 2, without Phoenix, but with tests
description: Using Ecto without Phoenix is a bit fiddly to set up. This is a step-by-step tutorial to getting through that.
---

My guess is that the majority of people using [Ecto](https://hexdocs.pm/ecto/Ecto.html) are using it from [Phoenix](http://www.phoenixframework.org). Through [Phoenix Ecto](https://github.com/phoenixframework/phoenix_ecto), they get a lot of the boilerplate code generated for them. Using _Ecto_ by itself, means that you need to deal with that boilerplate.

There are a couple of reasons that you would want to use _Ecto_ this way. The most obvious is that you are writing something without a web frontend, but that needs database access. Another is that you have (correctly) decided that mixing your persistence tier up with your web framework is unhygienic: you are using an [Umbrella project](http://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-apps.html) to separate out your persistence, domain, and web tiers.

To be fair, most of the information is in [this Hex Docs](https://hexdocs.pm/ecto/Ecto.html) page, but I believe there is some value in presenting a worked example that includes `ExUnit` tests. This will also serve as the basis for a subsequent post on testing database interactions taking place in OTP processes.

The example code is also in [this](https://github.com/CultivateHQ/ecto_todos) repository.

## Setting Up

Let's create our example, supervised, application; something to hold a _to do list_. 

```
mix new --sup todos
cd todos
```

Add Ecto and Postgres (assuming Postgres) to mix.exs dependencies and application to _mix.exs_.

```
  def application do
    [applications: [:logger, :ecto, :postgrex],
     mod: {Todos, []}]
  end

  defp deps do
    [
      {:ecto, "~> 2.0.4"},
      {:postgrex, ">= 0.0.0"},
    ]
  end
```

We need to create our Repo ourselves. Make the file _lib/todos/repo.ex_ with the following content.

```
defmodule Todos.Repo do
  use Ecto.Repo, otp_app: :todos
end
```

A _Repo_ is a Supervisor; we need to add it to our application's supervision tree. In _lib/todos.ex_ add to the application supervisor.

```
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Todos.Repo, []), # <--- Add this line
    ]

    opts = [strategy: :one_for_one, name: Todos.Supervisor]
    Supervisor.start_link(children, opts)
  end
```

The _Repo_ will be looking for configuration. Let's put our development config in _config/dev.exs_. I'm using the same assumptions as Phoenix: that there's a dev database server on localhost with a super-user called 'postgres' with an easy-to-guess password.

```
use Mix.Config

config :todos, Todos.Repo,[
  adapter: Ecto.Adapters.Postgres,
  database: "todos_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
]
```

We'll need to ensure that `dev.exs` is compiled by including it in `config/config.exs`. While we're in that file we will configure the `Mix tasks` to use the correct Repo.

```
config :todos, :ecto_repos, [Todos.Repo] # Required for Mix tasks, such as mix ecto.gen.migration

import_config "#{Mix.env}.exs" # Should just need to uncomment this line
```

On the command line, we should be able to successfully run the following.

```
mix deps.get
mix ecto.create
```

Now let's add our _todos_ table, to hold our "to do" list. 

```
mix ecto.gen.migration AddTodos
```

This will create the directories _priv/repo/migrations/_. Within migrations edit file called _[timestamp]_add_todos.exs, to create the table.


```
defmodule Todos.Repo.Migrations.AddTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :item, :string
      add :completed, :boolean, default: false

      timestamps
    end
  end
end
```

We'll also want to create the schema that maps to the table. My preference is to follow the boilerplate used by _Phoenix Ecto_. Let's create the file _lib/todos/todo.ex_


```
defmodule Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :item, :string
    field :completed, :boolean, default: false

    timestamps
  end

  @required_fields ~w(item completed)
  @optional_fields ~w()


  def changeset(record, params \\ :empty) do
    record
    |> cast(params, @required_fields, @optional_fields)
  end
end
```

We can apply the migration by running:

```
mix ecto.migrate
```

Let's give it a bit of a spin:


```
$ iex -S mix
iex(1)> Todos.Todo.changeset(%Todos.Todo{}, 
  %{item: "Check from iex"}) |> Todos.Repo.insert 
{:ok,
 %Todos.Todo{__meta__: #Ecto.Schema.Metadata<:loaded, "todos">,
  completed: false, id: 2, ... }}


iex(2)> Todos.Todo |> Todos.Repo.all

 %Todos.Todo{__meta__: #Ecto.Schema.Metadata<:loaded, "todos">,
  completed: false, id: 2, ... }]
iex(3)> 

```

# Tests and functionality

Now we are ready to add some functionality and, of course, some tests. As I've been cheerfully ignoring Michael Feather's [definition of unit tests](http://www.artima.com/weblogs/viewpost.jsp?thread=126923) since 2005, let's set up the test database. Add _config/test.exs_

```
use Mix.Config

config :todos, Todos.Repo,[
  adapter: Ecto.Adapters.Postgres,
  database: "todos_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
]
```

Run

```
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate
```

We want to use the `Repo` in Sandbox mode, so that we can take run concurrent tests, and also be sure that database changes are transient. Add to the bottom of `test/test_helper.exs`

```
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Todos.Repo, :manual)
```

Let's write a test in _test/todos/todo_items_test.exs_

```
defmodule Todos.TodoItemsTest do
  alias Todos.TodoItems
  use ExUnit.Case

  test "adding and retrieving todo items" do
    assert [] == TodoItems.items

    TodoItems.add("Make example app")
    TodoItems.add("Write blog post")

    assert [{"Make example app", false}, {"Write blog post", false}] == TodoItems.items
  end
end
```

The test will fail, because we have not written an implementation. Let's do that in `lib/todos/todo_items.ex`.

```
defmodule Todos.TodoItems do
  alias Todos.{Repo, Todo}
  import Ecto.Query

  def items do
    (from t in Todo, select: {t.item, t.completed})
    |> Repo.all
  end

  def add(item) do
    Todo.changeset(%Todo{}, %{item: item})
    |> Repo.insert!
  end
end
```

Run

```
mix test
```

It fails. But happily it tells us exactly why it fails:

```

  1) test adding and retrieving todo items (Todos.TodoItemsTest)
     test/todo_items_test.exs:5
     ** (DBConnection.OwnershipError) cannot find ownership process for #PID<0.218.0>.
     
     When using ownership, you must manage connections in one
     of the three ways:
     
       * By explicitly checking out a connection
       * By explicitly allowing a spawned process
       * By running the pool in shared mode

```

We need to checkout the repo, before running the test. Add to 'lib/todos/todo_items.ex'

```
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end
```

It all passes! Hooray. You are up to [here](https://github.com/CultivateHQ/ecto_todos/tree/without-process) in the example repository.

Next up - testing database interaction in other processes.
