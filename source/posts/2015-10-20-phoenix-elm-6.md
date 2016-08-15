---
title: Phoenix with Elm - part 6
author: Alan Gardner
description: We mentioned in part 3 that Elm has a Model - Update - View architecture. We've looked at the View and the Model, so let's turn our attention now to the Update. The best way to get a handle on what the update function will need to do is by taking a look at its type annotation.
tags: alan
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver-017) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>

<section class="callout">
  Thanks to Anthony Verez (@netantho) and Mark Provan (@markprovan) for some corrections in this post. :)
</section>

## Adding an Update

We mentioned in [part 3](/posts/phoenix-elm-3) that Elm has a *Model - Update - View* architecture. We've looked at the [View](/posts/phoenix-elm-3) and the [Model](/posts/phoenix-elm-4), so let's turn our attention now to the Update. The best way to get a handle on what the `update` function will need to do is by taking a look at its [type annotation](/posts/phoenix-elm-5).

```haskell
update : Msg -> Model -> Model
```

The `update` function will take two arguments, one of type Msg and one of type Model, and return a value of type Model. In actual fact it will look for a matching message handler in the `update` function for the message (Msg) sent to it. If it finds one it will call it, which will transform the current Model (or state) of the application into a brand new Model.

<div class="callout">
  It is important to note here that the <code>update</code> function does not <em>change</em> the current Model. It creates a whole new Model based on the current Model. The Model in Elm is immutable.
</div>

But what is a message? Well it is a [Union Type](http://elm-lang.org/docs/syntax#union-types) that lets us group a bunch of other types together. The end result is that we can then pattern match on those types in order to react to different "messages".

Let's look at an example,

```haskell
-- UPDATE

type Msg = Increment | Decrement

update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment -> model + 1
    Decrement -> model - 1
```

Let's assume that our Model is an Int that initializes to 0. We have two possible `Msg` types, `Increment` and `Decrement`. When the update function is called it is passed a Msg and the current Model. It will then pattern match on the given Msg's type to find a function to call. If the Msg type is `Increment` then a new Model will be produced by adding 1 to the current Model. If it is `Decrement` then 1 will be subtracted from the current Model instead.

From this we can see that the purpose of the `update` function, for now anyway, is to step the Model from one state to the next.

## Adding an update function

Let's update our Elm application so that we can toggle a Seat from available to occupied and vice versa.

1. Add the following to your *web/elm/SeatSaver.elm* file. It doesn't matter where you put it, but I typically stick the Update section between the Model and View sections.

    ```haskell
    -- UPDATE

    type Msg = Toggle Seat


    update : Msg -> Model -> Model
    update msg model =
      case msg of
        Toggle seatToToggle ->
          let
            updateSeat seatFromModel =
              if seatFromModel.seatNo == seatToToggle.seatNo then
                { seatFromModel | occupied = not seatFromModel.occupied }
              else seatFromModel
          in
            List.map updateSeat model
    ```

    OK, there's a lot going on here, so let's take it line by line. First of all we define a Msg called Toggle. The Toggle Msg will take an argument of type Seat. That is why we have `Toggle Seat`. We are not declaring two Msgs here, otherwise there would have been a `|` between them.

    In our `update` function we have a `case` statement that just has one matcher currently for our `Toggle` Msg. The message handler will use `List.map` (in the `in` block at the bottom) to call the `updateSeat` function for each seat in the model (remember our model is a List of Seat).

    The `updateSeat` function is defined in the `let` block. The `let` block enables us to define functions that can be used within the local scope. The `updateSeat` function checks to see if the seat passed into it `seatFromModel` has a seatNo that matches the seatNo of the `seatToToggle` passed into the Msg. If it matches, the function returns a new seat record with the occupied boolean flipped to the opposite value. If it doesn't match it just returns a new seat record with the same values as the existing `seatFromModel`.

    Phew! The upshot of this is that, when the `update` function is called with the Toggle message and a seat, it will return a new List with the given seat's occupied boolean flipped.


## Introducing Html.App

We now have our `update` function, but we're not using it anywhere. We could at this point start looking at Elm Signals and Mailboxes, at folding and mapping and merging, but let's not. Elm handily provides a wrapper around all of the necessary wiring required to have Msgs routed around our application into the Update. This wrapper is called Html.App.

1. Let's import it into our *web/elm/SeatSaver.elm* file.

    ```haskell
    import Html.App as Html
    ```

    The `as Html` part allows us to create an alias so that calls to Html.App.<function> can be done as Html.<function>. Don't worry, this doesn't overwrite any existing Html module functions and there are no name clashes between these two modules. This is the idiomatic way to import the `Html.App` module.

2. We need to change our `main` function to use the `beginnerProgram` function from the Html.App module. This takes as an argument a record with our init, update and view functions, does all the necessary wiring under the covers and returns `Program Never` values.

    <div class="callout">
      A <code>Program</code> in Elm is a way to package up an Elm program. You can find out more in the [Elm docs](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Platform#Program).

      The <code>Never</code> part just means that this operation can never fail. You can read [more on Never](http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Basics#Never) in the Elm docs.
    </div>

    ```haskell
    main : Program Never
    main =
      Html.beginnerProgram
        { model = init
        , update = update
        , view = view
        }
    ```

## Clicking on a seat

We now have our `beginnerProgram` set up, but it doesn't yet _do_ anything.

1. Let's change our view so that we can click on a seat in the browser and have that update the model using our Toggle action.

    ```haskell
    seatItem : Seat -> Html
    seatItem seat =
      li
        [ class "seat available"
        , onClick (Toggle seat)
        ]
        [ text (toString seat.seatNo) ]
    ```

    We've added an `onClick` function to our attributes, which takes the Msg to be sent, and the current seat, as its argument.

    <div class="callout">
      Our <code>Toggle</code> Msg needs to have the clicked Seat as an argument. However the <code>onClick</code> function can only accept one argument. So how do we get the Seat in there? We can do this in the same way as we would in maths, by denoting precedence of function execution with parentheses. When we write <code>onClick (Toggle seat)</code> what we are doing is creating a [partial function](https://wiki.haskell.org/Partial_functions) that binds the clicked seat to the Toggle function call. In other words, we create a Toggle function where we have already provided the Seat argument. This technique is known as [currying](https://en.wikipedia.org/wiki/Currying).
    </div>

2. We need to import the onClick event for this to work.

    ```haskell
    import Html.Events exposing (onClick)
    ```

3. We also need to change the type annotation of this function now. Before we added the onClick event we were passing out plain HTML strings. Now we are passing out HTML that can result in Messages being called. If you try to compile the file as it currently stands, you will get the following error:

    ![seatItem type error](/images/phoenix-elm/type_error.png)

    As before the error messages are very helpful. They are telling us that both of our View functions state that they will return values of type `Html String` when in fact they are now returning values of `Html Msg`.

    Change the type annotations as follows to enable the file to compile again:

    ```haskell
    view : Model -> Html Msg
    ```

    ```haskell
    seatItem : Seat -> Html Msg
    ```

4. When we click on a seat we create a Toggle Msg with the seat that was clicked as an argument. 'beginnerProgram` will handle things from here, picking the Msg up and routing it through the `update` function. This in turn will toggle the occupied flag of that seat.

5. Changing the occupied flag is all well and good, but we can't actually tell currently if that has happened or not. So that we get an indication that something has happened, let's change the style of the seat based on its occupied status.

    ```haskell
    seatItem : Seat -> Html Msg
    seatItem seat =
      let
        occupiedClass =
          if seat.occupied then "occupied" else "available"
      in
        li
          [ class ("seat " ++ occupiedClass)
          , onClick (Toggle seat)
          ]
          [ text (toString seat.seatNo) ]
    ```

    We're using a `let` block again to define a local function. `occupiedClass` will return "occupied" if the seat is occupied or "available" if it is not. We then use the `++` function to concatenate the result of calling `occupiedClass` with the existing class string.

3. Now, if you go to your browser, you should be able to click on the seats and see them turn from gray to green and back again!

    ![toggling a seat](/images/phoenix-elm/wNpuUF1fHn.gif)


## Summary

This has been a rather long and complex section of the tutorial, but we finally have something that we can interact with. This may seem like a lot of effort to set up something relatively simple, but the pay-offs come further down the line as we add more complexity.

We'll take a brief detour in [Part 7](/posts/phoenix-elm-7) to look at Signals. After that we can start to bring in Phoenix to bring our application to life.
