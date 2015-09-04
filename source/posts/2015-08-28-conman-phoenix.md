---
title:  Building a data API in Phoenix
author: Alan Gardner
---

> I've recently been playing around with [Phoenix](http://phoenixframework.org) and [Elm](http://elm-lang.org). I'm really enjoying using both and so I thought I would see how easy it is to combine the two, with Phoenix serving a data API and Elm consuming it.

## Road map

* In this post we will walk through setting up a basic Phoenix data API.
* In the [second post](#part_2) we will get an Elm app talking to the API.
* In the [third post](#part_3) we will look at ways we can combine the Phoenix and Elm projects together.
* In the [fourth post](#part_4) we will add support for Phoenix channels.


## TL;DR

If you'd rather just see the code, it's available on [GitHub](http://github.com/CultivateHQ/conman_data). You can look at the commit history to see the steps involved.

Jump [straight to part 2](#part_2) to carry on with the tutorial.


## Up and running

If you don't yet have Phoenix installed, you can follow the instructions on the [Phoenix installation page](http://www.phoenixframework.org/docs/installation).

**We are using Phoenix version `1.0.1`, Elixir version `1.0.5` and Erlang/OTP version `18.0.3`**


## Introduction

This post will get you up and running quickly with a very simple data API. We're going to use the [Phoenix mix tasks](http://www.phoenixframework.org/docs/mix-tasks) to do this. The aim is to have something that we can use to demonstrate serving data to our Elm application that we'll build in [Part 2](#part_2) and is therefore not intended to be an exhaustive guide.


## Creating a new project

1. Open a terminal and navigate to where you'd like to create your Phoenix project.
1. Let's create a new Phoenix application to serve as the base for our data API.

  ```bash
  # when prompted, type y to install dependencies
  mix phoenix.new conman_data

  # cd into the project folder
  cd conman_data

  # compile and generate the project database
  mix ecto.create

  # check that everything is working (you should have 4 passing tests)
  mix test

  # startup a server
  iex -S mix phoenix.server
  ```

**Please note:** Phoenix will expect you to have Postgres installed and running, and role called postgres to exist. If you run into issues, check out the [Ecto docs](http://www.phoenixframework.org/docs/ecto-models).

If all has gone according to plan, you should now be able to see the default landing page at [http://localhost:4000](http://localhost:4000).

<TODO: insert image https://www.dropbox.com/s/pa57gox6eeirckr/Screenshot%202015-09-01%2008.29.45.png?dl=0 >


## Generating a JSON API

1. Let's create a Contact endpoint. We can use the built-in Phoenix generators for this. Note that I'm using `phoenix.gen.json` here. If I used `phoenix.gen.html`, for example, I'd get a HTML scaffold instead.

  ```bash
  mix phoenix.gen.json Contact contacts name:string email:string phone:string
  ```

2. You'll see that it has created quite a number of files for us. Feel free to have a read through them to see what you get. However, we only need to concern ourselves with a few of them to get our API endpoint up and running.
3. Add the required resource into our `web/router.ex` file.

  ```elixir
  # web/router.ex
  defmodule ConmanData.Router do
    use ConmanData.Web, :router

    ...

    scope "/api", ConmanData do
      pipe_through :api

      resources "/contacts", ContactController
    end
  end
  ```

4. Now let's run migrations to get the database up-to-date.

  ```bash
  mix ecto.migrate
  ```

5. We should run the tests again to ensure that we haven't broken anything (note that we get tests for free by using the generator). Before we do so though we (currently) need to make a small tweak to the controller test that was generated. Change the `test/controllers/contact_controller.exs` file so that the "shows chosen resource" on line 18 uses string keys rather than atoms in the assertion.

  ```elixir
  test "shows chosen resource", %{conn: conn} do
    contact = Repo.insert! %Contact{}
    conn = get conn, contact_path(conn, :show, contact)
    assert json_response(conn, 200)["data"] == %{
      "id" => contact.id,
      "name" => contact.name,
      "email" => contact.email,
      "phone" => contact.phone
    }
  end
  ```

6. Now we can run `mix test` to check that everything is working (you should have 14 passing tests).

If we restart our server (`Cmd+c` twice and then `iex -S mix phoenix.server` again) and visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts), we should see something like this:

<TODO: insert image https://www.dropbox.com/s/xu6k3y9bvspiu9z/Screenshot%202015-09-01%2008.41.34.png?dl=0 >


## Seeding the database

We'll need some contacts for our API, let's seed the database with some.

1. Open `priv/repo/seeds.exs` and add the following.

  ```elixir
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Bobby Tables", email: "bobby@example.com",    phone: "01 234 5678"})
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Molly Apples", email: "molly@example.com",    phone: "01 789 2340"})
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Elroy Bacon",  email: "el_bacon@example.com", phone: "01 398 7654"})
  ```

2. Now run `mix run priv/repo/seeds.exs` to add these to the database.

Now when you visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts), you should see something like this:

<TODO: insert image https://www.dropbox.com/s/cmibunjrbo5a762/Screenshot%202015-09-01%2008.42.23.png?dl=0 >


## Conclusion

Creating a basic data API in Phoenix is super simple thanks to the built in [mix tasks](http://www.phoenixframework.org/docs/mix-tasks). Not only does the `phoenix.gen.json` generator give us exactly what we need right now, but it also shows us how we can idiomatically create our own JSON APIs in future when we want to stop using the generator. This is one of the things that I really like about Phoenix.

Another thing that I really like about Phoenix is that it has baked in support for running both a web application (on the "/" scope) and a data API (on the "/api" scope). This will come in handy for running the Phoenix and Elm applications together in [Part 3](#part_3) of this series.

If you want to find out more about Phoenix then the [Phoenix guides](http://www.phoenixframework.org/docs/overview) are a great place to start.

Now that we have a data API, let's [get Elm talking to it](#part_2).


<TODO Cultivate PR stuff goes here :) >
