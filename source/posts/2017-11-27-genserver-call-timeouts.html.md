---
author: Paul Wilson
title: GenServer call time-outs
description: What exactly happens when `GenServer.call/3` times out? Let's find out.
tags: elixir
date: 2017/11/27
---

There is a [GitHub repository](https://github.com/CultivateHQ/elixir_call_timeouts) that accompanies this post.


By law, every OTP tutorial must include an exercise in which you build your own version of `GenServer` before the astonishing revelation that OTP provides a better thought-out one. So, you will already know that `GenServer.call` is implemented something like

```elixir
def call(server, request, timeout \\ 5_000) do
  ref = Process.monitor(server)
  send(server, {:"$gen_call", {self(), ref}, request})
  receive do
    {^ref, reply} ->
      Process.demonitor(ref)
      reply
  after
    timeout ->
      Process.demonitor(ref)
      exit(:timeout)
  end
end
```

Of course there's a bit more to it than that, but [it's pretty damned close](https://github.com/erlang/otp/blob/695ce64b3168c3fcc2d5f2de5cb74701f767e71d/lib/stdlib/src/gen.erl#L155).

## Forcing a time-out

In the accompanying code we have a `GenServer`, [Timesout](https://github.com/CultivateHQ/elixir_call_timeouts/blob/master/lib/timesout.ex), which is designed to time-out if you call `yawn` with a value greater than 99 (milliseconds). Note that the default time-out is 5 seconds, but life is too short to wait that long.

```elixir
  @timeout 100
  def yawn(sleep) do
    GenServer.call(@name, {:yawn, sleep}, @timeout)
  end

  def handle_call({:yawn, sleep}, _from, call_count) do
    :timer.sleep(sleep)
    {:reply, {:previous_call_count, call_count}, call_count + 1}
  end
```

So ..

```elixir
$ iex -S mix
iex(1)> Timesout.yawn(110)
** (exit) exited in: GenServer.call(, {:yawn, 110}, 100)
    ** (EXIT) time out
    (elixir) lib/gen_server.ex:774: GenServer.call/3
```

## Time-out kills the client

When investigating this from `iex` it can be a bit confusing, as `iex` prevents errors and time-outs from killing the shell. (The Erlang REPL behaves differently - uncaught errors and time-outs kill the shell process.)

```elixir
iex(1)> self
#PID<0.181.0>
iex(2)> exit(:whatevs)
** (exit) :whatevs

iex(2)> self
#PID<0.181.0>
```

The following illustrates the time-out killing the client.

```elixir
iex(1)> self
#PID<0.181.0>
iex(2)> spawn_link(fn -> Timesout.yawn(110) end)
#PID<0.184.0>
** (EXIT from #PID<0.181.0>) evaluator process exited with reason: exited in: GenServer.call(, {:yawn, 110}, 100)
    ** (EXIT) time out

Interactive Elixir (1.5.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> self
#PID<0.186.0>

```

## Time-out does not kill the server, or prevent the call from completing

The `Timesout` server keeps a count of all the number of calls that it has processed.


```elixir
iex(1)> :sys.get_state(Timesout)
0
iex(2)> Timesout.yawn(110)
** (exit) exited in: GenServer.call(, {:yawn, 110}, 100)
    ** (EXIT) time out
    (elixir) lib/gen_server.ex:774: GenServer.call/3
iex(2)> :sys.get_state(Timesout)
1

```

Although the call timed-out, the operation still completed. This is important if your call has effects, is not idempotent, and you would consider retrying. It also means that a blocked call will continue to block the GenServer even after a time-out.

```elixir
iex(1)> Timesout.yawn(60_000)
** (exit) exited in: GenServer.call(, {:yawn, 60000}, 100)
    ** (EXIT) time out
    (elixir) lib/gen_server.ex:774: GenServer.call/3
iex(1)> Timesout.yawn(1)
** (exit) exited in: GenServer.call(, {:yawn, 1}, 100)
    ** (EXIT) time out
    (elixir) lib/gen_server.ex:774: GenServer.call/3
```

## Replying early

A GenServer call can reply before the end of the `handle_call/3` function. In our example [Timesout](https://github.com/CultivateHQ/elixir_call_timeouts/blob/master/lib/timesout.ex) we also have

```elixir
  def before_you_sleep(sleep) do
    GenServer.call(@name, {:before_you_sleep, sleep}, @timeout)
  end

  def handle_call({:before_you_sleep, sleep}, from, call_count) do
    GenServer.reply(from, {:previous_call_count, call_count})
    :timer.sleep(sleep)
    {:noreply, call_count + 1}
  end
```

Blocking after the reply will not provoke a time-out in that call.

```elixir
iex(1)> Timesout.before_you_sleep(10_000)
{:previous_call_count, 0}
```

## Catching the exit

The client can explicitly catch the exit, and stay alive.

```elixir
iex(1)> self
#PID<0.181.0>
iex(2)> spawn_link(fn ->
...(2)>   try do
...(2)>     Timesout.yawn(110)
...(2)>   catch
...(2)>     :exit, value ->
...(2)>       IO.inspect {:caught_an_exit, value}
...(2)>   end
...(2)> end)
#PID<0.191.0>
{:caught_an_exit, {:timeout, {GenServer, :call, [, {:yawn, 110}, 100]}}}

iex(3)> self
#PID<0.181.0>
```

However remember that the server will also not die: the reply message will be sent to the client and if unhandled will clutter the mailbox. This also occurs when `iex` prevents exits:

```elixir
iex(1)> Timesout.yawn(110)
** (exit) exited in: GenServer.call(, {:yawn, 110}, 100)
    ** (EXIT) time out
    (elixir) lib/gen_server.ex:774: GenServer.call/3
iex(1)> flush
{#Reference<0.2855926460.1725169668.87324>, {:previous_call_count, 0}}
:ok
```


## Recap

When a GenServer times-out:-

* The client process will exit.
* The server will not exit and, if nothing else goes wrong, will complete the operation.
* You can reply early from `GenServer.handle_call/3` callback; that call will not time-out if the server blocks after the reply.
* If you prevent the client dying by catching the `exit` then you should also be handling the response message, to prevent the client processes mailbox from filling up.

## Acknowledgement

Thanks to [Tetiana Dushenkivska](https://twitter.com/Tetiana12345678) for helping me out with the syntax for catching exits in Elixir.

## Updates

* **2018-02-27** fixed typo in a `iex -S mix`
