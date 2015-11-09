---
title: Putting an Elm in your Phoenix - part 8
author: Alan Gardner
description: Upgrading to a more advanced StartApp.
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>


## Upgrading StartApp

So far `StartApp.Simple` has been good enough for us. However, in order to continue, we need more from StartApp. Let's upgrade our application and explain why as we go.

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

    Likewise we create a [port](http://elm-lang.org/guide/interop#ports) so that we can use any [tasks](http://elm-lang.org/guide/reactivity#tasks) that pass through StartApp. We'll discuss tasks and ports more later on.

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

3. Now that we're using the new StartApp we need to make a few changes to our existing code. We'll make these changes first and then talk about why we're making them afterwards.

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

    Our initializer no longer just returns the initial Model. It returns a tuple with the initial Model and a null Effect (supplied by `Effects.none`). We'll discuss what Effects are in a minute.

4. Because our `update` function steps the Model from one state to the next, it too needs to return this tuple of Model and Effects.action.

    ```haskell
    update : Action -> Model -> (Model, Effects Action)
    update action model =
      case action of
        Toggle seat ->
          let
            updateSeat s =
              if s.seatNo == seat.seatNo then { s | occupied <- not seat.occupied } else s
          in
            (List.map updateSeat model, Effects.none)
    ```

5. If we visit <http://localhost:4000> in our browser our application should look and behave the same as before.

    ![toggling a seat](/images/phoenix-elm/10.png)


## Effects

So, what are [Effects](http://package.elm-lang.org/packages/evancz/elm-effects/2.0.0/Effects) and why did we have to change our application to support them? Originally our application only allowed us to model a given state and perform actions that resulted in changes to that state. We created an initial state for our application with the `init` function and thereafter were only able to change that state via the `update` function. The `update` function always returned a new Model and so the only way to do anything other than generate a new Model would have been to have some kind of side effect happening before we returned the new Model. This is bad form in purely functional languages like Elm.

So what if we wanted to perform some action that didn't directly affect the state of the application? Say, for example, we wanted to perform an HTTP request. Elm's *StartApp* (as opposed to *StartApp.Simple*) provides Effects for this purpose. Effects enable us to perform tasks such as HTTP requests and channel the results back through the application in a form that Elm understands.


## Summary

Now we have the option of either changing the state of the Model, or performing an Effect like an HTTP request or both (or neither in the case of a NoOp).

In [part 9](/posts/phoenix-elm-9) we'll use Effects to get data for our Elm application from our Phoenix application over HTTP.