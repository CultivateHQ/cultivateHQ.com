---
title: Phoenix with Elm - part 1
author: Alan Gardner
description: Installing prerequisites and generating a base Phoenix project
tags: alan
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>


## Prerequisites

You'll need to have the items below installed in order to follow along:

* [Erlang, Elixir and Phoenix](http://www.phoenixframework.org/docs/installation)
* [Elm](http://elm-lang.org/install)
* [Postgres](http://www.postgresql.org/download/) (or see [the Ecto guide](http://www.phoenixframework.org/docs/ecto-models) if you want to try using something else)

### Versions used in this tutorial

If you can, please use the versions noted below as it will make following the tutorial easier. If you can't then check the gotchas on the repo as others may have logged issues for the version that you are using.

* Erlang 19.0.2
* Elixir 1.3.2
* Phoenix 1.2.0
* Elm 0.17.0


### Upgrading Phoenix

You may need to upgrade your version of Phoenix. Be sure to check the [Phoenix blog](http://www.phoenixframework.org/blog) for any upgrade notes between versions.

### A note for readers using Windows

This tutorial assumes that you are working on a *nix machine, but I've tried to call out where possible any Windows-specific gotchas. However you will have to parse some things such as file paths as you go (i.e. `web/elm/SeatSaver.elm` becomes `web\elm\SeatSaver.elm` on Windows).

### Getting up to speed

If you're brand new to Phoenix then I would suggest going through the [Guides on the Phoenix site](http://www.phoenixframework.org/docs/overview). That said, we will likely cover everything that you need to know as you need to know it here. There is also a [book](https://pragprog.com/book/phoenix/programming-phoenix) on The Pragmatic Bookshelf.

If you're brand new to Elm then I would suggest the [Pragmatic Studio Elm course](https://pragmaticstudio.com/elm) as a great way to get into the language. Also, the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial) is a great way to see how idiomatic Elm applications are constructed.


### Gotchas

There are a number of gotchas on the [tutorial project's wiki](https://github.com/CultivateHQ/seat_saver/wiki). We'll add to them over time. If you come across any it would be great if you could raise an [issue](https://github.com/CultivateHQ/seat_saver/issues) so that we can update. Thanks in advance!


## Creating a Phoenix project

1. The first thing that we want to do is to create a Phoenix project. Open a terminal and navigate to where you want to create the project. Then do the following:

    ```shell
    mix phoenix.new seat_saver
    cd seat_saver
    ```

2. Now we'll set up the database.

    <div class="callout">
      Make sure that you have Postgres running and that you either have a <em>postgres</em> user set up in Postgres or that you have valid user credentials in both the <em>config/dev.exs</em> and <em>config/test.exs</em> files.
      <br>
      <br>
      If you are running on Windows you will need to make sure that you have the path to the `psql` binary in your Environment Path. See <a href="http://www.computerhope.com/issues/ch000549.htm#0">this guide</a> for instructions on how to change the PATH and add the following to the end of the PATH string (changing as appropriate for your installation):
      <br>
      <br>
      <code>
        C:\Program Files\PostgreSQL\9.5\bin;
      </code>
    </div>

    Create the database for the project by running:

    ```shell
    mix ecto.create
    ```

3. We can run the tests to check that everything went according to plan by running:

    ```shell
    mix test
    ```

    There should be 4 passing tests.

4. If we fire up the Phoenix server

    ```shell
    iex -S mix phoenix.server
    ```

    and visit <http://localhost:4000> in the browser, we should see something like this:

    ![Phoenix start page](/images/phoenix-elm/1.png)

## Summary

We now have a base Phoenix application that we can build on. In [Part 2](/posts/phoenix-elm-2) we'll see how to add an Elm application into the mix.
