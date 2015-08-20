---
title:  Building an app using Phoenix and Elm
author: Alan Gardner
---

## Intro

I've recently been playing around, independently, with [Phoenix](http://phoenixframework.org) and [Elm](http://elm-lang.org). I'm really enjoying using both and so I thought I would see how easy it would be to combine the two, with Phoenix serving a data API and Elm consuming it.

We'll take a look at three approaches:

1. Independent - the Phoenix and Elm apps will exist as separate codebases and will be run independently.
2. Combined - the Phoenix and Elm apps will exist as separate codebases, but the JavaScript resulting from compiling the Elm app will be manually added to the Phoenix app and run from there.
3. Embedded - the Phoenix and Elm apps will exist a single codebase. The Elm app will be added into the Brunch workflow so that any changes to the Elm scripts are automatically built and the resulting JabaScript immediately available within the app.


## The project

We're going to build a really simple Contact Manager tool called ConMan. So simple in fact that ConMan will just fetch a list of contacts from our Phoenix data API and display them using Elm.


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

  # check that everything is working (you should have 4 passing tests)
  mix test

  # startup a server
  iex -S mix phoenix.server
  ```

4. If all has gone according to plan, you should now be able to see the default landing page if you point your browser to [http://localhost:4000](http://localhost:4000).
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

7. And run migrations to get the database up-to-date and run the tests to ensure that we haven't broken anything (note that we get tests for free by using the generator)

  ```bash
  mix ecto.migrate

  # check that everything is working (you should have 14 passing tests)
  mix test
  ```

8. Now, if we restart our server (`Cmd+c` twice and then `iex -S mix phoenix.server` again) and visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts), we should see an empty dataset.
9. Let's seed some contact data into the database. Open `priv/repo/seeds.exs` and add the following:

  ```elixir
  Conman.Repo.insert!(%Conman.Contact{name: "Bobby Tables", email: "bobby@example.com",    phone: "01 234 5678"})
  Conman.Repo.insert!(%Conman.Contact{name: "Molly Apples", email: "molly@example.com",    phone: "01 789 2340"})
  Conman.Repo.insert!(%Conman.Contact{name: "Elroy Bacon",  email: "el_bacon@example.com", phone: "01 398 7654"})
  ```

10. Now add those to the database by running `mix run priv/repo/seeds.exs`.
11. If we visit [http://localhost:4000/api/contacts](http://localhost:4000/api/contacts) again we can see that we now have three contacts. However we're not getting any information about them. Let's fix that by opening `web/views/contact_view.ex` and changing the `def render("contact.json" ...` function to the following:

    ```elixir
    def render("contact.json", %{contact: contact}) do
      %{
        id: contact.id,
        name: contact.name,
        email: contact.email,
        phone: contact.phone
      }
    end
    ```

12. Refreshing our browser, we should now see the data that we expect.


## Building our front end client in Elm

OK, so we now have a very simple data API up and running. At this point in the post I was going to do a step-by-step walkthrough of creating an Elm app to consume it. However that is the subject of blog post (or more) of its own! As such I've decided just to post the contents of my Elm file below with comments to explain how it's working. If you want to know more about this application and how it all fits together then I suggest the best place to start is with the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial). As the first comment below states, the example app is pretty much based on exercise 5 in that tutorial.

```elm
-- Example based on Tutorial 5 on the Elm Architecture Tutorial (https://github.com/evancz/elm-architecture-tutorial)

module Main where

-- Gives us the ability to work with HTML elements
-- and attributes in our Views.
import Html exposing (..)
import Html.Attributes exposing (..)

-- Wiring that joins our Model-Update-View architecture
-- together and provides Effects for allowing Tasks to
-- flow through our application.
import StartApp
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task

-- Enables the fetching of data over HTTP and the decoding
-- of the returned JSON.
import Http
import Json.Decode as Json exposing ((:=))


-- This starts up our app using StartApp:
--
-- init   = points to our init function that derives the initial
--          state of the Model and runs any preliminary Tasks that
--          need to be run
-- update = points to the Updater that can step the application Model
-- view   = points to the base View for the application
-- inputs = any external signal that our application needs, ignore for now
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


-- Display the HTML returned by StartApp.
main : Signal Html
main =
  app.html


-- Port Tasks that are created in StartApp to this application
-- without this we can't see any affects of updating the Model.
-- For more info see http://package.elm-lang.org/packages/evancz/start-app/2.0.0/StartApp
port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


-- MODEL
-- The Model describes the current state of the application.

-- Defines a Contact.
type alias Contact =
  { name: String
  , email: String
  , phone: String
  }


-- Defines the overall application Model.
type alias Model =
  { contacts : (List Contact) }


-- Defines how to set up the initial state of the application.
-- In this case we built a Model with an empty contacts list
-- and call fetchContacts to get an Effects Action that will
-- populate the contacts list.
init : (Model, Effects Action)
init =
  ( Model [ ], fetchContacts )


-- UPDATE
-- Updates the Model state through a set of defined Actions.
-- Whenever the Model's state is updated the Views will automatically
-- re-render.

-- Defines the Actions allowed by the application
type Action
  = RefreshContacts (Maybe (List Contact))


-- Takes any given input and produces a new application Model (and possibly also new Effects Action).
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    -- The supplied `contacts` params can either be an HTTP error
    -- or a List of Contact models.
    -- If contacts is an error the `Maybe.withDefault` will provide
    -- an empty list, otherwise it will provide the given List of
    -- Contact models.
    -- `Effects.none` is used to show that no further actions
    -- need to be taken.
    RefreshContacts contacts ->
      ( Model (Maybe.withDefault [] contacts)
      , Effects.none
      )


-- VIEW
-- Defines how the application Model is displayed.

-- Base view to display the ConMan UI.
view : Address Action -> Model -> Html
view address model =
  div [ class "container" ]
  [ h1 [ ] [ text "Conman" ]
  , contactList model.contacts
  ]


-- Display a list of contacts.
contactList : List Contact -> Html
contactList contacts =
  ul [ class "contact-list" ] (List.map contactListItem contacts)


-- Display an individual contact.
contactListItem : Contact -> Html
contactListItem contact =
  li [ class "contact-list__contact" ]
  [ h2 [ class "contact-list__contact__name" ] [ text contact.name ]
  , div [ class "contact-list__contact__email" ]
    [ span [ ] [ text "Email:" ]
    , a [ href ("mailto:" ++ contact.email) ] [ text contact.email ]
    ]
  , div [ class "contact-list__contact__phone" ]
    [ span [ ] [ text "Phone:" ]
    , a [ href ("tel:" ++ contact.phone) ] [ text contact.phone ]
    ]
  ]


-- EFFECTS

-- Fetches contact data from the dataAPI:
--
-- 1. GET contacts data and decode using the `decodeContacts` function below.
-- 2. Pipe to `Task.maybe` to move any errors from the fail response to the
--    success response. This allows us to bubble errors to the Update, which
--    can then handle them.
-- 3. Pipe to `Task.map` which converts the data into an Action that can be run.
-- 4. Pipe that Action to `Effects.task` which queues the Task to be run.
--
-- Result should be an updated application Model that contains Contact models for
-- each contact returned by the API.
fetchContacts : Effects Action
fetchContacts =
  Http.get decodeContacts "http://localhost:4000/api/contacts"
    |> Task.toMaybe
    |> Task.map RefreshContacts
    |> Effects.task


-- Defines the rule for decoding the JSON data returned by the API.
decodeContacts : Json.Decoder (List Contact)
decodeContacts =
  let contact =
        Json.object3 (\name email phone -> (Contact name email phone))
          ("name" := Json.string)
          ("email" := Json.string)
          ("phone" := Json.string)
  in
      "data" := Json.list contact

```


## Running the two apps independently


## Using the Elm generated JavaScript within the Phoenix app


## Embedding the Elm app inside the Phoenix app


## Conclusions
