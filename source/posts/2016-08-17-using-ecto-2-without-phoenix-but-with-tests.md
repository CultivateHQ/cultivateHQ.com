---
author: Paul Wilson
title: Using Ecto 2, without Phoenix, but with tests
description: I believe most users of Ecto, use it within a Phoenix project. This is a step-by-step guide to using Ecto by itself, using an example project. Includes tests.
---


[Outline]

* I'd bet that most people use Ecto within a Phoenix _application_. 
* Phoenix helps you with the Ecto setup through (Phoenix Ecto)[https://github.com/phoenixframework/phoenix_ecto]
* Standalone - there's a few things you need to do yourself
* Most of the information is in (this Hex Docs)[https://hexdocs.pm/ecto/Ecto.html] document, but thought it would be worthwhile to work through an example adding setup for ExUnit tests

[Why standalone]

* Because you're writing a non-phoenix web thing, that needs access to the database
* Because you are writing Phoenix a web application, but are using Umbrella application to separate out the  the _persistence_ layer.


[Below pasted from notes]

## basic setup

```
mix new --sup todos
cd todos

```
mix.exs
```
  defp deps do
    [{:ecto, "~> 2.0.4"},
      {:postgrex, ">= 0.0.0"},
    ]
  end
```
also add to apps

`mix deps.get`

```
defmodule Todos.Repo do
  use Ecto.Repo, otp_app: :todos
end
```


config/config.exs

Uncomment and add repos 
```
config :todos, :ecto_repos, [Todos.Repo]

import_config "#{Mix.env}.exs"
```

Add dev.exs

```
use Mix.Config

config :todos, Todos.Ecto.Repo,[
  adapter: Ecto.Adapters.Postgres,
  database: "todos_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
]
```


In lib/todos.ex

```
    children = [
      supervisor(Todos.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Todos.Supervisor]
    Supervisor.start_link(children, opts)

```
`mix ecto.create`

` mix ecto.gen.migration AddTodos`

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

lib/todos/todo.ex
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

# tests and functionality

./config/test.exs

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

./test/test/helper.exs

```
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(HolidayTracking.Ecto.Repo, :manual)
```

`MIX_ENV=test mix ecto.create`


Write the test
```
defmodule Todos.TodoItemsTest do
  alias Todos.{TodoItems}
  use ExUnit.Case

  test "adding and retrieving todo items" do
    assert [] == TodoItems.items

    TodoItems.add("Make example app")
    TodoItems.add("Write blog post")

    assert [{"Make example app", false}, {"Write blog post", false}] == TodoItems.items
  end
end
```

Implement

lib/todos/todo_items.ex

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

`mix test`

```
 1) test adding and retrieving todo items (Todos.TodoItemsTest)
     test/todos/todo_items_test.exs:5
     ** (DBConnection.OwnershipError) cannot find ownership process for #PID<0.209.0>.
     
     When using ownership, you must manage connections in one
     of the three ways:
     
     ... 
```
Add set up to test

```
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end
```

### Process

* See final versions
* Have to create process per test
* 

If we try and re-use a process in the supervision tree, in 2nd test
```
  1) test completing items (Todos.TodoItemsTest)
     test/todos/todo_items_test.exs:22
     ** (exit) exited in: GenServer.call(#PID<0.177.0>, {:add, "Find bucket"}, 5000)
         ** (EXIT) exited in: GenServer.call(#PID<0.200.0>, {:checkout, #Reference<0.0.3.792>, true, 15000}, 5000)
             ** (EXIT) shutdown: "owner #PID<0.199.0> exited with: shutdown"
     stacktrace:
       (elixir) lib/gen_server.ex:604: GenServer.call/3
       test/todos/todo_items_test.exs:23: (test)


```

