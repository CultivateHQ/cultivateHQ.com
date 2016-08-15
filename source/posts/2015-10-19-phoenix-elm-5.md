---
title: Phoenix with Elm - part 5
author: Alan Gardner
description: So far Elm has been happily inferring the types that we are using in our application, and it will continue to do so. However let's take a moment to look at how we can make it more obvious to others who might read our code what types we are expecting.
tags: alan
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver-017) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>

<section class="callout">
  Thanks to @tcoopman for some corrections in this post. :)
</section>

## Type annotations

So far Elm has been happily inferring the types that we are using in our application, and it will continue to do so. However let's take a moment to look at how we can make it more obvious to others who might read our code what types we are expecting. We can do this by using [*type annotations*](http://guide.elm-lang.org/types/).

Type annotations are optional in Elm, but they help us, and others that read our code, to better see what is going on. They also allow us to specify the contract for our functions.

A type annotation goes on the line before a function definition and consists of the name of that function, followed by a colon, followed by a list of one or more types. The list of types is separated by `->`. The very last type in this list is always the return type. Elm functions always return one value, so there is always one return type. The other types refer to the type of each parameter being passed into the function.

For example,

```haskell
samesies : Int -> String -> Bool
samesies number word =
  (toString number) == word
```

The `samesies` function takes two arguments, one of type `Int` and one of type `String` and returns a value of type `Bool`. Its type annotation is
`samesies : Int -> String -> Bool`.

Let's add type annotations to our existing functions.

1. Add the following above the `main` function:

    ```haskell
    main : Html.Html String
    ```

    Our main function takes no arguments and returns an Html String, i.e. collection of HTML represented as String values.

    We're having to prefix the Html type with `Html.` here because the `Html` function is defined in the `Html` library. To save us from having to do that each time, let's tweak the Html import so we use the `(..)` syntax instead rather than naming each function that we want to use.

    ```haskell
    import Html exposing (..)
    ```

    Now we can change our `main` function's type annotation to

    ```haskell
    main : Html String
    ```

2. The next function is the `init` function (we don't have to add type annotations to type definitions as they already state their expected types). The `init` function takes no arguments and returns a Model.

    ```haskell
    init : Model
    ```

3. The `view` function takes a Model as an argument and returns an Html String.

    ```haskell
    view : Model -> Html String
    ```

4. Last but not least, the `seatItem` function takes a Seat as an argument and returns an Html String.

    ```haskell
    seatItem : Seat -> Html String
    ```

5. The end result should look like this:

    ```haskell
    module SeatSaver exposing (..)

    import Html exposing (..)
    import Html.Attributes exposing (class)


    main : Html String
    main =
      view init


    -- MODEL

    type alias Seat =
      { seatNo : Int
      , occupied : Bool
      }


    type alias Model =
      List Seat


    init : Model
    init =
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


    -- VIEW

    view : Model -> Html String
    view model =
      ul [ class "seats" ] (List.map seatItem model)

    seatItem : Seat -> Html String
    seatItem seat =
      li [ class "seat available" ] [ text (toString seat.seatNo) ]
    ```

6. Checking the browser again, nothing should have changed.

  ![seat list](/images/phoenix-elm/8.png)

Type annotations, as mentioned above, are optional. Elm will infer our types for us. However it is good to get into the habit of using them. I find that they help me to figure out what a function should be doing. They also help to catch errors when defining functions in case we accidentally use a type that is not the one we were intending.

For example, let's change our `view` function to the following:

```haskell
view : Model -> Html String
view model =
  List.map seatItem model
```

When you try to compile this, you will see the following error in your terminal window where the server is running:

![type mismatch](/images/phoenix-elm/error_page_new.png)

Elm has fantastic error messages. Here it quite clearly tells us that *"The type annotation for `view` does not match its definition."*. What this is telling us is that the `view` function is expected to return a value of type `Html String` but has returned a value of `List Html` instead.

Returning the `view` function to its original definition will fix this error.

```haskell
view : Model -> Html String
view model =
  ul [ class "seats" ] (List.map seatItem model)
```


## Summary

Now that we know more about Type Annotations it will be easier for us to understand the `update` function. We'll look at that in [Part 6](/posts/phoenix-elm-6).
