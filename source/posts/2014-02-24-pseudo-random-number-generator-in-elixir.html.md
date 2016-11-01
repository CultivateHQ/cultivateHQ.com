---
title:  "Pseudo Random Number Generation in Elixir"
author: Alan Gardner
description: I recently started learning Elixir and decided for my first "real" project to implement a basic genetic algorithm. I like to do this to kick the tyres on a new language because it's a non-trivial problem that gives you a good idea of what it's like to work with that language.
tags: alan
---

<br>
<div class="callout">
  <strong>UPDATE</strong>: since this post was written Erlang 18 was released. Erlang 18 now contains a <code>rand</code> module that provides a seeded PRNG. Calling <code>:rand.uniform</code> instead of <code>:random.uniform</code> negates the need for seeding unless you specifically change the algorithm being used. See <a href="http://erlang.org/doc/man/rand.html">the docs</a> for more info.

  Thanks to José Valim (Plataformatec) for the heads up.
</div>

I recently started learning Elixir and decided for my first "real" project to implement a basic genetic algorithm. I like to do this to kick the tyres on a new language because it's a non-trivial problem that gives you a good idea of what it's like to work with that language.

Genetic algorithms rely pretty heavily on the ability to generate random numbers. They need them to create the initial population of possible solutions, to generate new child solutions and to potentially mutate solutions. The whole purpose of a genetic algorithm is to reduce the risk of getting stuck in local maxima by introducing a random element to the process.

This led to an interesting spelunk into the world of random number generation in Erlang. Elixir runs on the Erlang Beam VM and uses Erlang modules to provide random number generation. Along the way I came across a few interesting areas and gotchas, so I thought that I would share.

## TL;DR
Random number generation can be a fascinating subject (for a given value of fascinating). If you are interested in a quick tour of the science bits, carry on reading. Otherwise you can skip to the Elixir section if you'd rather just find out how to be random in Elixir.

## What is (pseudo) random number generation?
Random number generation crops up from time to time in software development. We need to pick a random element from an array, shuffle the contents of a set or randomly select a colour from a given palette. Most of the time we don't have to think too much about it; any number within a given range will do. We don't care about which algorithm is being used under the hood or how long its period is, and we only tend to care how deterministic or secure it is if we are generating a password or the like.

The Oxford English Dictionary defines random as:

"made, done, or happening without method or conscious decision"

This presents an obvious problem for a programming language. In order for a computer to generate a random number it needs to have a recipe (or algorithm) for doing so. It is possible to make this algorithm so complex that determining the next number that will be generated is, for all intents and purposes, impossible to determine. However, it can never generate a truly random number. As such Random Number Generators (RNGs) are split into two types.

### True Random Number Generators
In order to be truly random, a True Random Number Generator (TRNG) must have the following attributes:

* Each possible value is equally probable
* Each number in sequence must be
  * statistically independent (i.e. no values in the sequence affect the generation of any of the other values)
  * Non-deterministic (i.e. the next result can not be predicted)
  * Non-periodic (i.e. no pattern can develop over time)

The best way to achieve this is to use data from natural phenomena to generate truly random numbers. As an example of this random.org uses atmospheric noise to generate its truly random numbers. Great, you say. I can harness nature to pluck random elements from my array. I am a golden god!

Not so fast. Literally.

Generating truly random numbers is comparatively slow and inefficient when compared to pseudo random number generation, and most problem domains don't call for that level of randomness. Just how crucial is it that the randomly selected background colour for your website has not been used in the last 2<sub>^19938</sub> times?

### Pseudo Random Number Generators
This brings us to the Pseudo Random Number Generator (PRNG). The job of the PRNG is to provide a "good enough" random number for the task at hand. In general this means two things:

* The algorithm is deterministic. There is a pattern being followed to generate the number and therefore it is deterministic by definition. It may be nigh on impossible to figure out in polynomial time, but it is still deterministic.
* The algorithm is periodic. That is to say that, given enough time, the sequence of numbers being generated will repeat. A good PRNG will have as long a period as possible.

The end result is that they are generating numbers that are random enough, and they are doing it much faster than the TRNG equivalent.

## Pseudo Random Number Generation in Elixir
Now that we know what and why a PRNG is, let's look at Elixir. As I mentioned above, Elixir does not implement its own PRNG, instead preferring (as it does on many occasions) to use the Erlang implementation. Erlang is unusual when compared to the other languages I've used random number generation in before, in that it does not seed the PRNG for you. You need to set it yourself. For example, when you ask for a random number in Ruby using Kernel.rand, it automatically seeds the PRNG using the current time and process ID.

```bash
~ $ irb
2.1.0 :001 > Kernel.rand
=> 0.6469110224958001
2.1.0 :002 > Kernel.rand
=> 0.19273856179089177
2.1.0 :003 > Kernel.rand
=> 0.7674679417203816
2.1.0 :004 > exit
```

```bash
~ $ irb
2.1.0 :001 > Kernel.rand
=> 0.5675955527713897
2.1.0 :002 > Kernel.rand
=> 0.24136062798733005
2.1.0 :003 > Kernel.rand
=> 0.6559555351137014
```


However Erlang does not do this. When you start a Beam VM and ask for a sequence of random numbers you will get the same result as you do if you restart the Beam VM and ask again.

```bash
~ $ iex
iex(1)> :random.uniform
0.4435846174457203
iex(2)> :random.uniform
0.7230402056221108
iex(3)> :random.uniform
0.94581636451987
```

```bash
~ $ iex
iex(1)> :random.uniform
0.4435846174457203
iex(2)> :random.uniform
0.7230402056221108
iex(3)> :random.uniform
0.94581636451987
```

In the above example we open an Interactive Elixir shell (iex) and then ask the underlying Erlang :random module for a random number between 0 and 1 three times. We then close the iex session, open a new iex session and then ask for three random numbers again. As you can see, we get the same sequence of numbers both times. Not so random!

## Default seeding
The reason that the results are so predictable is that the same default seed is being used each time. We can see this by opening an iex session and explicitly using the default seed before we ask for random numbers.

Note: the reason that we call `:random.seed` twice is because the returned value is the old seed value and not the new seed value. By calling it twice we can see that the value hasn't changed because the default is being used. This does not mean that you have to call `:random.seed` twice. :)

```bash
~ $ iex
iex(1)> :random.seed
{3172, 9814, 20125}
iex(2)> :random.seed
{3172, 9814, 20125}
iex(3)> :random.uniform
0.4435846174457203
iex(4)> :random.uniform
0.7230402056221108
iex(5)> :random.uniform
0.94581636451987
```

As you can see, we get the same pattern occurring because we have not yet changed the seed. This is handy from a testing point of view. We can use `:random.seed()` in our tests to ensure that we always get the expected results when testing randomised methods. However it is not so handy when we want to have a PRNG that appears to be non-deterministic.

## Seeding using timestamp
The first solution we often turn to when looking for a unique number to seed with, is the current timestamp. This is generally unique enough in a single-threaded application. We can do this in Elixir as follows:

```bash
~ $ iex
iex(1)> :random.seed(:os.timestamp)
{1393, 17601, 3899}
iex(2)> :random.uniform
0.19198799713471804
iex(3)> :random.uniform
0.34462933791281847
iex(4)> :random.uniform
0.264660857546803
iex(5)> :random.seed(:os.timestamp)
{15982, 2799, 9869}
iex(6)> :random.uniform
0.8477991246924288
iex(7)> :random.uniform
0.10262363928084794
iex(8)> :random.uniform
0.5813421379555017
```

This time we get a different sequence of random numbers because we are seeding using a different value each time. You will also notice that we did not restart iex between seeding this time. Reseeding is enough to reset the PRNG and so we don't have to restart iex. We can prove this out if we seed multiple times using the default seed.

```bash
iex(1)> :random.seed
{3172, 9814, 20125}
iex(2)> :random.uniform
0.4435846174457203
iex(3)> :random.uniform
0.7230402056221108
iex(4)> :random.uniform
0.94581636451987
iex(5)> :random.seed
{3172, 9814, 20125}
iex(6)> :random.uniform
0.4435846174457203
iex(7)> :random.uniform
0.7230402056221108
iex(8)> :random.uniform
0.94581636451987
```

Job done ... or is it?

## Seeding using now
The problem with using the timestamp is that it is only unique if each call to `:os.timestamp` occurs within a separate tick of the system clock. This becomes much less likely when you start using a concurrent approach across multiple CPU cores. Considering that this is where Elixir excels, it seems a shame not to take advantage. Luckily for us the designers of Erlang took this into account and gave us `:erlang.now`.

`:erlang.now` is monotonic. That is to say that it will always return us a unique timestamp. If the VM is asked for a timestamp that has already been handed out using `:erlang.now`, it will increment the timestamp by one until it gets a timestamp that it has not used before. This is great for getting a unique number to seed the PRNG with. However it has side effects.

GOTCHA: when you use `:erlang.now` and it increments the returned timestamp so that you get a unique value, it actually steps forward the Beam VM clock. This means that the Beam VM will be out of step with the system clock until it catches up. This can produce some strange side effects within code running on that same VM. For example, if you ask for 10 unique timestamps in a single tick, the Beam VM will be 9 ticks ahead of the system clock. Providing you don't use `:erlang.now` again for the next 9 ticks, the system clock will catch up with the Beam clock and then start incrementing it again on the 10th tick. `:erlang.now` has a granularity of 1 millionth of a second, so you would have to use it a lot to introduce significant clock skew. However, it is worth bearing this in mind.

```bash
iex(1)> :random.seed(:erlang.now)
{1393, 19097, 12915}
iex(2)> :random.uniform
0.9603944516428959
iex(3)> :random.uniform
0.8973416107371897
iex(4)> :random.uniform
0.08752834436488932
iex(5)> :random.seed(:erlang.now)
{3526, 29988, 29764}
iex(6)> :random.uniform
0.27391576833972353
iex(7)> :random.uniform
0.4343262239364174
iex(8)> :random.uniform
0.3729658432572305
```

So we get our uniqueness guaranteed, but there is a possibility that you might cause clock skew if you need to call `:erlang.now` a lot. There is another option though.

## Seeding using crypto
Instead of using the timestamp, we can use the Erlang crypto module to generate some unique values and then present them to `:random.seed` in a tuple like that produced by `:os.timestamp` or `:erlang.now`. The output from `:os.timestamp` or `:erlang.now` is a tuple containing three integers (representing the number of megaseconds, seconds and milliseconds since the epoch of the current system, in case you're interested). We can mimic this by using `:crypto.rand_bytes` and then pattern matching the result into a bitstring (as seen in the excellent Learn You Some Erlang):

```bash
iex(1)> << a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
<<217, 47, 118, 16, 166, 73, 158, 208, 16, 104, 182, 4>>
iex(2)> :random.seed(a,b,c)
:undefined
iex(3)> :random.uniform
0.6567207345244586
iex(4)> :random.uniform
0.9948936772936514
iex(5)> :random.uniform
0.6540583453470816
iex(6)> << a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
<<79, 26, 228, 207, 205, 196, 167, 106, 8, 98, 197, 124>>
iex(7)> :random.seed(a,b,c)
{9376, 13798, 26958}
iex(8)> :random.uniform
0.302614218684619
iex(9)> :random.uniform
0.7664941429798051
iex(10)> :random.uniform
0.7752787034211441
```

This gives us the unique values that we are looking for each time and does not affect the Beam clock in any way. Win win!

A note on `:random.uniform`

When reviewing this blog post, Kenji Rikitake pointed out to me that the period of the PRNG used by `:random.uniform` is actually quite short. For the purposes of supplying random numbers to a genetic algorithm an implementation of the Mersenne Twister PRNG would be better.

Many modern languages such as Ruby, Python and R use a Mersenne Twister based PRNG by default. To use one in Erlang, Kenji has a couple of implementations that can be used. I haven't tried either of these yet, but it will be the first thing I do after this.

[https://github.com/jj1bdx/sfmt-erlang](https://github.com/jj1bdx/sfmt-erlang)

[https://github.com/jj1bdx/tinymt-erlang](https://github.com/jj1bdx/sfmt-erlang)

## Conclusion
If you are looking to generate pseudo random numbers in Elixir, remember to set a seed before you do so. If you care about how deterministic or periodic the sequence of random numbers is, consider seeding using the Erlang crypto module.

Whatever you are working on, be careful when using `:erlang.now`. If you are thinking about using `:erlang.now` stop and think about whether `:os.timestamp` might suit your needs better.

## Acknowledgements

My thanks to Paul Wilson (Cultivate), Gordon Guthrie (Basho), Francesco Cesarini (Erlang Solutions) and Kenji Rikitake for kindly agreeing to review this post for me. Further thanks to Kenji for the presentation that seeded (pun entirely intended) my understanding of random number generation in Erlang. :)
