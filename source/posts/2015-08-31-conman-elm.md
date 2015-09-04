---
title:  Building a data client in Elm
author: Alan Gardner
---

> I've recently been playing around, with [Phoenix](http://phoenixframework.org) and [Elm](http://elm-lang.org). I'm really enjoying using both and so I thought I would see how easy it would be to combine the two, with Phoenix serving a data API and Elm consuming it.
> This is Part 2 in a series of 4 posts. In it we will walk through setting up a basic Elm client that will consume the data we serve from the API we built in [Part 1](#part_1). [Part 3](#part_3) talks about combining the Phoenix and Elm projects together, and [Part 4](part_4) walks through adding support for Phoenix channels.

**We are using Elm version `0.15.1`.**


## TL;DR

If you'd rather just see the code, it's available on [GitHub](http://github.com/CultivateHQ/conman_ui). You can look at the commit history to see the steps involved.

Jump [straight to part 3](#part_3) to carry on with the tutorial.


## Up and running

If you have been [following along](#part_1), you should now have a basic Phoenix data API that can serve contact data.

If you haven't been following along you can clone the [data API project](http://github.com/CultivateHQ/conman_data) instead, and then follow the instructions in the [README](http://github.com/CultivateHQ/conman_data/README.md) to start the server.

If you haven't got Elm installed, you can can do so from the [Elm install page](http://elm-lang.org/install).


## Introduction

We now have a very simple data API up and running, so let's create a client in Elm that uses that API. Please note that we'll be glossing over quite a lot in order to keep this section focussed. If you'd like more information on Elm then I fully recommend starting with the [Pragmatic Studios Elm course](https://pragmaticstudio.com/courses/elm) and then moving on to the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial). We're going to follow the patterns set out in the Elm Architecture Tutorial to build our Elm application.


## 1. Getting something working

1. First we'll need to create our base Elm application. Navigate to the directory where you want to create this and do the following:

  ```bash
  md conman_ui

  cd conman_ui

  elm package install --yes
  ```

2. That will create a folder for our application, install the Elm core packages (into the `elm-stuff` folder) and create an application manifest file (`elm-package.json`).
3. From the root of our new project, create a ConMan.elm file and open it in your editor of choice. Add the following to that file.

  ```elm
  module ConMan where

  import Html


  main =
    Html.text "ConMan is alive!"
  ```

4. The code above creates a module called ConMan, imports the Html package and then uses it to output the text "ConMan is alive!". The `main` function is required as the starting point for an Elm application.
5. In order to use this though, we need to add the elm-html package and compile ConMan.elm to JavaScript. We can do this from the terminal as follows.

  ```bash
  elm package install evancz/elm-html --yes
  elm make --output conman.js ConMan.elm
  ```

6. This will compile the Elm code into a JavaScript file called conman.js in the directory in which the command was run.
7. Now we can create an HTML file that will allow us to use the JavaScript file in the browser. Create a file on the root of the project called `index.html` and add the following code to it.

  ```html
  <!DOCTYPE html>
  <html>
    <head>
      <title>ConMan - Contact Manager</title>
    </head>
    <body>
      <script src="conman.js"></script>
      <script>
        var app = Elm.fullscreen(Elm.ConMan);
      </script>
    </body>
  </html>
  ```

8. Note that we have a `<script>` tag that gets our `conman.js` file, and another that runs a function `Elm.fullscreen` passing in our starting point (`Elm.ConMan`) and storing that in a variable called `app`. `Elm.fullscreen` will run our Elm application fullscreen rather than embedded within a particular DOM element within the page.
9. Now open the index.html file in a browser and you should see it output "ConMan is alive!"

<TODO: insert image https://www.dropbox.com/s/qe2oa5lyr6bgxn9/Screenshot%202015-08-31%2012.16.38.png?dl=0 >


## 2. Introducing Views

Elm uses a Model-Update_View architecture. The Model describes the current state of the application, Update contains various actions that can be performed on the Model to transition it from the current state into a new state, and the View defines how the Model is displayed.

We'll start off with the View as that is the simplest to demonstrate. A View is just a function that returns HTML.

1. Open ConMan.elm in your editor and change the `main` function to the following.

  ```elm
  main =
    view


  -- VIEW

  view =
    Html.text "ConMan is alive!"
  ```

2. Rather than display the text directly in the `main` function, we can create a `view` function to handle that and then call it from the `main` function. `main` and `view` are the idiomatic names for these functions, although you can name the `view` function anything you like (also note that another Elm idiom is to have two line breaks between functions rather than one). the `-- VIEW` line is just a comment and has no special significance.
3. Now we can recompile our conman.js file and see that nothing has changed!

  ```bash
  elm make --output conman.js ConMan.elm
  ```

4. OK, so perhaps showing that nothing has changed is not the most ideal way to show something working. But you can verify that something is indeed happening by changing the text we are outputting to "ConMan is in a View!" and run `elm make --output conman.js ConMan.elm` again.

<TODO insert image https://www.dropbox.com/s/v5nk0p6hdu97kzp/Screenshot%202015-08-31%2012.38.26.png?dl=0 >

By this point you may be itching to automate this build process using your build pipeline of choice. Feel free to scratch that itch, but be aware that we will doing so using Brunch in [Part 3](#part_3) to fit in with Phoenix.


## 3. Exposing functions

Back to the task at hand. We're going to be using quite a few functions from both the Html module. Rather than do what we've been doing so far and explicitly using the Html namespace (i.e. `Html.text`), we'll change the way that we import that module to expose the `text` function instead.

1. Change your ConMan.elm file to the following:

  ```elm
  module ConMan where

  import Html exposing (text)


  main =
  view


  -- VIEW

  view =
    text "ConMan is in a View!"
  ```

2. If you run `elm make --output conman.js ConMan.elm` it should compile successfully. Refresh your browser to see that it displays exactly as before.
3. As it happens we'll need to use a few different functions from the `Html` module, and also some from the `Html.Attributes` module. As such we can use the `exposing (..)` syntax to enable us to expose any function from the `Html` and `Html.Attributes` modules.

  ```elm
  import Html exposing (..)
  import Html.Attributes exposing (..)
  ```

4. Be careful when using this approach though as it can start to become confusing as to where a function you are using has been defined. In the case of the `Html` and `Html.Attributes` modules, it should be fairly self-explanatory, as you will see in the next section.

## 4. Building a Contact View

Let's now swap out our "ConMan is in a View!" text for something more useful

1. Replace the current View code with the following:

  ```elm
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

2. We've fleshed out the view to show a sample contact. The functions `div`, `h2`, `text`, `span`, and `a` all come from the `Html` module. The `class` and `href` functions come from the `Html.Attributes` module. These functions are used to construct HTML that is then displayed to the user. The format of these function calls is as follows:

  ```elm
  element [ attribute list ] [ content list ]

  -- i.e.
  div [ class "my-class" ] [ text "Hello" ]
  ```

3. Recompile the Elm file to JavaScript again and refresh your browser. You should see the following.

<TODO insert image https://www.dropbox.com/s/f2fl1mxomkl2lt2/Screenshot%202015-08-31%2014.03.25.png?dl=0 >

Please note that instead of using `exposes(..)` we could have given a list of the functions that we were going to use instead.

```elm
import Html exposing (div, h2, text, span, a)
import Html.Attributes exposing (class, href)
```


## 5. Introducing a Model

As mentioned in section "2. Introducing Views", Elm uses a Model-Update-View architecture. We've looked at the View, now let's look at the Model. We'll do so by changing our application to use a Model that can be passed to the View (rather than hard code the View with the contact data).

1. Add the following under the `main` function:

  ```elm
  ...

  main =
    view


  -- MODEL

  type alias Model =
    { name: String
    , email: String
    , phone: String
    }


  ...
  ```

2. We defined a `type alias` for the Elm `Model` type. This is essentially just saying to the Elm app, when we talk about the Model from now on we are referring to a record that contains three Strings representing the name, email and phone for a contact.
3. Now we can change our `view` to take a contact as an argument and then use that contact internally to get the data to output.

  ```elm
  ...


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
4. Finally we change our main function to build a Model to build a contact with the name, email and phone we had hardwired previously in the View. Then we pass it as an argument to `view`.

  ```elm
  ...

  main =
    view (Model "Bobby Tables" "bobby@example.com" "01 234 5678")


  -- MODEl
  ...
  ```

5. Note that parentheses in Elm are used to indicate precedence, not to encapsulate parameters, i.e. `view (Model "Bobby Tables" "bobby@example.com" "01 234 5678")` says run `Model "Bobby Tables" "bobby@example.com" "01 234 5678"` and then pass the result to `view`.
6. Recompile the ConMan.elm file to JavaScript and refresh your browser. It should look exactly the same.

<TODO insert image https://www.dropbox.com/s/f2fl1mxomkl2lt2/Screenshot%202015-08-31%2014.03.25.png?dl=0 >


## 6. Extracting the Contact

We could continue to work with one file here, but it's going to start getting a bit hard to see what is going on. So let's extract our contact into a separate file.

1. Create a file in the root of the project called Contact.elm and add the following to it.

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

2. We've taken all but the `main` function from our ConMan module over to our new Contact module.
3. Now, in the ConMan.elm file, remove the imports for `Html` and `Html.Attributes` because we don't need them any more. Instead we need an import for our new Contact module, exposing the `Model` type and `view` function.

  ```elm
  import Contact exposing (view, Model)
  ```

Recompile the ConMan.elm file to JavaScript (it will automatically compile any referenced modules such as our Contact module) and refresh your browser. It should look exactly the same.

<TODO insert image https://www.dropbox.com/s/f2fl1mxomkl2lt2/Screenshot%202015-08-31%2014.03.25.png?dl=0 >


## 7. Introducing the Update function

We've now covered the Model and View parts of the Model-Update-View architecture, but what about the Update part? Well we don't have a reason to have an `update` function yet as we have no way of updating the application's state (e.g there are no inputs in our View and we're not reacting to any other events yet). However, rather than leaving this until we do have something to handle, let's introduce a NoOp just now so that we can see how the Update works (this is a trick I learned from the [Pragmatic Studios course](https://pragmaticstudio.com/courses/elm)).

1. In your Contact.elm file, add the following between the `-- MODEL` section and the `-- VIEW` section.

  ```elm
  ...


  -- UPDATE

  type Action = NoOp

  update action model =
    case action of
      NoOp -> model


  -- VIEW
  ...
  ```

2. Before we define our `update` function we need to list the types of Action that the `update` function is allowed to make. In this instance we only have one Action, called NoOp.
3. The `update` function takes as arguments the action to perform and the current application state (i.e. the model). It then performs the given action on the current state to provide the new application state, which is then returned.
4. In the case of our NoOp action, it simply returns the current model with no action taken upon it.

This is not very useful in its own right, but it will shortly become useful. Better to introduce it now so we can see its size and shape.


## 8. Introducing an initializer function

One final tweak that we'll make before delving into more complex topics is to introduce an initializer to the Contact module, rather than expose its `Model` type. The benefits of this won't be seen until the next section, but we'll do it here in preparation.

1. Add an `init` function to the `Contact` module's `-- MODEL` section that takes name, email and phone strings and returns a Model created with those strings.

  ```elm
  ...

  init name email phone =
    Model name email phone


  -- UPDATE
  ...
  ```

2. Now, inside your ConMan module, expose `init` instead of `Model` and use it in the `main` function.

  ```elm
  import Contact exposing (view, init)


  main =
    view (init "Bobby Tables" "bobby@example.com" "01 234 5678")
  ```

Recompile the ConMan.elm file to JavaScript and refresh your browser. It should still look exactly the same.

<TODO insert image https://www.dropbox.com/s/f2fl1mxomkl2lt2/Screenshot%202015-08-31%2014.03.25.png?dl=0 >


## 9. Drawing the rest of the owl

So far things have been fairly straightforward. We have a Contact module that defines how to initialise a new contact (the `init` function) and how it should be displayed (the `view` function). These are then exposed and used in the overall application's `main` method. We also have an `update` function on the contact that we're not using yet.

Now we need to start introducing some more advanced topics. We want to be able to handle HTTP requests and JSON decoding in order to get our contact data from the data API. In order to do that we need to introduce concepts such as Signals, Tasks and Effects. Rather than do that (badly) here, I recommend that you follow through the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial) (items 5 onwards in particular) once you've finished this article.

We can side-step this a little in our application just now by utilising a package called [StartApp](http://github.com/evancz/start-app). This will deal with all of the wiring under the cover and give us a simpler interface to work with.


### Adding the necessary wiring

We'll start by introducing StartApp to our ConMan.elm file. We'll use the pattern suggested in the [StartApp documentation](http://package.elm-lang.org/packages/evancz/start-app/2.0.0/StartApp).

1. Let's begin by creating an `app` function to wrap our call to StartApp's `start` function. This function takes four arguments:

  a. `init` expects a function that describes the initial state of our application (i.e. our Contact's `init` function)

  b. `update` expects an Update function (i.e. our Contact's `update` function)

  c. `view` expects a function that returns the HTML for our application (i.e. our Contact's `view` function)

  d. `inputs` expects a list of external signals that our application depends on (in our case just an empty list as we have no external signals).

2. We'll also need to import StartApp in order to be able to use it.

  ```elm
  ...

  import Contact exposing (init, update, view)

  import StartApp
  ...


  app =
    StartApp.start
    { init = init "Bobby Tables" "bobby@example.com" "01 234 5678"
    , update = update
    , view = view
    , inputs = []
    }


  ...
  ```

3. The `main` function needs to output HTML and so we pipe the HTML generated by StartApp out using its `html` function.

  ```elm
  main =
    app.html
  ```

4. Seeing as we are offloading a lot of the wiring to StartApp, we need a way to get actions that occur in StartApp back into our app. Add the following function to the end of your ConMan.elm file to handle this.

  ```elm
  port tasks : Signal (Task.Task Effects.Never ())
  port tasks =
    app.tasks
  ```

5. We'll need imports for those `Task.Task` and `Effects.Never` call.

  ```elm
  ...

  import StartApp
  import Effects
  import Task

  ...
  ```

The `port tasks` function basically allows you to take Tasks generated by StartApp and use them in your own application. Tasks are used to describe asynchronous operations that may fail, like our HTTP requests for example. More on this later.

> The `port tasks : Signal (Task.Task Never ())` is a [type annotation](http://elm-lang.org/docs/syntax#type-annotations) and describes the function's interface. I'll not delve into these here. Suffice it to say that they help others (including the compiler) to see how we expect our functions to be used. We should really use them above all of our functions but I've left them out for ease of understanding.


### Refactoring Contact

Now we need to change our Contact.elm file to be able to work with StartApp. This involves two main changes: introducing Effects and letting the view know which address it should send any events it generates to.

1. Effects can be thought of as a way to queue Tasks such as HTTP requests. You can read more about them on the [Elm Effects documentation](http://package.elm-lang.org/packages/evancz/elm-effects/1.0.0) page. To set up Effects we first need to import the module.

  ```elm
  ...
  import Html.Attributes exposing (..)

  import Effects

  ...
  ```

2. Now we need to change the returned values from both our `init` function and our `NoOp` action so that they return both the current model and a null Effects instance. We use `Effects.none` for this purpose. What this basically means is that no further Effects need to occur at that point.

  ```elm
  ...

  init name email phone =
    ( Model name email phone
    , Effects.none)


  -- UPDATE

  type Action = NoOp

  update action model =
    case action of
      NoOp -> (model, Effects.none)

  ...
  ```

3. The address that we give to the `view` function is essentially an inbox where actions can be sent. StartApp will give an address as the first argument to the `view` function when it calls it so that the View knows how to communicate back to StartApp if it has any buttons or the like that allow input. We don't have any of these and so we won't use the address inside our definition, but we still need to add it as an argument.

  ```elm
  ...
  -- VIEW

  view address contact =
    ...
  ```

4. Now all we need to do is to install those packages we're importing.

  ```bash
  elm package install evancz/start-app --yes
  elm package install evancz/elm-effects --yes
  ```

5. Phew! OK, so we now have our application wired up with StartApp. Let's run `elm make --output conman.js ConMan.elm` again and check that everything still works in our browser.

> If you're worried that you're always seeing the same output in the browser, feel free to change the Contact name, email or phone and recompile to check that everything still works.


## 10. Making the HTTP request and handling the response

The final piece of the puzzle is to introduce our HTTP call and the converting of the returned JSON into a new Model to be displayed.

### Adding an Effect

1. Let's start by adding an `Effects.task` to our Contact module for performing the HTTP request. Append the following to the Contact.elm file:

  ```elm
  -- EFFECTS

  fetchContact =
    Http.get decodeContact "http://localhost:4000/api/contacts/1"
      |> Task.toMaybe
      |> Task.map Refresh
      |> Effects.task

  decodeContact =
    let contact =
          Json.object3 (\name email phone -> (init name email phone))
            ("name" := Json.string)
            ("email" := Json.string)
            ("phone" := Json.string)
    in
        Json.at ["data"] contact
  ```

2. This is doing quite a lot so let's look at it line by line.

  a. `Http.get decodeContact "http://localhost:4000/api/contacts/1"` creates an HTTP GET to the given URL and passes in the `decodeContact` function (defined beneath it) that knows how to convert the returned JSON into a contact model instance. It is important to note that the request is not being made yet. It is only being defined so that the Effects task can call it when it's ready.

  b. We then pipe that definition into a Task.maybe. Maybes are used in Elm when you are dealing with uncertainty in the type of something. In this case we don't know whether the `Http.get` function is going to return us a contact model or an error. Using Task.maybe allows us to postpone the handling of any errors. More on this when we look at the `update` function changes.

  c. We then tell the Task to invoke the `Refresh` action passing in the result of the Http.get.

  d. Finally we convert the `Task` into an `Effects.task` so that StartApp can run it through our application for us.

  e. `decodeContact` tells our application how to convert the expected JSON into a contact instance. It expects there to be a "data" key with an object as its value. That object is expected to have "name", "email" and "phone" keys that have string values. Those values are passed into the `Json.object3` function, which in turn initialises a contact instance with those values.


### Updating the `update` function

1. In our `fetchContact` function we invoked an Action called `Refresh`, but that Action doesn't exist yet. Let's add it now.

  ```elm
  ...
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
  ```

2. The `Refresh` action take a new contact (of type Model) wrapped in a [Maybe](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Maybe). We can use the Maybe to handle any errors that come back from our HTTp request.
3. Inside the definition we see that Refresh takes a contact argument. We then use the `Maybe.withDefault` function to say "If what you have given me is NOT of type Model then return the current `model`. If it IS of type model then return it instead". In practice this means that if we get a contact back from the data API its values will be used in the View. If we get an error however, the current model will remain being used instead.

### Initial state

Now that we have a way of fetching a contact, let's do that when we first initialise the application's state.

1. Change the `init` function to call our `fetchContact` function (which returns an Effect) rather than `Effects.none`:

  ```elm
  init name email phone =
    ( Model name email phone
    , fetchContact
    )
  ```

2. Let's also change our ConMan module to initialise the contact with no contact data so that we can see when we have contact data from the data API. In ConMan.elm, change the `app` function as follows:

  ```elm
  app =
    StartApp.start
    { init = init "" "" ""
    , ...
    }

  ...
  ```

### Imports

1. We are missing a couple of imports, so add the `Http` and `Json.Decode` modules to your Contact.elm file as follows:

  ```elm
  import Effects
  import Task

  import Http
  import Json.Decode as Json exposing ((:=))

  ...
  ```

2. We'll also need to install the elm-http package on the command line.

  ```bash
  elm package install evancz/elm-http --yes
  ```

3. Now we can recompile the ConMan.elm file and refresh our browser. If we have the [data API application](http://github.com/CulitivateHQ/conman_data) server running then we should see the details for our contact with ID 1 (you can find out the IDs of the contacts in your API by visiting http://localhost:4000/api/contacts).

  <TODO: insert image https://www.dropbox.com/s/e7itharktos9ddz/Screenshot%202015-08-27%2008.23.41.png?dl=0 >

## Conclusion

Well that was quite a journey! We've gone from something fairly straightforward to something quite complex and I appreciate there's been quite a bit of hand-waving going on. If you'd like to know more about Elm then I fully recommend starting with the [Pragmatic Studios course](https://pragmaticstudio.com/courses/elm). It gives a great intro to the language and goes into more depth on various things that I've hand-waved at or glossed over entirely.

Following on from that the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial) takes you step-by-step through Elm's architecture and how to scale from a basic model, like we have here, to more complex domains. It also covers StartApp, Effects, Http and the like in much more detail.

I'm really enjoying Elm. I like how it structures applications and gives you a nice, clear separation between the data, the states that data can go through and the presentation of that data.

Next up, in [Part 3](#part_3), we'll look at different ways that our Elm client and our [Phoenix data API](#part_1) can co-exist.
