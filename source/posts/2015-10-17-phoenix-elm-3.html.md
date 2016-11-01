---
title: Phoenix with Elm - part 3
author: Alan Gardner
description: Adding a simple View to the Elm application.
tags: alan
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver-017) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>


## Adding a simple View

OK so now we have a basic Phoenix application into which we've embedded a simple Elm application. Let's start to flesh out our Elm application a little. Elm has a *Model - Update - View* architecture. Let's take a look at what that means:

1. *Model* Elm keeps its state in one single place, the Model. The Model is immutable.
2. *Update* Elm has an update function that steps the model from one state to the next. It receives a Message (detailing a task to be performed) and the current model, and then swaps out the current model for a new one.
3. *View* A representation of the current model that can be displayed to the user, be that HTML, SVG or some other visual representation.

We'll start with the View. We want to create a simple representation of an airplane with seats that we can book. Something like this.

![seat saver all available](/images/phoenix-elm/6.png)

It's not the most accurate rendition, but it's just enough for us to demonstrate everything we need to.

<div class="callout">
  You can grab the assets from the <a href="https://github.com/CultivateHQ/seat_saver-017">SeatSaver repo</a>. The necessary styles are in <em>web/static/css/seatsaver.css</em> and the required image is in <em>web/static/assets/images/seat.png</em>.
</div>

1. Open *web/elm/SeatSaver.elm*.
2. Now we can create a View function. A View function is just an ordinary function that returns HTML. That is to say that its return value must be of the type `Html`. Elm is a statically typed language, so every value has a type. Luckily for us Elm also uses type inference so that we don't typically have to declare what type a value has. We'll explain more about types as we go through the tutorial, covering what we need to know when we need to know it. For now, change the `main` function as follows:

    ```haskell
    main =
      view


    -- VIEW

    view =
      Html.text "Woo hoo, I'm in a View"
    ```

    A few other things to note here are that `--VIEW` is just a standard Elm comment and has no special value. We're going to put all of our Elm code in one file in this tutorial to keep it easier to see what's going on. These comments will help us to find things as we add more code.

    Also, in Elm, we idiomatically place two new lines between function definitions.

4. If you check your browser now (start the server with `iex -S mix phoenix.server` if it's not already running) you should see something like this.

    ![woo hoo I'm in a View](/images/phoenix-elm/7.png)

What we actually want to display here is a bunch of seats, but in order to do that we need to know what seat data is going to look like. For that we need to introduce the Model. Let's do that next.


## Summary

We now have a simple view for our Elm application. In [Part 4](/posts/phoenix-elm-4) we'll introduce a Model and expand our View.
