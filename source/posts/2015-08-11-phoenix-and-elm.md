---
title:  Building an app using Phoenix and Elm
author: Alan Gardner
---

## Intro

I've recently been playing around, independently, with [Phoenix](http://phoenixframework.org) and [Elm](http://elm-lang.org). I'm really enjoying using both and so I thought I would see how easy it would be to combine the two, with Phoenix serving a data API and Elm consuming it.

As it turns out, this is fairly straightforward. Especially if you keep the two projects apart. It becomes a little more fun when you try to combine the two into a single app, but even this is not too bad once you've figured out how to get it running with Brunch.

### A necessary aside ...

I should point out before we start that I'm not suggesting that you should put an Elm app inside your Phoenix app. Perhaps this is the right thing to do, perhaps it's not. There are three main ways that I could envisage working with the two:

1. Run them completely separate. This is how we start out on this tutorial and is the simplest way to go.
2. Have separate projects but compile the Elm project into a JavaScript file inside the Phoenix project. This means that you don't have to have the Elm app embedded within the Phoenix app, there are less moving parts to go wrong and you are less likely to hit complications in your build pipeline. However it does make it a bit more difficult for others to work with your project.
3. Embed the Elm app inside the Phoenix app. This allows you to work with a single project and include Elm in your Brunch workflow. This means that any changes to your Elm files can trigger an `elm make` to generate the associated JavaScript, which in turn will trigger the JavaScript build process and LiveReload the app in your browser (if you have it open). IMLE it's a pretty nice workflow. It does however have the added complexity of having to run one language/framework inside another.

## The project

We're going to build a really simple Contact Manager (CRM) tool called ConMan. ConMan will fetch the list of contacts from our Phoenix data API and display them using Elm.

## Building our data server in Phoenix

Let's start by creating our simple data API in Phoenix.

1. Open a terminal and navigate to where you'd like top create your Phoenix project.
2. If you don't yet have Phoenix installed, you can follow the instructions on the [Phoenix installation page](http://www.phoenixframework.org/docs/installation).
3. Create a new Phoenix app to serve as our data API

    ```bash
    mix Phoenix.new conman
    # when prompted, type y to install dependencies

    # cd into the project folder
    cd conman

    # compile and generate the project database
    mix ecto.create

    # startup a server
    iex -S mix phoenix.server
    ```

4. If all has gone according to plan, you should now be able to see the default landing page if you point your browser to [http://localhost:4000](http://localhost:4000).
5. Let's use the built-in Phoenix JSON resource generator to get our Contact API in place.

    ```bash
    mix phoenix.gen.json Contact contacts \
      first_name:string last_name:string email:string
    ```

6. Add the required resource into our `web/router.ex` file

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

7. And run migrations to get the database up to date and run the tests to ensure that we haven't broken anything (note that we get tests for free by using the generator)

    ```bash
    mix ecto.migrate

    mix test
    ```

8. Now, if we restart our server (`Cmd+c` twice and then `iex -S mix phoenix.server` again) and visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts), we should see an empty dataset.
9. We can manually add some data in the Elixir repl, iex. Cunningly this is already running as a result of us running `iex -S mix phoenix.server`. Go to the terminal window where the Phoenix server is running and hit return to get a prompt.
10. You can create a contact by doing the following:

    ```elixir
    iex(3)> bobby = %Conman.Contact{first_name: "Bobby", last_name: "Tables", email: "bobby@example.com"}
    %Conman.Contact{__meta__: %Ecto.Schema.Metadata{source: {nil, "contacts"},
      state: :built}, email: "bobby@example.com", first_name: "Bobby", id: nil,
     inserted_at: nil, last_name: "Tables", updated_at: nil}

    iex(4)> molly = %Conman.Contact{first_name: "Molly", last_name: "Tables", email: "molly@example.com"}
    %Conman.Contact{__meta__: %Ecto.Schema.Metadata{source: {nil, "contacts"},
      state: :built}, email: "molly@example.com", first_name: "Molly", id: nil,
     inserted_at: nil, last_name: "Tables", updated_at: nil}

    iex(5)> Conman.Repo.insert(bobby)
    [debug] BEGIN [] OK query=0.3ms
    [debug] INSERT INTO "contacts" ("email", "first_name", "inserted_at", "last_name", "updated_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id" ["bobby@example.com", "Bobby", {{2015, 8, 10}, {14, 14, 56, 0}}, "Tables", {{2015, 8, 10}, {14, 14, 56, 0}}] OK query=1.1ms
    [debug] COMMIT [] OK query=0.6ms
    {:ok,
     %Conman.Contact{__meta__: %Ecto.Schema.Metadata{source: {nil, "contacts"},
       state: :loaded}, email: "bobby@example.com", first_name: "Bobby", id: 1,
      inserted_at: #Ecto.DateTime<2015-08-10T14:14:56Z>, last_name: "Tables",
      updated_at: #Ecto.DateTime<2015-08-10T14:14:56Z>}}

    iex(6)> Conman.Repo.insert(molly)
    [debug] BEGIN [] OK query=0.4ms
    [debug] INSERT INTO "contacts" ("email", "first_name", "inserted_at", "last_name", "updated_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id" ["molly@example.com", "Molly", {{2015, 8, 10}, {14, 15, 3, 0}}, "Tables", {{2015, 8, 10}, {14, 15, 3, 0}}] OK query=0.6ms
    [debug] COMMIT [] OK query=0.6ms
    {:ok,
     %Conman.Contact{__meta__: %Ecto.Schema.Metadata{source: {nil, "contacts"},
       state: :loaded}, email: "molly@example.com", first_name: "Molly", id: 2,
      inserted_at: #Ecto.DateTime<2015-08-10T14:15:03Z>, last_name: "Tables",
      updated_at: #Ecto.DateTime<2015-08-10T14:15:03Z>}}
    ```

11. If we visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts) again we can see that we now have two contacts. However we're not getting any information about them. Let's fix that by opening `web/views/contact_view.ex` and changing the `def render("contact.json" ...` function to the following:

    ```elixir
    def render("contact.json", %{contact: contact}) do
      %{
        id: contact.id,
        first_name: contact.first_name,
        last_name: contact.last_name,
        email: contact.email
      }
    end
    ```

12. Refreshing our browser, we should now see the data that we expect.


## Building our front end client in Elm

OK, so we now have a very simple data API up and running. Let's set up a basic Elm app to fetch that data and display it on a web page.


## Combining the two into a single app


## A quick detour into Brunch


## The finished product


## Conclusions
