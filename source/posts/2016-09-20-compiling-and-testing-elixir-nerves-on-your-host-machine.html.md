---
author: Paul Wilson
title: Compiling and testing Elixir Nerves on your host machine
description: Elixir Nerves is awesome, but it make it awkward to test your code on your development computer - especially if it is not Linux. Here I explain how to overcome that hurdle.
tags: elixir
---

[Nerves](https://hexdocs.pm/nerves) brings the power of the Erlang VM and Elixir to embedded devices. Something that makes Nerves such a great project is the effort that the Nerves Core Team have put into the tooling and documentation. It is pleasure to use.

However, by its very nature, Nerves deals with low level things. This makes testing, including futzing around in `iEX` as well as `ExUnit` tests, awkward on the host machine - particularly if it is not a Linux machine. (Host machine, means the machine that you are coding on, as opposed to the embedded device which is the target.)

This post describes my approach to overcoming these problems.

## Audience

I am assuming some familiarity with Nerves. I would suggest at least having a read through the [introductory documentation](https://hexdocs.pm/nerves/getting-started.html) and [installation instructions](https://hexdocs.pm/nerves/installation.html), and getting [Blinky](https://github.com/nerves-project/nerves-examples/tree/master/blinky) running on a [Raspberry PI](https://www.raspberrypi.org). Even if you do not have a Pi yourself, you probably know several people with a few of them in the back of a drawer.

## Step 1 - use an [Umbrella Project](http://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-apps.html)

A consequence of the general awesomeness of using Umbrella projects to separate the concerns of any Elixir project, is that it easy to divide the lower level code from that which is not concerned with the hardware. Simply by doing this you can test any of your applications that neither interacts with hardware or _depends on an application or library that does_.

Eg, from your Umbrella route:

```
cd apps/my_isolated_app
mix test
```

## Step 2 - use the power of `Mix.env`

While Umbrella apps are a step in the right direction, I find them an unsatisfactory solution to this issue for several reasons:-

1. I don't think that there's a whole lot of code in a lot of embedded projects that does not ultimately depend on something that interacts with hardware. You can probably get round this with some cunning indirection, such as using `GenEvent` instead of direct calls, but that glue code adds up and can make the code hard to figure out.
1. You won't be able to test any of the stuff that interacts with hardware. It would be nice to test some of that.
1. You can't run `mix test` from the Umbrella root to test all the code. Yuck!

The key is to be able to compile different things, in different ways, for different environments, and there is already a mechanism for this: `Mix.env`. If I am developing a web application I will be trying things out on my development machine in `dev`, testing in `test`, and building a server release in `prod`.

Let's take a look at how we achieved this with the [CultivatarMobile](https://github.com/CultivateHQ/cultivatarmobile), a small project to drive a small buggy controlled by a web interface or Slack. The Umbrella contains 5 applications:-

* [`fw`](https://github.com/CultivateHQ/cultivatarmobile/tree/nerves-post/apps/fw) - The Nerves image is built and burnt from here, making it the "master app". It also contains some networking related code.
* [`cb_locomotion`](https://github.com/CultivateHQ/cultivatarmobile/tree/nerves-post/apps/cb_locomotion) - This interacts directly with the stepper motors that drive the buggy around.
* [`dummy_nerves`](https://github.com/CultivateHQ/cultivatarmobile/tree/nerves-post/apps/dummy_nerves) - substitutes for modules in hardware specific libraries that we can't, or are not willing to, compile into `dev` and `test` code.
* [`cb_slack`](https://github.com/CultivateHQ/cultivatarmobile/tree/nerves-post/apps/cb_slack) - allows the buggy to be controlled via Slack. This does not interact with hardware, but it depends on `cb_locomotion` which does.
* [`cb_web`](https://github.com/CultivateHQ/cultivatarmobile/tree/nerves-post/apps/cb_web) - runs a web server for buggy control. Like `cb_slack`, depends on `cb_locomotion`

### Master App changes

You will have generated the "master app" by doing something like:-

```
cd apps
mix nerves.new fw --target rpi
```

The next step is a little surgery on the generated `mix.exs`.

I believe a fix will be released soon, but at the time of writing the generated file does not follow the umbrella convention of building, and caching and locking dependencies at the root. Let's correct that.


#### Use Umbrella conventions

In the [`mix.exs` `project`](https://github.com/CultivateHQ/cultivatarmobile/blob/nerves-post/apps/fw/mix.exs#L6-L19) replace

```
deps_path: "deps/#{@target}",
build_path: "_build/#{@target}",
```

with

```
  deps_path: "../../deps/#{@target}",
  build_path: "../../_build/#{@target}",
  config_path: "../../config/config.exs",
  lockfile: "../../mix.lock",
```

#### Only use Nerves specific aliases and system target in `prod`

The generated `mix.exs` is configured to build with the target (eg `rpi`) compilers and system. In `dev` and `test` mode you don't need to do that.

In the [`mix.exs` `project`](https://github.com/CultivateHQ/cultivatarmobile/blob/nerves-post/apps/fw/mix.exs#L6-L19) replace

```
  aliases: aliases,
  deps: deps ++ system(@target)]
```

with

```
  aliases: aliases(Mix.env),
  deps: deps ++ system(@target, Mix.env)]
```

Now we can use pattern matching to alter the content of aliases and system, depending on `Mix.env`. Change [`alias`](https://github.com/CultivateHQ/cultivatarmobile/blob/nerves-post/apps/fw/mix.exs#L56-L60)

```
 def aliases do
   ["deps.precompile": ["nerves.precompile", "deps.precompile"],
    "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end
```

to

```
  def aliases(:prod) do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end
  def aliases(_), do: []
```

And change [`system`](https://github.com/CultivateHQ/cultivatarmobile/blob/nerves-post/apps/fw/mix.exs#L43-L47)

```
  def system(target) do
    [
      {:"nerves_system_#{target}", ">= 0.0.0"},
    ]
  end
```

to

```
  def system(target, :prod) do
    [
      {:"nerves_system_#{target}", ">= 0.0.0"},
    ]
  end
  def system(_, _), do: []
```

#### Only include hardware dependencies in prod

Use the existing mechanism for including dependencies only in specific environments. In the `fw` master app, we use [Nerves Iterim Wifi](https://github.com/nerves-project/nerves_interim_wifi), so in ['deps'](https://github.com/nerves-project/nerves_interim_wifi) it is marked as `prod` only:-

```
  def deps do
    [
      {:nerves, "~> 0.3.0"},
      {:nerves_interim_wifi, "~> 0.0.2", only: :prod},
      {:cb_slack, in_umbrella: true},
      {:cb_web, in_umbrella: true},
      {:cb_locomotion, in_umbrella: true},
      {:dummy_nerves, in_umbrella: true, only: [:dev, :test]},
      {:porcelain, ">= 0.0.0" },
    ]
  end
```

As certain dependencies will only appear in the application list when compiling for `prod`, then that must also take into account [`Mix.env`](https://github.com/CultivateHQ/cultivatarmobile/blob/nerves-post/apps/fw/mix.exs#L24-L27).

```
  def application do
    [mod: {Fw, []},
     applications: applications(Mix.env)]
  end
```

...

```
  defp applications(:prod), do: [:nerves_interim_wifi | general_apps]
  defp applications(_), do: general_apps

  defp general_apps, do: [:logger, :porcelain, :cb_slack, :runtime_tools, :cb_web, :cb_locomotion]
```


Note that as we are not compiling in certain modules, then we will need to replace them with something else. For Interim Wifi, this is done in `dummy_nerves` [here](https://github.com/CultivateHQ/cultivatarmobile/blob/nerves-post/apps/dummy_nerves/lib/nerves/interim_wifi.ex):-

```
defmodule Nerves.InterimWiFi do
  use GenServer

  @moduledoc """
  Fakes interim wifi; does nothing.
  """

  def setup interface, opts \\ [] do
    GenServer.start_link(__MODULE__, {interface, opts}, [name: :interim_wifi])
  end
end
```

### Step 5. Modify any other of the umbrella apps that interact with hardware

The [`cb_locomotion`](https://github.com/CultivateHQ/cultivatarmobile/tree/nerves-post/apps/cb_locomotion) app interacts with the stepper motors using [Elixir Ale](https://github.com/fhunleth/elixir_ale). As only the "master app" needs to be a Nerves project, we only need to worry about the dependencies and application list in the [`mix.exs`](https://github.com/CultivateHQ/cultivatarmobile/blob/nerves-post/apps/cb_locomotion/mix.exs).

```
  def application do
    [mod: {CbLocomotion, []},
     applications: applications(Mix.env)]
  end

  defp deps do
    [
      {:nerves, "~> 0.3.0"},
      {:elixir_ale, "~> 0.5.6", only: :prod},
      {:dummy_nerves, in_umbrella: true, only: [:dev, :test]}
    ]
  end

  defp applications(:prod), do: [:elixir_ale | general_apps]
  defp applications(_), do: general_apps

  defp general_apps, do: [:logger]
```

Here we take advantage of swapping out Elixir Ale's [GPIO](https://github.com/fhunleth/elixir_ale/blob/master/lib/gpio.ex), to enrich the unit tests by recording state changes on the individual pins. See the [Stepper motor test case](https://github.com/CultivateHQ/cultivatarmobile/blob/nerves-post/apps/cb_locomotion/test/cb_locomotion/stepper_motor_test.exs#L100-L115).

### Step 6. Test locally and deploy to production.

If you clone the [Cultivator mobile](https://github.com/CultivateHQ/cultivatarmobile/) app and follow the configuration instructions, then you should be able to successfully run `mix test` or `iex -S mix` from the umbrella root on your host machine.  To build the firmware, however, you must set the `MIX_ENV` environment variable to `prod`

```
cd apps/fw
MIX_ENV=prod firmware
MIX_ENV=prod firmware.burn
```

If I am doing a lot of building firmware, then I `export MIX_ENV=prod` in a terminal shell, which minimises the typing. When I do that, I set the shell background colour to red, as a reminder that this is the deployment shell.


## Fin

Now with a little extra configuration, you should find it easier to test your Nerves code without having to deploy to your target every time. If you have any feedback, you can provide it through our [contact form](/contact/), as an issue or PR on the [CultivatarMobile](https://github.com/CultivateHQ/cultivatarmobile) repository.
