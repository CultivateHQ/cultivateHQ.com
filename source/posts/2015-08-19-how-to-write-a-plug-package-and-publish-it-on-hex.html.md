---
title:  "How to write a plug package and publish it on hex"
author: Mark Connell
description: This is a walkthrough on the process of creating a new plug package and getting it published on Hex.
tags: elixir
---

Last week, I went through the process of creating a Plug for the first time.
This is a walkthrough documenting that process.

## Create a new Elixir project

For the purposes of this walkthrough, we're going to make a nice and simple plug that inserts a
custom HTTP header `x-hello-world` into every response our server sends. To get
started, lets create a new Elixir project:

```bash
mix new hello_world_header
```

Once your new project is created, there should be a couple of generated commands to switch
to the new project directory and run the tests:

```bash
cd hello_world_header
mix test
```

## Create our simple plug

Now that we have our project, we need to create the skeleton for our Plug.

### Sort out dependencies

First, we need to setup our expected dependencies: Plug and Cowboy. Updating
the application and deps functions, you should end up with a `mix.exs` file
that looks a bit like:

```elixir
defmodule HelloWorldHeader.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_world_header,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~>1.0"}
    ]
  end
end
```

(Set the versions of cowboy and plug to be more current depending when you read this).

### Sketch out the shape of a plug

In order for a module to be pluggable, it needs to include 2 specific functions: `init` and `call`.

#### `init`

When we eventually declare our plug in our project, we'll use a snippet of code like:

```elixir
  plug HelloWorldHeader
```

`init` is invoked at this point, so if we want to pass some options to `init`, we would do that like so:

```elixir
  plug HelloWorldHeader, message: "hello world!"
```

#### `call`

This function is responsible for handling the connection (request/response cycle) portion. This function expects
to receive two arguments: `connection` and `options`, where `options` are the return of the `init` function.

### Add `init` and `call` to `hello_world_header.ex`

```elixir
defmodule HelloWorldHeader do
  def init(options) do
    options
  end

  def call(conn, _options) do
    conn
  end
end
```

This is a plug at it's most basic level. At the moment it's so basic, it's pretty much pointless as it will
immediately handle a connection, and pass it straight on. But it gives us everything we need to get going.

### Add a test for our desired behaviour

Lets crack open `hello_world_header_test.exs` and get a test up and running. The first thing we want to do
is add a dead simple test just to make sure we are on the right path and our plug will work.

```elixir
# test/hello_world_header_test.exs
defmodule HelloWorldHeaderTest do
  use ExUnit.Case, async: true
  use Plug.Test

  # Demo module with plug and a simple index action
  defmodule DemoPlug do
    use Plug.Builder

    plug(HelloWorldHeader)

    plug(:index)
    defp index(conn, _opts), do: send_resp(conn, 200, "OK")
  end

  test "it works!" do
    conn =
      :get
      |> conn("/")
      |> DemoPlug.call([])

    assert conn.status == 200
  end
end
```

What we've done here is simply add a simple module which makes use of our plug and defines a
basic index function that returns a `200` status code.

Now lets add an additional test for our custom HTTP header:

```elixir
  test "we receive a custom header with content" do
    conn =
      :get
      |> conn("/")
      |> DemoPlug.call([])

    assert get_resp_header(conn, "x-hello-world") == ["YEAH IT WORKS!"]
  end
```

Running our tests (`mix test`), we can see that the first test passes, and this one fails.

### Make our test pass

Lets add our header to our plug:

```elixir
  def call(conn, _options) do
    Plug.Conn.put_resp_header(conn, "x-hello-world", "YEAH IT WORKS!")
  end
```

We now have a plug which injects our new header into every request!

## Publish to Hex

### Add package metadata

We need to add some helpful metadata to our project. Lets update our `mix.exs` file:

```elixir
defmodule HelloWorldHeader.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_world_header,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~>1.0"}
    ]
  end

  defp package do
    [
      contributors: ["Mark Connell"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/cultivatehq/hello_world_header"},
      files: ~w(lib mix.exs README.md)
    ]
  end
end
```

### submit to Hex

If you've never submitted a package to hex before, you'll need to register as a new user. More
details on the process can be found [here](https://hex.pm/docs/publish) if you get stuck.

```bash
mix hex.user register
```

Once you're done with that all that's left to do is

```bash
mix hex.publish
```

And your package is now published to [hex.pm](https://hex.pm/packages/hello_world_header) for the world to use!
