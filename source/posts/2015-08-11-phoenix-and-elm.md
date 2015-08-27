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

22. We've taken all but the `main` function over and added a new `init` function that will allow us to easily generate a new contact Model. Now change your Main.elm file to look like this.

  ```elm
  module Main where

  import Contact exposing (init, view)


  main =
    view (init "Bobby Tables" "bobby@example.com" "01 234 5678")
  ```

23. Now we just need to import our Contact module and expose the `init` and `view` functions. Then we call the `view` function as before from our main function, but change the input to the view to use our exposed `init` function.
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
38. Let's start by changing our Contact.elm file as follows.

  ```elm
  ...

  import Effects
  import Task

  import Http
  import Json.Decode as Json exposing ((:=))

  ...


  init =
    ( Model "" "" ""
    , fetchContact
    )


  -- UPDATE

  type Action
    = NoOp
    | Refresh (Maybe Model)

  update action model =
    case action of
      NoOp -> (model, Effects.none)

      Refresh contact ->
        ( Maybe.withDefault model contact
        , Effects.none
        )

  ...


  -- EFFECTS

  fetchContact =
    Http.get decodeContact "http://localhost:4000/api/contacts/1"
      |> Task.toMaybe
      |> Task.map Refresh
      |> Effects.task


  decodeContact =
    let contact =
          Json.object3 (\name email phone -> (Model name email phone))
            ("name" := Json.string)
            ("email" := Json.string)
            ("phone" := Json.string)
    in
        Json.at ["data"] contact
  ```

39. There's a lot going on here so let's start with the `init` function where we swap out our `Effects.none` for a new function called `fetchContact`. We'll get to that function later, but for now know that it returns an Effect.
40. We also added a new update Action `Refresh`. This takes a given model wrapped in a [Maybe](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Maybe) as an argument. All you need to know about the Maybe is that it lets us handle HTTP errors. The body of the function then looks at what it was given. If it was anything other than a valid new state for our model it just returns the current model. Otherwise it updates the current model to the model passed in.
41. At the bottom we added a new `--EFFECTS` section. The first function we added creates the HTTP request to the given URL and sets up a chain so that, when the call is made, it wraps the response in a Maybe (which let's us handle errors in the `update` function), states that the resulting Maybe should be piped to the `Refresh` update function and then stores this pipeline as an Effect.Action so that it can be queued to be run through the application. You can read more about this type of process on the [Elm Reactivity page](http://elm-lang.org/guide/reactivity).
42. You'll see that the first argument to the `Http.get` function is our second Effects function `decodeContact`. This function tells Elm how to parse the returned response. It takes the JSON response and spits out a Contact model. It is this model that is given to the `Refresh` action and is the data required to represent the returned contact.
43. Please note that the URL used her assumes that you have your data API running on `http://localhost:4000` and that you have a contact with an ID of 1. Make any necessary adjustments if this is not the case.
44. Now we need to update our Main.elm file so that it no longer passes in the hardwired contact details. You could actually leave this as is, but you will see the hardwired contact data flash up first before the HTTP request is made, parsed and the application state updated.

  ```elm
  app =
    StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }
  ```

45. We'll need to install the HTTP package for our code to work.

  ```bash
  elm package install evancz/elm-http --yes
  ```

46. And now we should have everything in place on the ELM side to get the client up and running. To check this out let's fire up our Phoenix data API and then recompile the Main.elm file and refresh the browser. Uh oh, something is wrong, we're not seeing a contact. Checking the browser's console will reveal the cause. We've got a [Cross Origin Resource Sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) issue. We'll deal with that in the next section.

<TODO: insert image https://www.dropbox.com/s/e7itharktos9ddz/Screenshot%202015-08-27%2008.23.41.png?dl=0 >


## Combining Phoenix and Elm

One way or another we now have a Phoenix data API and an Elm client that reads data from that API. Now let's look at ways that we can combine them together.

If you've not been following along you can get to the current state of play by doing as follows:

```bash
git clone git@github.com:cultivate/conman_ui.git

git clone git@github.com:cultivate/conman_data.git
cd conman_data
iex -S min phoenix.server
```


### 1. Running the two apps independently

The first way is to work with them as separate apps entirely. This is essentially what we have just now. If you open `conman_ui/index.html` in your browser you will see the following:

<TODO insert image https://www.dropbox.com/s/e7itharktos9ddz/Screenshot%202015-08-27%2008.23.41.png?dl=0 >

This is because the Elm application is not on the same origin as the Phoenix server. We can get around this by adding [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) handling to our Phoenix application.

1. We can use [mschae/cors_plug](https://github.com/mschae/cors_plug) to do this.
2. Add the following to the Phoenix `mix.exs` file

  ```elixir
  def deps do
    # ...
    {:cors_plug, "~> 0.1.3"},
    #...
  end
  ```

3. Run `mix deps.get` to pull the code and then add the following to the `lib/conman_data/end_point.ex` file just above the call to `plug ConmanData.Router`

  ```elixir
  plug CORSPlug

  plug ConmanData.Router
  ```

4. We'll not worry about adding any specific configuration at this point.
5. If you restart your server `iex -S mix phoenix.server` then you should now see the contact being pulled through correctly.

<TODO insert image https://www.dropbox.com/s/l4bhmpyvlnmcag6/Screenshot%202015-08-27%2012.33.04.png?dl=0 >

This previous approach works well and gives you a great separation of concerns. However if the two are really two parts of the one application, and neither have much function without the other, you could argue that having them as two separate projects in separate version controlled projects is not ideal. To be clear, _I'm not saying this_ I haven't yet made up my mind how best to run these two technologies together. However, let's look at two ways in which our Elm application can live inside our Phoenix application.


### 2. Using the Elm generated JavaScript within the Phoenix app

The first way in which we can combine the two is also the simplest. we just vendor the JavaScript file that is built by Elm. You can either compile directly to your Phoenix project's `web/static/vendor` folder, or compile and then manually copy the resulting JavaScript file over. In order to use this file on the site we'll need to make a slight tweak to the Phoenix application.

1. Change the `web/templates/layout/app.html.eex` as follows.

  ```html.eex
  <body>
    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
    <script>
      var app = Elm.fullscreen(Elm.Main);
    </script>
  </body>
  ```

2. Now copy the `conman.js` file over from the Elm app to `web/static/vendor` (if you haven't already) and point your browser at [http://localhost:4000](http://localhost:4000) and you should see the contact appearing as before (albeit with some Phoenix default styling added in).

  <TODO insert image https://www.dropbox.com/s/p0daix3th3muvc5/Screenshot%202015-08-27%2014.38.38.png?dl=0 >

3. We can safely take the CORS Plug back out now if we want to.

This method could be seen to give us the best of both worlds. We still have a clear line of separation between the two apps, but the result of building the Elm application is embedded in the Phoenix application so the project will work for anyone getting our application from version control without them having to necessarily also get the Elm application code.

On the other hand it could be see to be the worst of both worlds, we still have to keep to version controlled projects and anyone working with the front end is going to have to know that the JavaScript must be compiled from the Elm application. The third way allows us to embed the whole Elm application inside our Phoenix application and even hook it into the Phoenix Brunch pipeline so that everything just works.


### 3. Embedding the Elm app inside the Phoenix app

In order to add Elm to the existing Brunch pipeline that Phoenix has, we can use the [Elm Brunch Plugin](https://github.com/madsflensted/elm-brunch). Let's set that up first.

> CAVEAT: you might it better to stop the Phoenix server at this point. If Elm Brunch is not setup properly you can find yourself with an `elm-stuff` folder and `elm-config.json` in the root of your Phoenix project. If that does happen though, simply deleting them and checking the Elm Brunch config should get things back on track.

1. All that Brunch needs in order to know to run a plugin is to add it to our `package.json` as a dependency. Add it before the `javascript-brunch` line as these will get called in order by Brunch.

  ```json
  {
    "repository": {
    },
    "dependencies": {
      ...
      "elm-brunch": "^0.3.0",
      "javascript-brunch": ">= 1.0 < 1.8",
      ...
    }
  }
  ```

2. Now run `npm install` in the root of your Phoenix project to install the plugin.
3. We can now configure the plugin to work with our app inside the `brunch-config.js`. Change the plugins section so that it looks similar to the following.

  ```json
  // Configure your plugins
  plugins: {
    elmBrunch: {
      elmFolder: 'web/elm',
      mainModules: ['Main.elm'],
      outputFolder: '../static/vendor'
    },

    ...
  },
  ```

4. And then your watched list look like the below.

  ```json
  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["deps/phoenix/web/static",
              "deps/phoenix_html/web/static",
              "web/static", "test/static",
              "web/elm/Main.elm", "web/elm/Contact.elm"],

    // Where to compile files to
    public: "priv/static"
  },
  ```

5. As you can probably tell from the configuration we just added, we're going to copy our Elm project into `web/elm`. Before we do this we want to make sure that Brunch isn't going to pick up any JavaScript that might be in our `web/elm` folder. We do this by adjusting the files section to look like the below.

  ```json
  files: {
    javascripts: {
      joinTo: {
        'js/app.js': /^(web\/static)/
      }
    },
    ...
  }
  ```

6. Finally we can take out the existing `conman.js` in `web/static/vendor`. We don't need to do this, but it's always a good sense check that our build pipeline is setup correctly to see the file actually being built.
7. Now we can create our `web/elm` folder and copy the `Main.elm`, `Contact.elm` and `elm-package.json` files over from our Elm project folder. We don't need the rest of the files. Anything that we need will be built for us.
8. Once that's all in place, fire up the Phoenix server `iex -S mix phoenix.server` and head to [http://localhost:4000](http://localhost:4000) to see the result ... which is of course the same!
9. To check that everything is working, let's change the URL we're calling in the `web/elm/Contact.elm` file so that we get a different contact. If you keep the browser and the editor side-by-side whilst you do this you will be able to see it all happen in real time! Oh the giddy excitement!

  ```elm
  -- EFFECTS

  fetchContact =
    Http.get decodeContact "http://localhost:4000/api/contacts/2"
      |> Task.toMaybe
  ```


## Conclusions

So, there we have it. Three different ways that you can put an Elm in your Phoenix. I've only just started playing about with these technologies so I've yet to come to any strong conclusions about how they best work together. Hopefully this post has at least given you some food for thought as to how you might get these two playing nicely together.

My next move is to add channels into the mix so that we can get a nice flow through the application. When I know more I'll be sure to post it here. If you've been doing anything in this area [I'd love to hear about it](mailto:alan@cultivatehq.com).

