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
4. In order to use this though, we need to add the elm-html package and compile Main.elm to JavaScript. We can do this from the terminal as follows.

  ```bash
  elm package install evancz/elm-html --yes
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

10. Rather than display the text directly in the `main` function, we can create a `view` function to handle that and then call it from the `main` function. `main` and `view` are the idiomatic names for these functions, although you can name the `view` function anything you like (also note that another Elm idiom is to have two line breaks between functions rather than one).
11. Now we can recompile our conman.js file and see that nothing has changed!

  ```bash
  elm make --output conman.js Main.elm
  ```

12. OK, so perhaps showing that nothing has changed is not the most ideal way to show something working. But you can verify that something is indeed happening by changing the text we are outputting to "ConMan is still alive!" and run `elm make --output conman.js Main.elm` again.
13. By this point you may be itching to automate this build process using your build pipeline of choice. Feel free to scratch that itch, but be aware that we will doing so in the **Combining Phoenix and Elm** section.
14. Back to the task at hand. Let's now swap out our "ConMan is (still) alive!" text for something more useful. Change your Main.elm file to the following.

  ```elm
  module Main where

  import Html exposing (..)
  import Html.Attributes exposing (..)


  main =
    view


  -- VIEW

  view =
    div [ class "contact" ]
    [ h2 [ class "contact__name" ] [ text "Bobby Tables" ]
    , div [ class "contact__email" ]
      [ span [ ] [ text "Email:" ]
      , a [ href ("mailto:bobby@example.com") ] [ text "bobby@example.com" ]
      ]
    , div [ class "contact__phone" ]
      [ span [ ] [ text "Phone:" ]
      , a [ href ("tel:01 234 5678") ] [ text "01 234 5678" ]
      ]
    ]
  ```

15. We change the `import Html` expression to include `exposing (..)`. This basically means that we don't have to prefix any functions that come from this package with `Html` and therefore cleans up our view code considerably. We add the `import Html.Atrributes exposing (..)` for the same reason except that this package gives us the attribute functions as opposed to the Html package which gives us the elements. Then we flesh out the view to show a sample contact.
16. Now compile the elm file to javascript again and refresh your browser. You should see the following.

<TODO insert image https://www.dropbox.com/s/p89g7enzu20pa49/Screenshot%202015-08-26%2018.21.13.png?dl=0 >

17. Elm uses a Model-Update-View architecture. The Model contains the current state of the application, the Update defines how that model can be stepped from one state to another (i.e. how the Model can be updated), and the View defines how the current state is displayed. We can ignore the Update layer for just now and we already have a basic View, so what about a Model?
18. Let's change our Main.elm application to use a Model rather than hard code the View with the contact data.

  ```elm
  module Main where

  import Html exposing (..)
  import Html.Attributes exposing (..)


  main =
    view (Model "Bobby Tables" "bobby@example.com" "01 234 5678")


  -- MODEL

  type alias Model =
    { name: String
    , email: String
    , phone: String
    }


  -- VIEW

  view contact =
    div [ class "contact" ]
    [ h2 [ class "contact__name" ] [ text contact.name ]
    , div [ class "contact__email" ]
      [ span [ ] [ text "Email:" ]
      , a [ href ("mailto:" ++ contact.email) ] [ text contact.email ]
      ]
    , div [ class "contact__phone" ]
      [ span [ ] [ text "Phone:" ]
      , a [ href ("tel:" ++ contact.phone) ] [ text contact.phone ]
      ]
    ]
  ```

19. We defined a type alias for Model, essentially saying to the Elm app, when we talk about the Model from now on we are referring to a record that contains three strings representing the name, email and phone for a contact. We then change our main function to use this Model to build a contact and pass it into the View (note that parentheses in Elm are used to indicate precedence, not to encapsulate parameters, i.e. `view (Model "Bobby Tables" "bobby@example.com" "01 234 5678")` says run `(Model "Bobby Tables" "bobby@example.com" "01 234 5678")` and then pass the result to `view`). Finally we change our `view` function to take a `contact` param and then use then to extract the necessary data.
20. Recompile the Main.elm file to JavaScript and refresh your browser. It should look exactly the same.

<TODO insert image https://www.dropbox.com/s/p89g7enzu20pa49/Screenshot%202015-08-26%2018.21.13.png?dl=0 >

21. We could continue to work with one file here, but it's going to start getting a bit hard to see what is going on. So let's extract our contact into a separate file. Create a file in the root of the project called Contact.elm and add the following to it.

  ```elm
  module Contact where

  import Html exposing (..)
  import Html.Attributes exposing (..)


  -- MODEL

  type alias Model =
    { name: String
    , email: String
    , phone: String
    }


  init name email phone =
    Model name email phone


  -- VIEW

  view contact =
    div [ class "contact" ]
    [ h2 [ class "contact__name" ] [ text contact.name ]
    , div [ class "contact__email" ]
      [ span [ ] [ text "Email:" ]
      , a [ href ("mailto:" ++ contact.email) ] [ text contact.email ]
      ]
    , div [ class "contact__phone" ]
      [ span [ ] [ text "Phone:" ]
      , a [ href ("tel:" ++ contact.phone) ] [ text contact.phone ]
      ]
    ]
  ```

22. We've taken all but the `main` method over and added a new `init` function that will allow us to easily generate a new contact Model. Now change your Main.elm file to look like this.

  ```elm
  module Main where

  import Contact exposing (init, view)


  main =
    view (init "Bobby Tables" "bobby@example.com" "01 234 5678")
  ```

23. Now we just need to import our Contact module and expose the `init` and `view` functions. Then we call the `view` function as before from our main method, but change the input to the view to use our exposed `init` function.
24. This is where we need to start introducing more advanced topics. We want to be able to handle HTTP requests and JSON decoding in order to get our contact data from the data API. In order to do that we need introduce concepts such as Signals, Tasks and Effects. Rather than do that (badly) here, I recommend that you follow through the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial), items 5 onwards in particular. We can side-step this a little in our application by utilising a package called StartApp. This will deal with all of the wiring under the cover and give us a simpler interface to work with.
25. We can start by introducing StartApp to our Main.elm file. We'll use the pattern suggested in the [StartApp documentation](http://package.elm-lang.org/packages/evancz/start-app/2.0.0/StartApp).

  ```elm
  module Main where

  import Contact exposing (init, update, view)

  import StartApp
  import Effects exposing (Never)
  import Task


  app =
    StartApp.start
    { init = init "Bobby Tables" "bobby@example.com" "01 234 5678"
    , update = update
    , view = view
    , inputs = []
    }


  main =
    app.html


  port tasks : Signal (Task.Task Never ())
  port tasks =
    app.tasks
  ```

26. We've imported the StartApp, Effects and Task modules. We then define a function called app which calls StartApp's `start` function passing in the required information. We'll come back to the `update` in a minute. The `inputs` is used to pass in external signals, but we can ignore this as we won't need it.
27. The `main` function needs to output HTML and so we pipe the HTML generated by StartApp out using its `html` function.
28. The `port tasks` basically allows you to take Tasks generated by StartApp and use them in your own application. Tasks are used to describe asynchronous operations that may fail. Like our HTTP requests for example. More on this later.
29. The `port tasks : Signal (Task.Task Never ())` is a [type annotation](http://elm-lang.org/docs/syntax#type-annotations) and describes the function's interface. I'll not delve into these here. Suffice it to say that they help others (including the compiler) to see how we expect our functions to be used. We should really use them above all of our functions but I've left them out for ease of understanding.
30. Now we need to change our Contact.elm file to provide the interface that we've promised to Main.elm.

  ```elm
  module Contact where

  import Html exposing (..)
  import Html.Attributes exposing (..)

  import Effects


  -- MODEL

  type alias Model =
    { name: String
    , email: String
    , phone: String
    }


  init name email phone =
    ( Model name email phone
    , Effects.none
    )


  -- UPDATE

  type Action = NoOp

  update action model =
    case action of
      NoOp -> (model, Effects.none)


  -- VIEW

  view address contact =
    div [ class "contact" ]
    [ h2 [ class "contact__name" ] [ text contact.name ]
    , div [ class "contact__email" ]
      [ span [ ] [ text "Email:" ]
      , a [ href ("mailto:" ++ contact.email) ] [ text contact.email ]
      ]
    , div [ class "contact__phone" ]
      [ span [ ] [ text "Phone:" ]
      , a [ href ("tel:" ++ contact.phone) ] [ text contact.phone ]
      ]
    ]
  ```

31. The first addition is `import Effects`, which allows us to use the Effects package. Effects can be thought of as a way to queue Tasks such as HTTP requests. You can read more about them on the [Elm Effects documentation](http://package.elm-lang.org/packages/evancz/elm-effects/1.0.0). Now that we are using StartApp, instead of just passing back a model from our `init` function we now also need to pass an Effect. We don't need an Effect just now so instead we use `Effect.none` as a "null" Effect.
32. We now need to introduce an `update` function that lets us update the Model. As it stands we don't yet have an state changes that we want to make, so let's just create a `NoOp` action, a trick I learned from the [Pragmatic Studios course](https://pragmaticstudio.com/courses/elm), that just returns the current model and another `Effects.none`. The `type Action = NoOp` lists the type of Actions that our `update` function handles.
33. Finally we need to pass an `address` into our `view` function as the first parameter. This allows any events triggered by the View to be routed to the right place. We don't have any yet, but StartApp needs the parameter to be in place even though we're not using it yet.
34. Now all we need to do is to install those packages we're importing.

  ```bash
  elm package install evancz/start-app --yes
  elm package install evancz/elm-effects --yes
  ```

35. Phew! OK, so we now have our application wired up with StartApp. Let's run `elm make --output conman.js Main.elm` again and check that everything still works in our browser.
36. If you're worried that you're seeing the same output in the browser, feel free to change the Contact name, email or phone and recompile to check that everything still works.
37. The final piece of the puzzle is to introduce our HTTP call and the converting of the returned JSON into a Model to be displayed.


## Combining Phoenix and Elm


### Running the two apps independently


### Using the Elm generated JavaScript within the Phoenix app


### Embedding the Elm app inside the Phoenix app



## Conclusions
