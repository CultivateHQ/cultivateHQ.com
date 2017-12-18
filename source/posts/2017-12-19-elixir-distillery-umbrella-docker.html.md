---
title: Building and configuring a Phoenix app with Umbrella for releasing with Docker
author: Fernando Briano
description: A tutorial to understand how Phoenix, Umbrella, Distillery and Docker fit together.
tags: elixir
image: /images/posts/paraguas.jpg
---

This tutorial goes through the process of building *Elixir* and *Phoenix* apps within an *Umbrella* project, releasing it with *Distillery* and containerizing it with *Docker*, ready for deploying in production. There's an [accompanying repository](https://github.com/CultivateHQ/paraguas) for this tutorial, but you'll find commits related to each part linked in the article whenever it's relevant.

## Opening the umbrella

From a common pattern when building Erlang applications, came `umbrella`. Umbrella projects are a way to break apart different parts of a project into smaller isolated applications. This was implemented into Mix (Elixir's build tool for creating, compiling and testing applications and managing its dependencies) [in Elixir 0.9.0](https://elixir-lang.org/blog/2013/05/23/elixir-v0-9-0-released/#umbrella-projects).

When you create a new project in Elixir using mix, you can pass the `--umbrella` parameter to implement this pattern. The command itself is pretty self-explanatory:

```bash
$ mix new paraguas --umbrella
* creating .gitignore
* creating README.md
* creating mix.exs
* creating apps
* creating config
* creating config/config.exs

Your umbrella project was created successfully.
Inside your project, you will find an apps/ directory
where you can create and host many apps:

    cd paraguas
    cd apps
    mix new my_app

Commands like "mix compile" and "mix test" when executed
in the umbrella project root will automatically run
for each application in the apps/ directory.
```

[\[GITHUB REPO\]: What the code looks like now](https://github.com/CultivateHQ/paraguas/commit/cc2589243ea8e19af5ace4d9cb04b793977f7e1c).

## Adding Phoenix to the mix

[Phoenix](http://phoenixframework.org/) is a web development framework written in Elixir. This post assumes you've already [installed Phoenix](https://hexdocs.pm/phoenix/installation.html) and its dependencies. To create the app, we'll do it inside `paraguas/apps`. We won't use Ecto (database wrapper) for this example, so we can skip the database setup and focus on the build process:

```bash
$ cd apps
$ mix phx.new phoenix_app --no-ecto
```

We can now run the web app from the umbrella project root:

```bash
$ mix phx.server
```

[\[GITHUB REPO\]: Adding Phoenix](https://github.com/CultivateHQ/paraguas/commit/c8de5d363d18bdc3c3e712780edcc68d92abcfbd).

We're going to add [basic_auth](https://github.com/cultivatehq/basic_auth) to the web app for ExtraSecurity™ and to have more environment variables to use as an example. We start by adding the dependency in `paraguas/apps/phoenix_app/mix.exs`:

```elixir
defp deps do
[
  ...,
  {:basic_auth, "~> 2.2.2"}
]
```

To configure basic_auth, we'll add the corresponding configuration in the `dev.exs`, `test.exs` and `prod.exs` files. We'll set simple credentials for the development and test environments and will load proper credentials from environment variables in production. Remember to fix your default Phoenix test to use authentication.

```elixir
# paraguas/apps/phoenix_app/config/dev.exs
config :phoenix_app, authentication: [
  username: "user",
  password: "password",
  realm:    "Development Realm"
]
```
I used this same configuration ☝ for `text.exs`.

```elixir
# paraguas/apps/phoenix_app/config/prod.exs
config :phoenix_app, authentication: [
  username: {:system, "BASIC_AUTH_USERNAME"},
  password: {:system, "BASIC_AUTH_PASSWORD"},
  realm:    {:system, "BASIC_AUTH_REALM"}
]
```

Finally, add BasicAuth to the router pipeline:

```elixir
# paraguas/apps/phoenix_app/lib/phoenix_app_web/router.ex
pipeline :authentication do
  plug BasicAuth, use_config: {:phoenix_app, :authentication}
end

scope "/", PhoenixApp do
  pipe_through [:browser, :authentication]
 get "/", PageController, :index
end
```

Run `mix deps.get` and `mix phx.server` again to start the web app with basic auth enabled.

[\[GITHUB REPO\]: Adding basic_auth](https://github.com/CultivateHQ/paraguas/commit/af94967767ce0c97610eaa0c36ac47e882e9183f)

## Apps interacting under the umbrella

Now, let's create another app to interact with our web app so we can take advantage of umbrella. Again, we're building a very simple app so we can focus on build details further ahead.

```bash
# paraguas/apps
$ mix new greeter
```

We're just going to write a `hello/1` method in our greeter, to greet a given name:

```elixir

defmodule Greeter do
  def hello(name), do: "Hello #{name}"
end

```

Our web app is going to use this code to greet people. So we need to add it as a dependency in the Phoenix app. Since we're using umbrella, this is rather simple:

```elixir
# paraguas/apps/phoenix_app/mix.exs
  defp deps do
    [
      ...,
      {:basic_auth, "~> 2.2"},
      {:greeter, in_umbrella: true}
    ]
  end
```

After tying it all together, I created a [Phoenix channel](https://hexdocs.pm/phoenix/channels.html) for JavaScript to interact with our Greeter app through Phoenix:

![Phoenix App](/images/posts/umbrella.gif "Phoenix App")

[\[GITHUB REPO\]: Implement Phoenix channel to send Greeter hello to frontend](https://github.com/CultivateHQ/paraguas/commit/696957f96a64554894c1b91d8d21528c8315f2fc)

Now that we have a couple of "functional" Elixir apps in an umbrella project, it's time to work on the release.

## Distillation for release

Distillery is a release management tool for Elixir projects. It produces a release from our mix projects which can be deployed independently of dependencies and Erlang/Elixir installations. We add distillery as a dependency in our Umbrella app:

```elixir
defp deps do
  [{:distillery, "~> 1.5", runtime: false}]
end
```

Then run `mix deps.get` and `mix release.init`. This adds a `rel` directory with a `config.exs` file. You should check this file and run `mix help release.init` to learn more about it. Find out more in [distillery's Getting Started guide](https://hexdocs.pm/distillery/getting-started.html).

We're now ready to build a release with `mix release`:

```bash
$ mix release
==> Assembling release..
==> Building release paraguas:0.1.0 using environment dev
==> You have set dev_mode to true, skipping archival phase
==> Release successfully built!
    You can run it in one of the following ways:
      Interactive: _build/dev/rel/paraguas/bin/paraguas console
      Foreground: _build/dev/rel/paraguas/bin/paraguas foreground
      Daemon: _build/dev/rel/paraguas/bin/paraguas start
```

The release was built and we can run it with any of the last three commands printed out to the console. So let's try that:

```bash
./_build/dev/rel/paraguas/bin/paraguas foreground
```

Nothing seems to be happening. If we check the processes in our system, we can see Erlang is running, but we can't see the application in our browser. We still need to [configure Phoenix with distillery](https://hexdocs.pm/distillery/use-with-phoenix.html).

First we need to edit `paraguas/apps/phoenix_app/config/prod.exs` and add the `server`, `root` and `version` options:

```elixir
config :phoenix_app, PhoenixApp.Endpoint,
  http: [:inet6, port: {:system, "PORT"}],
  url: [host: "localhost", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:phoenix_app, :vsn)
```

Following the distillery guide for Phoenix, we need to build the release, wich requires the static assets to be built. In `paraguas/apps/phoenix_app/assets` run:

```bash
$ npm install
# build assets in production mode.
$ ./node_modules/brunch/bin/brunch b -p
```

In `paraguas/apps/phoenix_app/` run:

```bash
# compressess and tags assets for proper caching.
$ MIX_ENV=prod mix phoenix.digest
```

In the project root:

```bash
# Actually generate a release for a production environment
$ MIX_ENV=prod mix release
```

Now you can run the production build:

```bash
./_build/prod/rel/paraguas/bin/paraguas foreground
```

However, this will trigger the following error:

```
server can't start because :port in config is nil, please use a valid port number
```

So far we have two Elixir apps in an umbrella project and a distillery release which builds. We can run the app in development with `mix phx.server` and run the tests with `mix test` from the root app. But there's still some more set up we need to work on to get it working for production.

## Environment variables

If you look at the `config/prod.exs` file in our Phoenix App, there's a PORT variable which we're not setting anywhere. We also need to set the authentication variables values for `basic_auth`.

We could use `prod.secret.exs`, but it's not practical for the approach we want to use. Since we're going to deploy our app in a Docker container, we want to be able to change the variables without having to rebuild. And we can even start several Docker container with different variables so these have to be passed at runtime.

We can pass environment variables into our release with the following command:

```bash
$ PORT=4000 \
  COOKIE=cookie \
  BASIC_AUTH_USERNAME=user \
  BASIC_AUTH_PASSWORD=password \
  BASIC_AUTH_REALM="Our realm" \
  _build/prod/rel/paraguas/bin/paraguas foreground
```

The `:system` tuple is supported, which mean `System.get_env` will be called to get the values at runtime. So we now have a production release with environment variables at runtime.

[\[GITHUB REPO\]: Add distillery and configs](https://github.com/CultivateHQ/paraguas/commit/41901e1bcadc8b3dbfe63d7412377515cd638dd5)

## Containerize with Docker

<section class="callout">
  Check <a href="/posts/docker/">our blog post about Docker</a> if you need help getting started.
</section>

The final step for this tutorial is to dockerize the project so it's available for deploy in <em>Amazon Web Services</em>, <em>OpenShift</em>, <em>Kubernetes</em> or any other container deployment platform.

We built 2 docker images. One that builds the release, and a second one to run it. For the build container we're using [alpine-elixir-phoenix](https://hub.docker.com/r/bitwalker/alpine-elixir-phoenix/), an image that provides Elixir, Node, Hex, everything we need to run a Phoenix application. For the second container we're using [alpine](https://hub.docker.com/_/alpine/), a minimal image based on Alpine Linux.

The first part of our Dockerfile looks like this then:

```dockerfile
# Alias this container as builder:
FROM bitwalker/alpine-elixir-phoenix as builder

WORKDIR /paraguas

ENV MIX_ENV=prod

# Umbrella
# Copy mix files so we use distillery:
COPY mix.exs mix.lock ./
COPY config config

# Our Greeter App
COPY apps/greeter/config apps/greeter/config/
COPY apps/greeter/mix.exs apps/greeter/

# Phoenix App
COPY apps/phoenix_app/mix.exs apps/phoenix_app/
COPY apps/phoenix_app/config apps/phoenix_app/config/

RUN mix do deps.get, deps.compile

COPY apps apps

# Build assets in production mode:
WORKDIR /paraguas/apps/phoenix_app/assets
RUN npm install && ./node_modules/brunch/bin/brunch build --production

WORKDIR /paraguas/apps/phoenix_app
RUN MIX_ENV=prod mix phx.digest

WORKDIR /paraguas
COPY rel rel
RUN mix release --env=prod --verbose
```

It's pretty self-explanatory and we're basically doing the same stuff we went through before in our machines. Now for the release part:

```dockerfile
FROM alpine:3.6

RUN apk upgrade --no-cache && \
    apk add --no-cache bash openssl
    # we need bash and openssl for Phoenix

EXPOSE 4000

ENV PORT=4000 \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    SHELL=/bin/bash

WORKDIR /paraguas

COPY --from=builder /paraguas/_build/prod/rel/paraguas/releases/0.1.0/paraguas.tar.gz .

RUN tar zxf paraguas.tar.gz && rm paraguas.tar.gz

RUN chown -R root ./releases

USER root

CMD ["/paraguas/bin/paraguas", "foreground"]
```

We can now build these containers with:

```bash
$ docker build -t paraguas:0.1.0 .
```

If everything went well, we now have a working image:

```bash
$ docker images
REPOSITORY                        TAG                 IMAGE ID            CREATED              SIZE
paraguas                          0.1.0               32146e78bc11        About a minute ago   71.2MB
```

Finally, our code is available to run in a container. Remember we need to pass in the environment variables to our distillery release. So either source them from an .env file, or pass them as parameters to the `docker run` command:

```bash
$ docker run --rm -ti \
             -p 4000:4000 \
             -e COOKIE=a_cookie \
             -e BASIC_AUTH_USERNAME=username \
             -e BASIC_AUTH_PASSWORD=password \
             -e BASIC_AUTH_REALM=realm \
             paraguas:0.1.0
```

[\[GITHUB REPO\]: Add Dockerfile](https://github.com/CultivateHQ/paraguas/commit/34a8f577c07932d6b66bdc6a4b068f2444292c0d)

## Introducing vm.args

Using the configuration we saw here, only strings are supported. What if we need a variable to be a number? Phoenix can take a String as the port number, but if our app depended on a simple Plug running in Cowboy, or if we needed to set a database connection pool size? There's a solution for that: [Distillery's vm.args](https://hexdocs.pm/distillery/getting-started.html#vm-configuration).

Distillery will automatically generate a vm.args file in the release by default. This configures the VM with a name and cookie. We can provide our own vm.args configuration and take advantage of metadata provided by Distillery. We just need to create a vm.args file and tell Distillery where it is in our release configuration.

To test integer types through environment variables, I added a numeric variable as an example, and it is displayed in the Phoenix app frontend. I really didn't want to complicate things further with a database connection pool 😬.

 We need to use `${VAR}` instead of `{:system, VAR}` and set `REPLACE_OS_VARS=true` so we can use these environment variables for configuration. I'm calling this variable `sombrilla`, and the first step is adding it to the `prod.exs`` file:

```elixir
# paraguas/apps/phoenix_app/config/prod.exs
config :phoenix_app, sombrilla: "${SOMBRILLA}"
```

We'll add `vm.args` in the `rel` directory and set it in `rel/config.exs`:

```elixir
release :paraguas do
  set version: "0.1.0"
  set applications: [
    :runtime_tools,
    greeter: :permanent,
    phoenix_app: :permanent
  ]
  set vm_args: "rel/vm.args"
end
```

And our `vm.args` file:

```
-phoenix_app sombrilla ${SOMBRILLA}
```

I then wrote some code in the controller and template to display the value and show that it is in fact an integer. To see this, we just need to build the release one more time, and add the environment variable when we run it:

```bash
$ REPLACE_OS_VARS=true \
  PORT=4000 \
  COOKIE=cookie \
  BASIC_AUTH_USERNAME=user \
  BASIC_AUTH_PASSWORD=password \
  BASIC_AUTH_REALM="Our realm" \
  SOMBRILLA=42 \
  _build/prod/rel/paraguas/bin/paraguas foreground
```

And this is what the app looks like in our browser:

![Paraguas](/images/posts/paraguas.jpg "Paraguas")

You can check the final source code in [cultivateHQ/paraguas](https://github.com/CultivateHQ/paraguas/). And If you have any feedback or questions about this post, tweet at us [@cultivatehq](http://twitter.com/cultivatehq).

Acknowledgements: [Configuring Elixir Libraries](http://michal.muskala.eu/2017/07/30/configuring-elixir-libraries.html) by Michał Muskała.
