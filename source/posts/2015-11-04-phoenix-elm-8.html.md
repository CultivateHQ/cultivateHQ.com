---
title: Phoenix with Elm - part 8
author: Alan Gardner
description: Currently our application only allows us to model a given state and perform actions that result in changes to that state. We create an initial state for our application with the init function and thereafter are only able to change that state via the update function.
tags: alan
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>


## Introducing Effects

Currently our application only allows us to model a given state and perform actions that result in changes to that state. We create an initial state for our application with the `init` function and thereafter are only able to change that state via the `update` function. The `update` function always returns a new Model and so the only way to do anything other than generate a new Model is to have some kind of side effect happening before we return the new Model. This is bad form in purely functional languages like Elm.

So, what if we wanted to perform some action that didn't directly affect the state of the application? Say, for example, we wanted to perform an HTTP request (an HTTP *response* may change the state of the application, but the initial HTTP *request* will not). Elm's *StartApp* (as opposed to *StartApp.Simple*) provides [Effects](http://package.elm-lang.org/packages/evancz/elm-effects/2.0.0/Effects) for this purpose. Effects enable us to perform tasks such as HTTP requests and channel the results back through the application in a form that Elm understands.

Let's upgrade our application from *StartApp.Simple* to *StartApp*.

1. We'll start from the top. Change the `main` function to the following:

    ```haskell
    app =
      StartApp.start
        { init = init
        , update = update
        , view = view
        , inputs = []
        }

    main : Signal Html
    main =
      app.html

    port tasks : Signal (Task Never ())
    port tasks =
      app.tasks
    ```

    We start by defining a function `app` (we'll ignore its type annotation for now), and inside it we call the `start` function of `StartApp`, rather than of `StartApp.Simple`. This function takes a record with four keys: `init` which takes the initial model provided by our `init` function, the `update` and `view` functions as before, and a list of `inputs`. Inputs allow us to specify external Signals that provide Actions to our application. We'll revisit these later. For now we initialize with an empty list.

    We then change our `main` function so that it calls the `html` function on the function returned by our `app` function. This gives us access to the HTML that results from the View function we passed to StartApp.

    Likewise we create a [port](http://elm-lang.org/guide/interop#ports) so that we can use any [tasks](http://elm-lang.org/guide/reactivity#tasks) that pass through StartApp. We'll discuss tasks and ports more in later posts.

2. In order to be able to use the new StartApp and related packages we need to change our existing `StartApp.Simple` import to the following:

    ```haskell
    import StartApp
    import Effects exposing (Effects, Never)
    import Task exposing (Task)
    ```

    And we'll need to import the Effects package.

    ```shell
    cd web/elm
    elm package install evancz/elm-effects -y
    cd ../..
    ```

3. Now that we're using the new StartApp our initializer needs to return more than just the initial Model. It needs to return a tuple with the initial Model and an `Effects Action`. An `Effects Action` can be thought of as a way to send an Effect that will result in an Action. As we have no Action to send at this point we use a null Effect (supplied by `Effects.none`).

    Change the `init` function to the following:

    ```haskell
    init : (Model, Effects Action)
    init =
      let
        seats =
          [ { seatNo = 1, occupied = False }
          , { seatNo = 2, occupied = False }
          , { seatNo = 3, occupied = False }
          , { seatNo = 4, occupied = False }
          , { seatNo = 5, occupied = False }
          , { seatNo = 6, occupied = False }
          , { seatNo = 7, occupied = False }
          , { seatNo = 8, occupied = False }
          , { seatNo = 9, occupied = False }
          , { seatNo = 10, occupied = False }
          , { seatNo = 11, occupied = False }
          , { seatNo = 12, occupied = False }
          ]
      in
        (seats, Effects.none)
    ```

    The `in` block now returns `(seats, Effects.none)`.

4. Because our `update` function steps the Model from one state to the next, it too needs to return this tuple of Model and Effects Action.

    ```haskell
    update : Action -> Model -> (Model, Effects Action)
    update action model =
      case action of
        Toggle seatToToggle ->
          let
            updateSeat seatFromModel =
              if seatFromModel.seatNo == seatToToggle.seatNo then
                { seatFromModel | occupied = not seatFromModel.occupied }
              else seatFromModel
          in
            (List.map updateSeat model, Effects.none)
    ```

    Now we have the option of either changing the state of the Model, or performing an Effect like an HTTP request, or both (or neither in the case of a NoOp).

5. If we visit <http://localhost:4000> in our browser our application should look and behave the same as before.

    ![toggling a seat](/images/phoenix-elm/wNpuUF1fHn.gif)


## Summary

We have now set up our Elm application to use Effects. This allows for Actions that do things other than change the Model. In [part 9](/posts/phoenix-elm-9) we'll use Effects to get data for our Elm application from our Phoenix application over HTTP.
