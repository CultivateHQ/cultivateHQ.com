---
title: Phoenix with Elm - part 6
author: Alan Gardner
description: Adding an update function.
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>

<section class="callout">
  Thanks to Anthony Verez (@netantho) for some corrections in this post. :)
</section>

## Adding an Update

We mentioned in [part 3](/posts/phoenix-elm-3) that Elm has a *Model - Update - View* architecture. We've looked at the [View](/posts/phoenix-elm-3) and the [Model](/posts/phoenix-elm-4), so let's turn our attention now to the Update. The best way to get a handle on what the `update` function will need to do is by taking a look at its [type annotation](/posts/phoenix-elm-5).

```haskell
update : Action -> Model -> Model
```

The `update` function will take two arguments, one of type Action and one of type Model, and return a value of type Model. In actual fact it will take a type of Action to be performed and the current Model (or state) of the application, perform that Action and return a brand new Model.

<div class="callout">
  It is important to note here that the <code>update</code> function does not <em>change</em> the current Model. It creates a whole new Model based on the current Model. The Model in Elm is immutable.
</div>

But what is an Action? Well it is a [Union Type](http://elm-lang.org/docs/syntax#union-types) that lets us group a bunch of other types together. The end result is that we can then pattern match on those types in order to perform different "actions".

Let's look at an example,

```haskell
-- UPDATE

type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
```

Let's assume that our Model is an Int that initializes to 0. We have two Actions, `Increment` and `Decrement`. When the update function is called it is passed an Action and the current Model. It will then pattern match on the given Action to produce a new Model, either adding 1 or subtracting 1 from the current value of the Model accordingly.

From this we can see that the purpose of the update function, for now anyway, is to step the Model from one state to the next.

Let's update our Elm application so that we can toggle a Seat from occupied to available and vice versa.

1. Add the following to your *web/elm/SeatSaver.elm* file. It doesn't matter where you put it, but I typically stick the Update between the Model and View sections.

    ```haskell
    -- UPDATE

    type Action = Toggle Seat


    update : Action -> Model -> Model
    update action model =
      case action of
        Toggle seat ->
          let
            updateSeat s =
              if s.seatNo == seat.seatNo then { s | occupied <- not seat.occupied } else s
          in
            List.map updateSeat model
    ```

    OK, there's a lot going on here, so let's take it line by line. First of all we define an Action called Toggle. The Toggle Action will take an argument of type Seat which is why we have `Toggle Seat`.

    In our `update` function we have a `case` statement that just has one matcher currently for our `Toggle` Action. The matcher will use `List.map` to call the `updateSeat` function for each seat in the model (remember our model is a List of Seat).

    The `updateSeat` function is defined in the `let` block, which enables us to define local functions that can be used within the matcher. That function checks to see if the seat passed into it `s` has a seatNo that matches the seatNo of the `seat` passed into the matcher. If it matches, the function returns a new seat record with the occupied boolean flipped to the opposite value. If it doesn't match it just returns a new seat record with the same values as the existing seat record.

    Phew! The upshot of this is that, when the `update` function is called with the Toggle Action and a seat, it will return a new List with the given seat's occupied boolean flipped.

2. We now have our `update` function but we're not using it anywhere. We could at this point start looking at Elm Signals and Mailboxes, at folding and mapping and merging, but let's not. Elm handily provides a wrapper around all of the necessary wiring required to have Actions routed around our application into the Update. This wrapper is called StartApp. Let's add it to our application. Open a terminal window and do the following:

    ```bash
    # navigate to the web/elm folder where our Elm application lives
    cd web/elm

    # add the start-app library
    elm package install evancz/start-app -y

    # and then return to the project root, lest we forget
    cd ../..
    ```

    Now we can import it in our *web/elm/SeatSaver.elm* file.

    ```haskell
    import StartApp.Simple
    ```

3. We need to change our `main` function to use the `start` function from the StartApp.Simple library. This takes as an argument a record with our model, update and view functions, does all the necessary wiring under the covers and returns a Signal of Html values.

    <div class="callout">
      A Signal in Elm is a value that changes over time. We'll deal with them more thoroughly later. For now think of a Signal as a value that changes depending on the current state of our application. Our Signal of Html that the <code>main</code> function returns represents the HTML that shows the current state of our Model.
    </div>

    ```haskell
    main : Signal Html
    main =
      StartApp.Simple.start
        { model = init
        , update = update
        , view = view
        }
    ```

4. We need to make one other change to join everything up. The View needs to have a way to pass events such as mouse clicks or key presses back to the Update. In order to do this when using StartApp we need to provide an address to send Actions to so that StartApp knows how to link everything together. We can do this as follows:

    ```haskell
    -- VIEW

    view : Signal.Address Action -> Model -> Html
    view address model =
      ul [ class "seats" ] (List.map (seatItem address) model)


    seatItem : Signal.Address Action -> Seat -> Html
    seatItem address seat =
      li [ class "seat available" ] [ text (toString seat.seatNo) ]
    ```

    We need to pass the address in as the first argument, which has the type `Signal.Address Action`. Don't worry too much about what is going on here just now. We will cover Signals in more detail later. We then add an argument `address` to the `view` function. Our `seatItem` will need to be set up in the same way so we pass the address to the seatItem when we call it `(seatItem address)`. This may look a little odd at first, but what we are creating here is a [partial function](https://wiki.haskell.org/Partial_functions). In other words, a function where we have already provided one or more of the arguments, but not all of them. `(seatItem address)` returns the `seatItem` function with the first argument `address` pre-filled.

5. We now have StartApp set up, but it doesn't yet _do_ anything. Let's change our view so that we can click on a seat in the browser and have that update the model using our Toggle action.

    ```haskell
    seatItem : Signal.Address Action -> Seat -> Html
    seatItem address seat =
      li
        [ class "seat available"
        , onClick address (Toggle seat)
        ]
        [ text (toString seat.seatNo) ]
    ```

    We've added an `onClick` function to our attributes, which takes the `address` to send the Action to as its first argument and the Action to be called (curried with the seat that was clicked to create a partial function) as its second.

    We need to import the onClick event for this to work.

    ```haskell
    import Html.Events exposing (onClick)
    ```

    When we click on a seat we create a Toggle Action with the seat that was clicked as an argument and send it to the given address. StartApp will handle things from here, picking the Action up and routing it through the `update` function. This in turn will toggle the occupied flag of that seat.

6. Changing the occupied flag is all well and good, but we can't actually tell currently if that has happened or not. So that we get an indication that something has happened let's change the style of the seat based on its occupied status.

    ```haskell
    seatItem : Signal.Address Action -> Seat -> Html
    seatItem address seat =
      let
        occupiedClass =
          if seat.occupied then "occupied" else "available"
      in
        li
          [ class ("seat " ++ occupiedClass)
          , onClick address (Toggle seat)
          ]
          [ text (toString seat.seatNo) ]
    ```

    We're using a `let` block again to define a local function `occupiedClass` that will return "occupied" if the seat is occupied or "available" if it is not. We then use the `++` function to concatenate the result of calling `occupiedClass` with the existing class string.

7. Now, if you go to your browser, you should be able to click on the seats and see them turn from gray to green and back again!

    ![toggling a seat](/images/phoenix-elm/10.png)


## Summary

This has been a rather long and complex section of the tutorial, but we finally have something that we can interact with. This may seem like a lot of effort to set up something relatively simple, but the pay-offs come further down the line as we add more complexity.

We'll take a brief detour in [Part 7](/posts/phoenix-elm-7) to look at Signals. After that we can start to bring in Phoenix to bring our application to life.
