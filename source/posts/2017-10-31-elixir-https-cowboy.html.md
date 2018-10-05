---
title: Using HTTPS with Elixir on Cowboy
author: Fernando Briano
description: How to serve https from a simple Elixir app running locally with Cowboy in development mode
tags: elixir
date: 2017/10/31
---

We recently needed to serve requests via HTTPS locally in our Elixir app. We found several ways of doing it in a Phoenix app, but we just had a [Plug](https://github.com/elixir-plug/plug) running on Cowboy. We had to go into some source code and documentation to figure out how to make this work. Here's how we learned to serve https in our local development environments.

To get started, create a new mix app:

```bash
mix new secure_app
cd secure_app
```

Add `cowboy` and `plug` as dependencies in the `mix.exs` file:

```elixir
  defp deps do
    [
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.4"}
    ]
  end

```

Run `mix deps.get` in the command line to install these dependencies. We'll write a very simple plug for this example, similar to the one in the Plug documentation. You can check [How to write a plug package and publish it on hex](/posts/how-to-write-a-plug-package-and-publish-it-on-hex/) for more information on writing Plugs.

In `lib/secure_app/hello_plug.ex`, we write this code:

```elixir
defmodule SecureApp.HelloPlug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<h1>Hello 🌍</h1>")
  end
end
```

We want to start our Plug application under the supervision tree, so in `lib/secure_app.ex` we write:

```elixir
defmodule SecureApp do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(
        :http,
        SecureApp.HelloPlug,
        [],
        port: 8080
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

Finally, add the module to our `mix.exs` file:

```elixir
  def application do
    [
      extra_applications: [:logger],
      mod: {SecureApp, []}
    ]
  end
```

If we run the app with `mix run --no-halt` and visit http://localhost:8080 in a web browser, we'll see our "Hello world" message.

Looking for information on HTTPS in Elixir, we found [the documentation for the Cowboy adapter](https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html#content) in the Plug library. We actually found this documentation in the source code first, which says we're either bad at searching online or there's some search engine optimization missing there.

From the docs, we got almost everything we needed to get https running. First thing to notice is:

>`:port` - the port to run the server, defaults to 4000 (http) and 4040 (https).

The most interesting part is in [the `https` function](https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html#https/3). It gives us a code example with everything we need to add to our app to make it serve https.

We're going to need certificates for localhost, and we found [this blog post](http://ohanhi.com/phoenix-ssl-localhost.html) by Ossi Hanhinen had the commands to generate a self-signed certificate. We generated the key and certificate in the `priv/keys` directory inside our project.

Now the code for `start` in our module looks like this:

```elixir
def start(_type, _args) do
  cowboy_options = [
    keyfile: "priv/keys/localhost.key",
    certfile: "priv/keys/localhost.cert",
    otp_app: :secure_app
  ]

  children = [
    Plug.Adapters.Cowboy.child_spec(
      :https,
      SecureApp.HelloPlug,
      [],
      cowboy_options
    )
  ]

  Supervisor.start_link(children, strategy: :one_for_one)
end
```

We are not setting a port since we know from the documentaion that https defaults to 4040, but we could add it in `cowboy_options`. If we run our app now with `mix run --no-halt`, we can visit the app on localhost using `https`:

![HTTPS localhost](/images/posts/elixir-https-cowboy.gif "HTTPS localhost")
