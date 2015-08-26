---
title:  Putting an Elm in your Phoenix
author: Alan Gardner
---

## Intro

I've recently been playing around, independently, with [Phoenix](http://phoenixframework.org) and [Elm](http://elm-lang.org). I'm really enjoying using both and so I thought I would see how easy it would be to combine the two, with Phoenix serving a data API and Elm consuming it.

We'll take a look at three approaches:

1. Independent - the Phoenix and Elm apps will exist as separate codebases and will be run independently.
2. Inserted - the Phoenix and Elm apps will exist as separate codebases, but the JavaScript resulting from compiling the Elm app will be manually inserted into the Phoenix app and run from there.
3. Embedded - the Phoenix and Elm apps will exist a single codebase. The Elm app will be embedded into the Brunch workflow so that any changes to the Elm code automatically compiles it and the resulting JavaScript is then immediately available to the app as a whole.



## The project

We're going to build a really simple Contact Manager tool called ConMan. So simple in fact that ConMan will just fetch a list of contacts from our Phoenix data API and display them using Elm.


## Building the application

We'll go through setting up a data server in Phoenix and then a client to consume the data in Elm. If you are familiar with either or both of these technologies then you can safely skip to the Combining Phoenix and Elm section to find out how they can work together. The code for each part is available on GitHub if you'd prefer just to read that.

[Phoenix data api](https://github.com/CultivateHQ/conman_data)
[Elm client](https://github.com/CultivateHQ/conman_ui)


### Building our data server in Phoenix

> Using Phoenix version `0.17.0`, Elixir version `1.0.5` and Erlang/OTP version `17`.

Let's start by creating our simple data API in Phoenix.

1. Open a terminal and navigate to where you'd like top create your Phoenix project.
2. If you don't yet have Phoenix installed, you can follow the instructions on the [Phoenix installation page](http://www.phoenixframework.org/docs/installation).
3. Let's create a new Phoenix application to serve as our data API

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

4. If all has gone according to plan, you should now be able to see the default landing page if you point your browser to [http://localhost:4000](http://localhost:4000).

<TODO: insert image https://www.dropbox.com/s/hhb8nicdz0nlj15/Screenshot%202015-08-26%2011.34.37.png?dl=0>

5. Let's use the built-in Phoenix JSON resource generator to get our Contact API in place.

  ```bash
  mix phoenix.gen.json Contact contacts name:string email:string phone:string
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

7. And update the Contact View and Controller Test to use all of the Contact fields

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

8. Now let's run migrations to get the database up-to-date and run the tests again to ensure that we haven't broken anything (note that we get tests for free by using the generator)

  ```bash
  mix ecto.migrate

  # check that everything is working (you should have 14 passing tests)
  mix test
  ```

9. If we restart our server (`Cmd+c` twice and then `iex -S mix phoenix.server` again) and visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts), we should see an empty dataset.

<TODO: insert image https://www.dropbox.com/s/bufjbw3f0cliop9/Screenshot%202015-08-26%2011.46.23.png?dl=0>

10. Let's seed some contact data into the database. Open `priv/repo/seeds.exs` and add the following:

  ```elixir
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Bobby Tables", email: "bobby@example.com",    phone: "01 234 5678"})
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Molly Apples", email: "molly@example.com",    phone: "01 789 2340"})
  ConmanData.Repo.insert!(%ConmanData.Contact{name: "Elroy Bacon",  email: "el_bacon@example.com", phone: "01 398 7654"})
  ```

11. Now add those to the database by running `mix run priv/repo/seeds.exs`.
12. If we visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts) again we can see that we now have three contacts.


## Building our front end client in Elm

> Using Elm version `0.15.1`.

OK, so we now have a very simple data API up and running. Let's create a client in Elm that uses the data API we just built.

Please note that we'll be glossing over quite a lot in order to keep this section short. If you'd like more information on Elm then I fully recommend starting with the [Pragmatic Studios Elm course](https://pragmaticstudio.com/courses/elm) and then moving on to the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial).

We're going to follow the patterns set out in the Elm Architecture Tutorial to build our Elm application. If you don't already have Elm installed, you can do so from the [Elm installation page](http://elm-lang.org/install).

1. First we'll need to create our base Elm application. Navigate to the directory where you want to create this and do the following:

  ```bash
  md conman_ui

  cd conman_ui

  elm package install --yes
  ```

2. That will create a folder for our application, install the Elm core packages (into the elm-stuff folder) and create an application manifest file (elm-package.json). Now, from the root of our new project, create a Main.elm file and open it in our editor of choice. Add the following to that file.

  ```elm
  module Main where

  import Html


  main =
    Html.text "ConMan is alive!"
  ```

3. The code above creates a module called Main, imports the Html package and then uses it to output the text "ConMan is alive!". The `main` function is required as the starting point for an Elm application.
4. In order to use this though, we need to compile it to JavaScript. We can do this from the terminal as follows.

  ```bash
  elm make --output conman.js Main.elm
  ```

5. This will compile the Elm code into a JavaScript file called conman.js in the directory in which the command was run.
6. Now we can create an HTML file that will allow us to use the JavaScript file in the browser. Create a file on the root of the project called `index.html` and add the following code to it.

  ```html
  <!DOCTYPE html>
  <html>
    <head>
      <title>ConMan - Contact Manager</title>

      <script src="conman.js"></script>
    </head>
    <body>
      <script>
        var app = Elm.fullscreen(Elm.Main);
      </script>
    </body>
  </html>
  ```

7. Note that we have a `<script>` tag in the `<head>` that gets our `conman.js` file, and another in the `<body>` that runs a function `Elm.fullscreen` passing in our starting point (`Elm.Main`) and storing that in a variable called `app`. `Elm.fullscreen` will run our Elm application fullscreen rather than embedded within a particular DOM element within the page.
8. Now open the index.html file in a browser and you should see it output "ConMan is alive!"

<TODO: insert image https://www.dropbox.com/s/g24zuspsfzphjqb/Screenshot%202015-08-26%2012.50.54.png?dl=0 >

9. Let's make a slight tweak to our Main.elm file so that we can see the workflow for doing so. Open Main.elm in your editor and change the `main` function to the following.

  ```elm
  main =
    view


  -- VIEW

  view =
    Html.text "ConMan is alive!"
  ```

10. Rather than display the text directly in the `main` function, we can create a `view` function to handle that and then call it from the `main` function. `main` and `view` are the idiomatic names for these functions, although you can name the `view` function anything you like.
11. Now we can recompile our conman.js file and see that nothing has changed!



## Combining Phoenix and Elm


### Running the two apps independently


### Using the Elm generated JavaScript within the Phoenix app


### Embedding the Elm app inside the Phoenix app



## Conclusions
