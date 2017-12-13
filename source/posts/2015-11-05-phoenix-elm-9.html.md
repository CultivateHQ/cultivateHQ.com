---
title: Phoenix with Elm - part 9
author: Alan Gardner
description: This part of the tutorial is actually going to be a bit of a detour. We're going to fetch the initial data for our Elm application over HTTP from a data API that we'll create in our Phoenix application.
tags: elixir, elm
---

<section class="callout">
  <p>I gave <a href="http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm">a talk at ElixirConf 2015</a> on combining the <a href="http://www.phoenixframework.org/">Phoenix web framework</a> with the <a href="http://elm-lang.org">Elm programming language</a>. This is the tutorial that was referred to in that talk.</p>

  <p>The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.</p>

  <p>There is an <a href="https://github.com/CultivateHQ/seat_saver-017">accompanying repo</a> for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.</p>
</section>

## Introduction

This part of the tutorial is actually going to be a bit of a detour. We're going to fetch the initial data for our Elm application over HTTP from a data API that we'll create in our Phoenix application. However we're going to do this on a branch of the [seat_saver repo](https://github.com/CultivateHQ/seat_saver) (called *http* for reference), because we're ultimately going to prefer to use [Phoenix Channels](http://www.phoenixframework.org/docs/channels) for this instead. If you're using version control you may wish to do this part as a branch as well to make it easier to revert at the start of the next part of the tutorial.


## Creating a simple data API in Phoenix

Rather than hard-wire the seats in the `init` function we want to fetch them from a database via our Phoenix application. We'll start by creating a simple data API in the Phoenix application to serve that data.

1. We can use the built-in Phoenix mix tasks to build a seats endpoint. Open a terminal and use the following command to generate an endpoint scaffold.

    ```shell
    mix phoenix.gen.json Seat seats seat_no:integer occupied:boolean
    ```

2. Now follow the instructions mix gives you and make the following adjustment to the *web/router.ex* file

    ```elixir
    defmodule SeatSaver.Router do
      use SeatSaver.Web, :router

      ...

      # Other scopes may use custom stacks.
      scope "/api", SeatSaver do
        pipe_through :api

        resources "/seats", SeatController, except: [:new, :edit]
      end
    end
    ```

3. Back in the terminal, migrate the database and run the tests to make sure that nothing is broken (you should have 14 passing tests).

    ```shell
    mix ecto.migrate
    mix test
    ```

4. Now we need to add some seat data. We can use the *priv/repo/seeds.exs* file for this. Add the following to the end of that file (note that the first two seats are occupied but the rest are not):

    ```elixir
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 1, occupied: true})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 2, occupied: true})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 3, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 4, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 5, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 6, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 7, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 8, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 9, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 10, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 11, occupied: false})
    SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 12, occupied: false})
    ```

5. Run `mix run priv/repo/seeds.exs` to apply the seeds.
6. Elm is going to expect our field names to be in camel-case rather than snake-case. To keep things simple we'll just change the `seat_no` key to `seatNo` on line 14 of *web/views/seat_view.ex*

    ```elixir
    # web/views/seat_view.ex
    def render("seat.json", %{seat: seat}) do
      %{id: seat.id,
        seatNo: seat.seat_no,
        occupied: seat.occupied}
    end
    ```

    and adjust our test on line 21 of *test/controllers/seat_controller_test.exs* to match.

    ```elixir
    # test/controllers/seat_controller_text.exs
    test "shows chosen resource", %{conn: conn} do
      seat = Repo.insert! %Seat{}
      conn = get conn, seat_path(conn, :show, seat)
      assert json_response(conn, 200)["data"] == %{"id" => seat.id,
        "seatNo" => seat.seat_no,
        "occupied" => seat.occupied}
    end
    ```

7. We can run the tests again using `mix test` to ensure that we haven't broken anything.
8. Restart your Phoenix server (CTRL-C twice to shutdown and then `iex -S mix phoenix.server` to start again) and you should see the following at <http://localhost:4000/api/seats>

    ![Data API](/images/phoenix-elm/11.png)

I'm using a Chrome extension called [JSONView](https://chrome.google.com/webstore/detail/jsonview/chklaanhfefbnpoihckbnefhakgolnmc) so your output might not look _exactly_ the same.

## Fetching data in Elm via HTTP

As mentioned in [part 8](/posts/phoenix-elm-8), in order to do HTTP requests in Elm we need to use Effects.

We'll start by changing our `init` function so that it returns a tuple with an empty list for the Model and a function called `fetchSeats`, which we'll create in a minute, as an Effect.

```haskell
init : (Model, Effects Action)
init =
  ([], fetchSeats)
```

This initializes our Model to be an empty List (remember our Model is a List of Seat records) and then calls a function `fetchSeats`. The `fetchSeats` function will return an Effects Action that StartApp will subsequently call in order to make the HTTP request that will, hopefully, provide the seat data from our data API.


### Building an Effect

We'll now implement the `fetchSeats` function at the end of our *web/elm/SeatSaver.elm* file.

```haskell
-- EFFECTS

fetchSeats: Effects Action
fetchSeats =
  Http.get decodeSeats "http://localhost:4000/api/seats"
    |> Task.toMaybe
    |> Task.map SetSeats
    |> Effects.task


decodeSeats: Json.Decoder Model
decodeSeats =
  let
    seat =
      Json.object2 (\seatNo occupied -> (Seat seatNo occupied))
        ("seatNo" := Json.int)
        ("occupied" := Json.bool)
  in
    Json.at ["data"] (Json.list seat)
```

There's a _lot_ going on here, so let's walk through it. The purpose of our `fetchSeats` function is to create an Effects Action that StartApp can use to make an HTTP request to our data API. We also need to let StartApp know what we want it to do when we get a response. If it is successful, we want to parse the resulting JSON into a List of Seat records and then replace the existing Model, an empty List, with that List of Seat records. If it fails for any reason, including issues with parsing the JSON, we want to be able to handle that error. We can think of this as a job being prepared and put on a queue for StartApp to run.

We are using the Elm `|>` function to make it easier to see the process flow here. `|>` is just an alias for function application, and allows us to write our function inside out. The result of calling `Http.get ...` gets passed to `Task.toMaybe`, which in turn gets passed to `Task.map ...`, which then gets passed to `Effects.task`.

<div class="callout">
  <p>
    Note that Elm's <code>|></code> function is not quite the same as Elixir's pipe operator, but they are close enough in purpose for it not to really matter. The only practical difference is that, in Elixir, the value being piped is given as the first argument to the subsequent function whereas, in Elm, it is the last argument.
  </p>

  <p>
    This is because in Elm the <code>|></code> function is actually creating <a href="https://wiki.haskell.org/Partial_functions">partial functions</a>.
  </p>
</div>

So let's step through the `fetchSeats` function.

1. `Http.get decodeSeat "http://localhost:4000/api/seats"` creates a function that can be called to perform the HTTP request. Note that it is not called here. It will be called by StartApp when the Effects Action generated by the `fetchSeats` function is run. As the first argument we supply a JSON decoder that will be used to parse the body of a successful response. We define that decoder in the `decodeSeats` function. You can read more about the JSON decoder on the [Elm docs](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Json-Decode).

2. If we look at the type annotation for [Http.get](http://package.elm-lang.org/packages/evancz/elm-http/3.0.0/Http#get) we can see that what we are returned is `Task Error value` This means that we will get a `Task` that will either return a value of type `Error` or a `value` of some type other than `Error`. In Elm a [Task](http://elm-lang.org/guide/reactivity#tasks) is an asynchronous operation that might fail, a perfect example of which is an HTTP request. In our case, when the Task is performed, it will either fail with a type Error, or succeed with the type returned by our JSON decoder, i.e. the type Model.

    In this way Elm uses the type system to force us to handle the failure case by returning one type for a successful result and another type for a failure result. This means that any function being called with the result of this HTTP request cannot know in advance what the type of that result will be. The `Task.toMaybe` function lets us handle this uncertainty by wrapping the result in a [Maybe](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Maybe). A Maybe is an [option type](https://en.wikipedia.org/wiki/Option_type) that enables us to say "This might be a List of Seat records, or it might not." More on this when we come to handle this in the `update` function.

3. Speaking of the `update` function, we already know that this is the only place where we can make changes to the Model, and that is exactly what we need to do here. We want to replace the existing Model, which is currently initialized to an empty List, with the Model we receive from our JSON decoder. We do this by mapping our existing Task, using `Task.map`, to one that takes an Action to be performed, in our case the `SetSeats` Action, and any arguments for that Action, i.e. the Maybe-wrapped result from `Task.toMaybe`.

4. Finally, in order for StartApp to run the task, we need to wrap it in an Effects Action. The `Effects.task` function does this. The result is an Effects Action that can be returned to our `init` function and used by StartApp. When StartApp runs this it will result in a call to the `update` function with a SetSeats Action that has our new Model derived from the call to the data API. In other words, we are telling Elm "once you've got the result of the HTTP request and parsed it into something you can use, call the SetSeats action passing in that result".

    Pretty straightforward, right? ;)

### Wiring it all together

1. In order for that code to work we need to add the required imports:

    ```haskell
    import Http
    import Json.Decode as Json exposing ((:=))
    ```

2. then install them:

    ```shell
    cd web/elm
    elm package install evancz/elm-http -y
    cd ../..
    ```

3. and then add the `SetSeats` Action to our `update` function.

    ```haskell
    -- UPDATE

    type Action = Toggle Seat | SetSeats (Maybe Model)


    update : Action -> Model -> (Model, Effects Action)
    update action model =
      case action of
        ...
        SetSeats seats ->
          let
            newModel = Maybe.withDefault model seats
          in
            (newModel, Effects.none)
    ```

    Now we can see how we can use the Maybe we introduced in the `fetchSeats` function. If the Task completes successfully we will have a List of Seat records (aka a Model). If it fails then we won't. As such the type annotation for this Action is `SetSeats (Maybe Model)`. In other words the argument to SeatSeats may be a Model, or it may not.

    In our case statement we then use the `Maybe.withDefault` function to say "if the argument I'm given is anything other than a value of type Model return the current model, otherwise return the given argument". As such, `SetSeats` will return a NoOp (i.e. `(model, Effects.none)`) if the Task failed or it will replace the existing Model with the List of Seat records if we successfully parsed one from the HTTP response (i.e. `(seats, Effects.none)`).

    In this way Elm forces us to handle both success and failure outcomes and protects us from runtime errors.

6. Visiting <http://localhost:4000> in our browser will still display the seats as before, but now the initial data is coming from our data API. We should always see the first two seats being displayed as occupied, even on a refresh (you may also see a slight delay before all the seats are displayed).

    ![Data API](/images/phoenix-elm/12.png)


## Summary

So that's how we fetch data via HTTP in Elm. Elm makes a lot of hard things easy for us. Unfortunately HTTP is one of the "easy" things it makes, at least initially, hard. There is good reason for this though. Elm is forcing us to work in a particular way so that we can protect ourselves from runtime exceptions in our applications.

This is the part of the tutorial that I've found the hardest to explain, mostly because I'm fairly new to a few of these concepts myself. If you'd like to read more on the subject, example 5 in the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial/) is the best place to start.

As we mentioned at the start of this post, this was just a brief detour. We'll rewind this step and use Phoenix's Channels instead in [part 10](/posts/phoenix-elm-10).
