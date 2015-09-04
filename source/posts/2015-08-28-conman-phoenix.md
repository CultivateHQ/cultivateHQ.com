---
title:  Building a data API in Phoenix
author: Alan Gardner
---

> I've recently been playing around with [Phoenix](http://phoenixframework.org) and [Elm](http://elm-lang.org). I'm really enjoying using both and so I thought I would see how easy it is to combine the two, with Phoenix serving a data API and Elm consuming it.
> This is Part 1 in a series of 4 posts. In it we will walk through setting up a basic Phoenix data API. [Part 2](#part_2) walks through setting up a basic Elm client that will consume the data we serve from this API and [Part 3](#part_3) talks about combining the Phoenix and Elm projects together. Finally, in [Part 4](part_4), we will add support for Phoenix channels.

**We are using Phoenix version `0.17.0`, Elixir version `1.0.5` and Erlang/OTP version `17`.**


## What we're going to build

We're going to build a really simple Contact Manager tool called ConMan. So simple in fact that ConMan will just fetch a single contact from our Phoenix data API and display it using Elm. Whilst this might seem too simple, it's just enough to see all the moving parts of Phoenix and Elm that we need to for this exercise.


## Up and running

If you don't yet have Phoenix installed, you can follow the instructions on the [Phoenix installation page](http://www.phoenixframework.org/docs/installation).


## Introduction

The aim of this post is to get you up and running quickly with a very simple data API. We're going to use the Phoenix mix generators to do this. The aim is to have something that we can use to demonstrate serving data to our Elm application that we'll build in [Part 2](#part_2) and therefor is not intended to be an exhaustive guide.


## Creating a new project

> I'd lose the above three sections and maybe add a short sentence with a link to the installation instructions. "Show don't tell" is a good principal (principle? I've totally lost that word now). My experience is devs generally like to get stuck in. The preamble could also be condensed down — think of what the reader is interested in hearing, they'll probably decide whether to read on in the first paragraph.

> Also this first point is probably obvious to your target reader. You don't need to hand-hold them — exploration, failure, surprise is part of learning.

1. Open a terminal and navigate to where you'd like to create your Phoenix project.
2. Let's create a new Phoenix application to serve as the base for our data API.

  ```bash
  # when prompted, type y to install dependencies
  mix Phoenix.new conman_data

  # cd into the project folder
  cd conman_data

  # compile and generate the project database
  mix ecto.create

  # check that everything is working (you should have 4 passing tests)
  mix test

  # startup a server
  iex -S mix Phoenix.server
  ```

If all has gone according to plan, you should now be able to see the default landing page at [http://localhost:4000](http://localhost:4000).

<TODO: insert image https://www.dropbox.com/s/pa57gox6eeirckr/Screenshot%202015-09-01%2008.29.45.png?dl=0 >


## Generating a JSON API

> Here I think you're actually not hand-holding enough. You're using a lot of technical words, which is fine — but it takes a little while to parse. Consider hand-waving a bit and relating it to things they might already know about. I've amended the first point as an example.

1. Let's create a Contact API. We can use the built-in Phoenix generators for this.

  ```bash
  mix phoenix.gen.json Contact contacts name:string email:string phone:string
  ```

You'll see it's created quite a few files. We'll go through them later.

Note that I'm using `phoenix.gen.json` here. If I used `phoenix.gen.html` [or whatever] I'd get a HTML scaffold [or whatever].

2. Add the required resource into our `web/router.ex` file.

  ```elixir
  # web/router.ex
  defmodule Conman.Router do
    use Conman.Web, :router

    ...

    scope "/api", Conman do
      pipe_through :api

      resources "/contacts", ContactController
    end
  end
  ```

> You might want to touch on what a Phoenix view is here — for those who only know the Rails meaning of View.

3. And ensure that the Contact View and Controller Test use all of the Contact fields.

    ```elixir
    # web/views/contact_view.ex:12
    def render("contact.json", %{contact: contact}) do
      %{id: contact.id,
        name: contact.name,
        email: contact.email,
        phone: contact.phone}
    end

    # test/controllers/contact_controller.exs:18
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

4. Now let's run migrations to get the database up-to-date and run the tests again to ensure that we haven't broken anything (note that we get tests for free by using the generator).

> ^^^ this is good

  ```bash
  mix ecto.migrate

  # check that everything is working (you should have 14 passing tests)
  mix test
  ```

If we restart our server (`Cmd+c` twice and then `iex -S mix Phoenix.server` again) and visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts), we should see something like this:

<TODO: insert image https://www.dropbox.com/s/xu6k3y9bvspiu9z/Screenshot%202015-09-01%2008.41.34.png?dl=0 >


## Seeding the database

> Interstitial point here — it's more of a stylistic thing, but it's sometimes nice to have a narrative in tutorials. You could go as far as 'The Big Bad Wolf wanted some contacts so he could eat them, here they are!' — or as simple as 'We'll need some contacts for our API — let's seed the database with some.'

Let's seed some contact data into the database.

1. Open `priv/repo/seeds.exs` and add the following.

  ```elixir
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Bobby Tables", email: "bobby@example.com",    phone: "01 234 5678"})
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Molly Apples", email: "molly@example.com",    phone: "01 789 2340"})
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Elroy Bacon",  email: "el_bacon@example.com", phone: "01 398 7654"})
  ```

2. Now run `mix run priv/repo/seeds.exs` to add those to the database.

Now when you visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts), you should see something like this:

<TODO: insert image https://www.dropbox.com/s/cmibunjrbo5a762/Screenshot%202015-09-01%2008.42.23.png?dl=0 >


## Handling CORS errors

> As you know, javascript is only usually allowed to make API calls to its own server. If you make a request to another server, you'll get a [Cross-Origin Resource Sharing (CORS)](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) error. But we can tell our Phoenix server to make an exception just for us.

If we try to access this API from applications that are not on the same domain as this data API, then we will get a [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) error. Let's make a quick change to our application to handle that.

We can use Michael Schaefermeyer's [cors_plug](https://github.com/mschae/cors_plug) to do this.

1. Add the following to the Phoenix `mix.exs` file.

  ```elixir
  def deps do
    # ...
    {:cors_plug, "~> 0.1.3"},
    #...
  end
  ```

2. Run `mix deps.get` to pull the code and then add the following to the `lib/conman_data/endpoint.ex` file just above the call to `plug ConmanData.Router`.

  ```elixir
  plug CORSPlug

  plug ConmanData.Router
  ```

> For security in production, you will want to narrow this down so only specific servers can make CORS requests. [The CORSPlug README has more information on this.](#)

We'll not worry about adding any specific configuration at this point, so any domain should now be able to access our API with no CORS issues. If we restart our server we should now be able to access the data API from domains other than the one the API is running on.

> So far, you've not actually explained why we need to do this ^^^. As far as I, the reader, am concerned, I'm just running one server, so why should I care?


## Conclusion

> Suggest losing the first paragraph, replace with something like "Now we have a simple data API. In the next episode, we'll get Elm talking to it." I like the second paragraph, as you're highlighting things that are cool about Phoenix. Talk about possible extensions of the techniques — you mention the pipelines, talk about problems that might solve or cool things you might do (in the context of this exercise). Devs love that stuff because it starts them thinking 'oh cool, i wonder how you can do that?' and then if you're lucky they'll give it a go. Nothing worse than getting to the end of a tutorial and thinking 'whelp, all my curiosity is sastisfied, i'll go spend time with my family now I GUESS'

Creating a basic data API in Phoenix is super simple thanks to the code generator. Not only does it give us exactly what we need right now, but it also shows us how we can idiomatically create our own JSON APIs in future when we want to stop using the generator. This is one of the things that I really like about Phoenix.

Another thing that I really like about Phoenix is that it has baked in support for running both a web application (on the "/" scope) and a data API (on the "/api" scope), and for running different pipelines of plugs on each scope. This will come in quite handy for joining the Phoenix and Elm applications together.

That's all we need to do for Part 1. [Part 2](#part_2) will walk us through the creation of a basic Elm client that will consume the data from this API.

> Good stuff! Bonus points: get a CTA here. How are they going to find out about the next blog post (if they're staggered, that is). Follow us on twitter? Subscribe to our low volume newsletter? 
