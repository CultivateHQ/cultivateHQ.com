---
title:  Building a data API in Phoenix
author: Alan Gardner
---

> This is Part 1 of a series on working with Phoenix and Elm. [Part 2](#part_2) talks about setting up a basic Elm client that will consume the data we serve from this API and [Part 3](#part_3) talks about combining Phoenix and Elm.

> We are using Phoenix version `0.17.0`, Elixir version `1.0.5` and Erlang/OTP version `17`.

## Building the data API

<TODO preamble>


### Installation

1. Open a terminal and navigate to where you'd like top create your Phoenix project.
2. If you don't yet have Phoenix installed, you can follow the instructions on the [Phoenix installation page](http://www.phoenixframework.org/docs/installation).


### Creating a new project

1. Let's create a new Phoenix application to serve as our data API

  ```bash
  mix Phoenix.new conman_data
  # when prompted, type y to install dependencies

  # cd into the project folder
  cd conman_data

  # compile and generate the project database
  mix ecto.create

  # check that everything is working (you should have 4 passing tests)
  mix test

  # startup a server
  iex -S mix phoenix.server
  ```

If all has gone according to plan, you should now be able to see the default landing page if you point your browser to [http://localhost:4000](http://localhost:4000).

<TODO: insert image https://www.dropbox.com/s/hhb8nicdz0nlj15/Screenshot%202015-08-26%2011.34.37.png?dl=0>


### Generating a JSON API

1. Let's use the built-in Phoenix JSON resource generator to get our Contact API in place.

  ```bash
  mix phoenix.gen.json Contact contacts name:string email:string phone:string
  ```

2. Add the required resource into our `web/router.ex` file

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

3. And update the Contact View and Controller Test to use all of the Contact fields

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

4. Now let's run migrations to get the database up-to-date and run the tests again to ensure that we haven't broken anything (note that we get tests for free by using the generator)

  ```bash
  mix ecto.migrate

  # check that everything is working (you should have 14 passing tests)
  mix test
  ```

If we restart our server (`Cmd+c` twice and then `iex -S mix phoenix.server` again) and visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts), we should see an empty dataset.

<TODO: insert image https://www.dropbox.com/s/bufjbw3f0cliop9/Screenshot%202015-08-26%2011.46.23.png?dl=0>


### Seeding the database

Let's seed some contact data into the database.

1. Open `priv/repo/seeds.exs` and add the following:

  ```elixir
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Bobby Tables", email: "bobby@example.com",    phone: "01 234 5678"})
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Molly Apples", email: "molly@example.com",    phone: "01 789 2340"})
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Elroy Bacon",  email: "el_bacon@example.com", phone: "01 398 7654"})
  ```

2. Now add those to the database by running `mix run priv/repo/seeds.exs`.

If we visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts) again we can see that we now have three contacts.

<TODO: insert image>


### Handling CORS errors

If we try to access this API from applications that are not on the same domain as this data API then we will get a [Cross Origin Resource Sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) error. Let's make a quick change to our application to handle that.

We can use Michael Schaefermeyer's [cors_plug](https://github.com/mschae/cors_plug) to do this.

1. Add the following to the Phoenix `mix.exs` file

  ```elixir
  def deps do
    # ...
    {:cors_plug, "~> 0.1.3"},
    #...
  end
  ```

2. Run `mix deps.get` to pull the code and then add the following to the `lib/conman_data/end_point.ex` file just above the call to `plug ConmanData.Router`

  ```elixir
  plug CORSPlug

  plug ConmanData.Router
  ```

We'll not worry about adding any specific configuration at this point, so any domain should now be able to access our API with no CORS issues.


## Conclusion

Creating a basic data API in Phoenix is super simple thanks to the code generator. Not only does it give us exactly what we need right now but it also shows us how we can idiomatically create our own JSON APIs without using the generator. This is one of the things that I really like about Phoenix.

Another thing that I really like about Phoenix is that it has baked in support for running both a web application (on the "/" scope) and a data API (on the "/api" scope) together, and for running different pipelines of plugs on each scope. This will come in quite handy for joining the Phoenix and Elm applications together.

This was Part 1 of a series on Phoenix and Elm. [Part 2](#part_2) up next is a run through of how to create a "simple" Elm client that will consume the data from this API. [Part 3](#part_3) will look at how the two can be combined in a single project and [Part 4](#part_4) will see how we can introduce Phoenix channels to the mix (pun partially intended) for some real-time goodness.
