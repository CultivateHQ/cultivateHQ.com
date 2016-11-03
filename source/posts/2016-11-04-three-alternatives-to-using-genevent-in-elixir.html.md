---
author: Paul Wilson
title: Three alternatives to using GenEvent in Elixir
description: "For various reasons, may people are not fond of GenEvent. Here are some examples of using some good alternatives for broadcasting and subscribing to types of event: gproc, Phoenix PubSub, and the new process registry to be included in Elixir 1.4."
---

Wojket Gawronski's post [here](http://www.afronski.pl/2015/11/02/what-is-wrong-with-gen-event.html), neatly summarises the issues with [GenEvent](http://elixir-lang.org/docs/stable/elixir/GenEvent.html). Fortunately there are alternatives including [gproc](https://github.com/uwiger/gproc), [phoenix_pubsub](https://github.com/phoenixframework/phoenix_pubsub), and [Elixir 1.4's upcoming Process registry](https://github.com/elixir-lang/registry).

The code used in these examples is available from [this repository](https://github.com/CultivateHQ/pubsub_spike).

## gproc

While gproc's main purpose is as a [process registry](http://blog.rusty.io/2009/09/16/g-proc-erlang-global-process-registry/), it can be used as pub/sub framework using a lovely trick.

```
defmodule PubsubSpike.Gproc do
  use GenServer

  def start_link(topic, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, topic, otp_opts)
  end

  def broadcast(topic, message) do
    GenServer.cast({:via, :gproc, gproc_key(topic)},
                   {:broadcast, message})
  end

  def messages_received(pid) do
    GenServer.call(pid, :messages_received)
  end

  def init(topic) do
    :gproc.reg(gproc_key(topic))
    {:ok, []}
  end

  def handle_cast({:broadcast, message}, messages_received) do
    {:noreply, [message | messages_received]}
  end

  def handle_call(:messages_received, _from, messages_received) do
    {:reply, Enum.reverse(messages_received), messages_received}
  end

  defp gproc_key(topic) do
    {:p, :l, topic}
  end
end
```

The code above (also [here](https://github.com/CultivateHQ/pubsub_spike/blob/master/lib/pubsub_spike/gproc.ex)), illustrates using gproc in this way. In `init` the `GenServer` process registers itself with a particular key: `{:p, :l, topic}`:

* The `:p` atom in the tuple, indicates to gproc that multiple processes may be registered using the same key. (If it was `:n`, then the uniqueness of the key would be enforced.)
* The `:l` just says that the process is registered locally, just on this node. `:g` would register globally, across all connected nodes, but that involves [a certain amount of faff](http://erlang.org/pipermail/erlang-questions/2011-December/063133.html).
* And `topic` is our topic.

`broadcast` broadcasts a message to all processes listening on a topic; this is implemented with `GenServer.cast`. Rather than identifying the cast's target process with a `pid` or a [name in the Erlang process registry](http://erlang.org/doc/reference_manual/processes.html#id87478), it is identified using a *via tuple*, `{:via, :gproc, gproc_key(topic)}` which delegates finding the pid(s) to gproc's `whereis_name` function. Thus, all processes registered with that key (effectively listening to that topic) will receive the `cast`.

This test shows it all working  (code also [here](https://github.com/CultivateHQ/pubsub_spike/blob/master/test/pubsub_spike/gproc_test.exs)):

```
  alias PubsubSpike.Gproc
  test "broadcast messages" do
    {:ok, pid1} = Gproc.start_link("sue")
    {:ok, pid2} = Gproc.start_link("sue")
    {:ok, pid3} = Gproc.start_link(:miranda)

    Gproc.broadcast("sue", "Hi Sue!")
    Gproc.broadcast(:miranda, "Hi Miranda!")

    assert Gproc.messages_received(pid1) == ["Hi Sue!"]
    assert Gproc.messages_received(pid2) == ["Hi Sue!"]
    assert Gproc.messages_received(pid3) == ["Hi Miranda!"]
  end
```

## Elixir Registry

[Registry](https://github.com/elixir-lang/registry) will be in the Elixir 1.4 release, as a more Elixir-like and built-in version of gproc. We can also use it as a pub/sub framework. A registry is a supervisor and must be started, such as in the [application supervisor](https://github.com/CultivateHQ/pubsub_spike/blob/master/lib/pubsub_spike.ex#L11):

```
def start(_type, _args) do
  import Supervisor.Spec, warn: false

  children = [
    supervisor(Registry, [:duplicate,  :pubsub_elixir_registry]),
    # ...
  ]
  opts = [strategy: :one_for_one, name: PubsubSpike.Supervisor]
  Supervisor.start_link(children, opts)
end
```

Note that we have called this registry `:pubsub_elixir_registry` and have marked it as allowing duplicate keys.

[Here](https://github.com/CultivateHQ/pubsub_spike/blob/master/lib/pubsub_spike/elixir_registry.ex) is a pub/sub implementation similar to that for gproc:

```
defmodule PubsubSpike.ElixirRegistry do
  use GenServer

  def start_link(topic, otp_opts \\ []) do
    GenServer.start_link(__MODULE__, topic, otp_opts)
  end

  def broadcast(topic, message) do
    Registry.dispatch(:pubsub_elixir_registry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:broadcast, message})
    end)
  end

  def messages_received(pid) do
    GenServer.call(pid, :messages_received)
  end

  def init(topic) do
    Registry.register(:pubsub_elixir_registry, topic, [])
    {:ok, []}
  end

  def handle_info({:broadcast, message}, messages_received) do
    {:noreply, [message | messages_received]}
  end

  def handle_call(:messages_received, _from, messages_received) do
    {:reply, Enum.reverse(messages_received), messages_received}
  end
end
```

Registries that allow duplicates are [not allowed](https://github.com/elixir-lang/registry/blob/0af57d196b9c031245ec4c5d6ba629398c1c0c5e/lib/registry.ex#L182) to service via tuples, so we cannot perform the same trick as we did with gproc. Instead, `broadcast` uses [Registry.dispatch](https://github.com/elixir-lang/registry/blob/0af57d196b9c031245ec4c5d6ba629398c1c0c5e/lib/registry.ex#L182) to send a message to each process listening on a topic. We can use [handle_info](http://elixir-lang.org/docs/stable/elixir/GenServer.html#c:handle_info/2) to receive messages to the subscribed topic.

The illustrative test, [here](https://github.com/CultivateHQ/pubsub_spike/blob/master/test/pubsub_spike/elixir_registry_test.exs), is so similar to the gproc version that I will not include it below.

## Phoenix PubSub

Unlike gproc and Registry, Phoenix PubSub's primary purpose is as a pub/sub framework. There is a clue in the name.

Phoenix PubSub supports multiple implementations, such as a [Phoenix PubSub Redis](https://github.com/phoenixframework/phoenix_pubsub_redis), but we will just use the built-in one based on Erlang's [PG2](http://erlang.org/doc/man/pg2.html). We will to start the `Phoenix.PubSub.PG2` supervisor, in the [application supervisor](https://github.com/CultivateHQ/pubsub_spike/blob/master/lib/pubsub_spike.ex):

```
def start(_type, _args) do
  import Supervisor.Spec, warn: false

  children = [
    supervisor(Phoenix.PubSub.PG2, [:pubsub_spike, []]),
    # ..
  ]

  opts = [strategy: :one_for_one, name: PubsubSpike.Supervisor]
  Supervisor.start_link(children, opts)
end
```

Note that we have named the Phoenix PubSub supervisor, `:pubsub_spike`.

Implementing with the same interface as the other examples, we get [this](https://github.com/CultivateHQ/pubsub_spike/blob/master/lib/pubsub_spike/phoenix_pubsub.ex), following:

```
defmodule PubsubSpike.PhoenixPubsub do
  use GenServer

  alias Phoenix.PubSub

  def start_link(topic, otp_opts \\ []) when is_binary(topic) do
    GenServer.start_link(__MODULE__, topic, otp_opts)
  end

  def broadcast(topic, message) do
    PubSub.broadcast(:pubsub_spike, topic, {:pubsub_spike, message})
  end

  def messages_received(pid) do
    GenServer.call(pid, :messages_received)
  end

  def init(topic) do
    PubSub.subscribe(:pubsub_spike, topic)
    {:ok, []}
  end

  def handle_call(:messages_received, _from, messages_received) do
    {:reply, Enum.reverse(messages_received), messages_received}
  end

  def handle_info({:pubsub_spike, msg}, messages_received) do
    {:noreply, [msg | messages_received]}
  end
end
```

The interface to Phoenix Pub Sub is more straightforward than the other two, as it was designed specifically for pub/sub. We explicitly subscribed to a topic (in `init`), broadcast to a topic (in `broadcast`), and receive a message (in `handle_info`). It is worth noting that PHoenix PubSub [only supports binary](https://github.com/phoenixframework/phoenix_pubsub/blob/99181389e81d97d3e29ee09b22b3fc552cf2fe86/lib/phoenix/pubsub.ex#L151) (String) topics.

There is test code [here](https://github.com/CultivateHQ/pubsub_spike/blob/master/test/pubsub_spike/phoenix_pubsub_test.exs), but is also so similar to the gproc test that it is not worth embedding in the blog.

## Bonus: distributed events with Phoenix PubSub

A bonus of using Phoenix PubSub is that it can easily publish events across connected nodes. This post's [companion code](https://github.com/CultivateHQ/pubsub_spike) is set up for you to easily play with this.

A `PubsubSpike.PhoenixPubsub` worker (as above), named `:phoenix_pubsub` and listening on the topic "topic:phoenix_pubsub", is created by its [application supervisor](https://github.com/CultivateHQ/pubsub_spike/blob/master/lib/pubsub_spike.ex):

```
def start(_type, _args) do
  import Supervisor.Spec, warn: false

  children = [
    supervisor(Phoenix.PubSub.PG2, [:pubsub_spike, []]),
    worker(PubsubSpike.PhoenixPubsub, ["topic:phoenix_pubsub",
                                      [name: :phoenix_pubsub]]),
    # ..
  ]

  opts = [strategy: :one_for_one, name: PubsubSpike.Supervisor]
  Supervisor.start_link(children, opts)
end
```

To try this out, (assuming you're [all set up for Elixir](http://elixir-lang.org/install.html)) open a terminal and type the following.

```
git clone git@github.com:CultivateHQ/pubsub_spike.git
cd pubsub_spike
mix deps.get

iex --sname mel@localhost -S mix
```

In another terminal, but the same directory:

```
iex --sname sue@localhost -S mix
Node.connect(:"mel@localhost") # should return true

PubsubSpike.PhoenixPubsub.broadcast("topic:phoenix_pubsub", "Hello all!")

PubsubSpike.PhoenixPubsub.messages_received(:phoenix_pubsub)
```

`messages_received` should return `["Hello all!"]`. Now in the other terminal (Node "mel@localhost"), try

```
PubsubSpike.PhoenixPubsub.messages_received(:phoenix_pubsub)
```

That too should return `["Hello all!"]`. The message has been broadcast from the other node.

## Summary

And there we have it: 3 great alternatives to GenEvent. Registry will be bundled with Elixir 1.4, so you will soon be able to use it without adding any more dedpendencies. You may already be using gproc as a registry for dynamic processes; if so, it may be convenient to also use it's pub/sub capabilities. Phoenix PubSub has the benefits of actually being designed for pub/sub, has a clearer pub/sub interface, and is easy to distribute.
