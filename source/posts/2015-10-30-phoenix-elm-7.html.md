---
title: Phoenix with Elm - part 7
author: Alan Gardner
description: Let's take a moment to talk about what is happening behind the scenes in our Elm application.
tags: elixir, elm
---

<section class="callout">
  <p>I gave <a href="http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm">a talk at ElixirConf 2015</a> on combining the <a href="http://www.phoenixframework.org/">Phoenix web framework</a> with the <a href="http://elm-lang.org">Elm programming language</a>. This is the tutorial that was referred to in that talk.</p>

  <p>The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.</p>

  <p>There is an <a href="https://github.com/CultivateHQ/seat_saver-017">accompanying repo</a> for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.</p>
</section>


## Signals

Let's take a moment to talk about what is happening behind the scenes in our Elm application.

### What is a Signal?

In Elm a [Signal](http://elm-lang.org/guide/reactivity#signals) is a way of routing messages around the application. They are initialized with a value and always have a value from that point onwards. The values on a Signal are immutable, but the Signals themselves can be thought of as being mutable because their values can be changed. I'll not spend much time explaining what Signals actually are here. I found the [Pragmatic Studio course on Elm Signals](https://pragmaticstudio.com/elm-signals) to be the best place to get to grips with Signals, and the [Elm Reactivity tutorial](http://elm-lang.org/guide/reactivity) is also a great resource.

### Initializing our application

When we initialize our application we are actually putting an initial value onto a Signal that holds values of type Model. Under the covers StartApp then wires things together so that our View gets passed this initial value and then converts it into an initial value on a Signal of values of type Html. In other words we return the HTML that represents the current state of our application.

The Signal digram below demonstrates this.

![signal - tutorial 1](/images/phoenix-elm/signals_1.png)

### Clicking on a seat

Let's now take a look at what happens when we click on a seat in our browser.

1. Elm captures the mouse click and converts it into a value on a Signal of type () (called _unit_).

    <div class="callout">
      A unit type can be thought of as a type that has no value. We use it to represent a mouse click because we only care that a mouse click has happened, there is no <em>value</em> as such associated with that action.
    </div>

    ![signal - tutorial 2](/images/phoenix-elm/signals_2.png)

2. StartApp needs to have an Action to pass to our `update` function in order to do anything. We use the `onClick` function supplied by the `Html.Events` package to capture any values added to the Signal () and convert them into Toggle Actions curried with the seat that was clicked. This Action is added by StartApp as a value onto a Signal of type Action.

    <div class="callout">
      Please note that the Action is not executed at this point, it is just added to the Signal. StartApp will route any Actions to the <code>update</code> function for us, so it does <em>look</em> like this is what happens.
    </div>

    ![signal - tutorial 3](/images/phoenix-elm/signals_3.png)

3. Once the `update` function is called with the Toggle Action, it changes the model to be a new List of Seat that has the occupied flag toggled for the seat that matches the seat we clicked (and subsequently curried our Toggle Action with).

    ![signal - tutorial 4](/images/phoenix-elm/signals_4.png)

4. Now that the Model has been updated, the View will update to reflect the new Model.

    ![signal - tutorial 5](/images/phoenix-elm/signals_5.png)


### Summary

And there we have it. We'll use signal diagrams throughout this tutorial as they're a good way to understand what is going on in the workings of our application. Signals are one of the concepts that I found quite hard to parse at first, but stick with them (and look at the resources mentioned above) and they'll start to click (pun unavoided) after a while.

Next up in [part 8](/posts/phoenix-elm-8) we'll upgrade to the more advanced StartApp so that we can lay the foundations for talking to our Phoenix application.
