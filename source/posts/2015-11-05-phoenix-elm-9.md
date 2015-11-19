---
title: Phoenix with Elm - part 9
author: Alan Gardner
description: Creating a data API in Phoenix and then consuming in Elm over HTTP.
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>

## Introduction

This part of the tutorial is actually going to be a bit of a detour. We're going to fetch the initial data for our Elm application over HTTP from a data API that we'll create in our Phoenix application. However we're going to do this on a branch of the seat_saver repo (called *http* for reference), because we're ultimately going to prefer to use [Phoenix Channels](http://www.phoenixframework.org/docs/channels) for this instead.

This part of the tutorial is just to demonstrate how you could use HTTP should you want to. Feel free to skip this post if you'd rather just get stuck into using Channels though.


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
6. Elm is going to expect our field names to be in camel-case rather than snake-case. To keep things simple we'll just change the `seat_no` key to `seatNo` on line 14 of *web/views/seat_view.ex* and adjust our test on line 22 of *test/controllers/seat_controller_test.exs* to match.

    ```elixir
    # web/views/seat_view.ex
    def render("seat.json", %{seat: seat}) do
      %{id: seat.id,
        seatNo: seat.seat_no,
        occupied: seat.occupied}
    end

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
8. Fire up the Phoenix server (`iex -S mix phoenix.server` if you don't already have it running) and you should see the following at <http://localhost:4000/api/seats>

    ![Data API](/images/phoenix-elm/11.png)


## Fetching data in Elm via HTTP

As mentioned in [part 8](/posts/phoenix-elm-8), in order to do HTTP requests in Elm we need to use Effects.

1. We'll start by changing our `init` function so that it returns a tuple with an empty list for the Model and a function called `fetchSeats`, which we'll create in a minute, as an Effect.

    ```haskell
    init : (Model, Effects Action)
    init =
      ([], fetchSeats)
    ```

2. We'll now implement the `fetchSeats` function at the end of our *web/elm/SeatSaver.elm* file.

    ```haskell
    -- EFFECTS

    fetchSeats =
      Http.get decodeSeat "http://localhost:4000/api/seats"
        |> Task.toMaybe
        |> Task.map SetSeats
        |> Effects.task


    decodeSeat =
      let
        seat =
          Json.object2 (\seatNo occupied -> (Seat seatNo occupied))
            ("seatNo" := Json.int)
            ("occupied" := Json.bool)
      in
        Json.at ["data"] (Json.list seat)
    ```

    What we want to do here is the following:

    1. Make an HTTP request
    2. If the response is successful
      1. Parse the give JSON into a List of Seat records
      2. Build a Task that will call the `update` function with a SetSeats action
      3. Convert the Task into an Effects.Task that can be run by StartApp
    3. If the response was not successful



    There's a _lot_ going on here, so let's walk through it. Our `fetchSeats` function is going to generate an `Effects.task` that StartApp can use to perform an HTTP request when it calls it. It is important to note that we are not actually doing the HTTP request in this function, merely building an Effects.Task that will enable StartApp to perform the request when it handles the Effect.

    We then use the Elm |> operator to create a partial function that will be called once the HTTP request has been made.

    <div class="callout">
      Note the Elm's pipe operator is not quite the same an Elixir's. In Elixir <code>"some value" |> String.reverse |> String.upcase</code> is just syntactic sugar to make it easier to work with functions that have calls to other functions within their params. At compile time it is converted into <code>String.upcase(String.reverse("some value"))</code>.

      In Elm however the pipe operator is used to create partial functions through currying. In other words, <code>"some value" |> String.reverse |> String.upcase</code> will, in effect, call <code>String.reverse("some value")</code> first and curry <code>String.upcase</code> with the result.

      <!-- Needs more work! Ask Paul for help :) -->
    </div>

    When a response is received for the HTTP request, it will be passed to our `decodeSeat` function. The `decodeSeat` function will attempt to parse the response from JSON into a List of Seat records. The result of this is passed as the first argument to `Task.toMaybe`.

    A [Task](http://elm-lang.org/guide/reactivity#tasks) in Elm is used to describe an asynchronous operation that might fail, a perfect example of which is HTTP requests. When the Task is performed it will either succeed or fail. Elm forces you to handle that failure by returning one type for a successful result and another type for a failure result. This means that any function being called with the result cannot know in advance what the type of that result will be. In a statically typed language like Elm, this is a problem.

    One way of handling failure in Tasks is to defer handling the failure until you plan to handle the success. The `toMaybe` function does this by wrapping the result in a [Maybe](http://package.elm-lang.org/packages/elm-lang/core/2.1.0/Maybe). A Maybe is an [option type](https://en.wikipedia.org/wiki/Option_type). In this context a Maybe allows you say "This might be a List of Seat records, or it might not." More on this in a little bit.

    Once the result has been converted to a Task by the `Task.toMaybe` function it is then passed to `Task.map SetSeats`. This tells the Task we are building here to convert the result so far into a SetSeats Action with the result as its parameter. In other words, "once you've got the result of the HTTP request and parsed it into something Elm can use, call the SetSeats action passing in that result".

    Finally we convert the Task we've been building into an Effect by passing it to `Effects.task`. We can think of this as a job being prepared and being put on a queue for StartApp to run.

3. In order for that code to work we need to add the required imports:

    ```haskell
    import Http
    import Json.Decode as Json exposing ((:=))
    ```

4. then install them:

    ```shell
    cd web/elm
    elm package install evancz/elm-http -y
    cd ../..
    ```

5. and then add the `SetSeats` Action to our `update` function.

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

    Now we can see how we can use the Maybe we generated in step 1. If the Task completes successfully we will have a List of Seat records (aka a Model). If it fails then we won't. As such the type signature for this Action is `SetSeats (Maybe Model)`. In other words the argument to SeatSeats may be a Model, or it may not.

    In our case statement we then use the `Maybe.withDefault` function to say "if the argument I'm given is anything other than a value of type Model return the current model, otherwise return the given argument". As such `SetSeats` will return a NoOp (i.e. `(model, Effects.none)`) if the Task failed or it will replace the existing Model with the List of Seat records if we successfully parsed one from the HTTP response (i.e. `(seats, Effects.none)`).

    In this way Elm forces us to handle both success and failure outcomes and protects us from runtime errors.

6. Visiting <http://localhost:4000> in our browser will still display the seats as before, but now the initial data is coming from our data API. As such we should always see the first two seats being displayed as occupied, even on a refresh (you may also see a slight delay before all the seats are displayed).

    ![Data API](/images/phoenix-elm/12.png)


## Summary

So that's how we fetch data via HTTP in Elm. However, as we mentioned at the start, this was just a brief detour. We'll rewind this step and use Phoenix's Channels instead in part 10, which should be out soon.

We'll be announcing the rest of the tutorial on Twitter (@cultivatehq using hashtag #phoenixelm), so keep an eye out for updates.
