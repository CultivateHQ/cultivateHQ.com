---
title: Phoenix with Elm - part 2
author: Alan Gardner
description: Getting Phoenix and Elm to play together.
---

<section class="callout">
  I gave [a talk at ElixirConf 2015](http://confreaks.tv/videos/elixirconf2015-phoenix-with-elm) on combining the [Phoenix web framework](http://www.phoenixframework.org/) with the [Elm programming language](http://elm-lang.org). This is the tutorial that was referred to in that talk.

  The tutorial walks through the creation of a very basic seat saving application, like one you'd use when booking a flight for example. The application will do just enough to demonstrate the mechanisms for getting the two technologies talking to each other.

  There is an [accompanying repo](https://github.com/CultivateHQ/seat_saver) for this tutorial. Each of the numbered steps has an associated commit so that you can just look at the diffs if you'd rather not read through the whole thing.
</section>


## Getting Elm and Phoenix to play together

Now that we have a basic Phoenix application in place, let's add a basic Elm application into the mix. There are several ways that we can combine Phoenix with Elm:

1. Keep the two applications completely separate. This is probably the easiest way to go.

    ![uncombined](/images/phoenix-elm/2.png)

    We compile Elm to JavaScript using the `elm make` command and just run it in a browser. We can then make use of HTTP or similar to talk between the two.

2. Seeing as the Elm application compiles down to JavaScript we can just vendor it into our Phoenix application.

    ![vendored](/images/phoenix-elm/3.png)

    Compiling our Elm application into *web/static/vendor* will ensure that the Brunch pipeline picks it up when building our Phoenix application's JavaScript. You can put your Elm application's JavaScript anywhere within your Phoenix project as long as you tell Brunch where to find it. Another reason that I am placing it into *web/static/vendor* is that Elm builds to ES5 JavaScript and Brunch is setup by default not to transpile files in *web/static/vendor*.

3. The third way, and the way that we will be using in this tutorial, is to embed Elm in your Phoenix application.

    ![embedded](/images/phoenix-elm/4.png)

    By embedding our Elm application into our Phoenix application we can take advantage of the existing Brunch pipeline to first compile our Elm application into a JavaScript file, and then to have the resulting JavaScript file added to the existing build pipeline so that it is available for our Phoenix application. This has the added bonus of enabling livereload every time you make a change in your Elm application files.

### Adding Elm into Phoenix

Let's start by adding an Elm application into our Phoenix application.

1. Shutdown the Phoenix server (Ctrl+c twice) so that Brunch doesn't build whilst we're setting things up.

    <div class="callout">
      If you forget to close the server you may find yourself with an <em>elm-stuff</em> folder and <em>elm-package.json</em> file in the root of your Phoenix project. Just delete these and carry on with the instructions below.
    </div>

2. In the terminal, at the root of the *seat_saver* project we just created, do the following:

    ```shell
    # create a folder for our Elm project inside the web folder
    mkdir web/elm
    cd web/elm

    # install the core and html Elm packages (leave off the -y if you want to see what's happening)
    elm package install -y
    elm package install evancz/elm-html -y
    ```

3. Create a file called *SeatSaver.elm* in the *web/elm* folder and add the following:

    ```haskell
    module SeatSaver where

    import Html

    main =
      Html.text "Hello from Elm"
    ```

    This creates a new Elm module called `SeatSaver` and then imports the `Html` library so that we can use its functions. Every Elm application must have a `main` function that acts as its starting point. In our `main` function we call out to the `text` function in the `Html` library, passing it a string. This will result in that string being written out to the screen when the Elm application is run in a browser.

### Building with Brunch

Now let's set up Brunch to automatically build the Elm file for us whenever we save changes to it.

Brunch is an HTML5 build tool sort of like Grunt or Gulp. We're going to use it to compile our Elm application into JavaScript and then package it up with the rest of our application's JavaScript. We're using Brunch because it is included by default with Phoenix. If you are not familiar with Brunch you should still be able to follow along with the instructions below. However, if you want to know more, the [Brunch Guide](https://github.com/brunch/brunch-guide#readme) is the best place to start.

1. Add [elm-brunch](https://github.com/madsflensted/elm-brunch) to your *package.json* directly after the `"brunch": <version>` line. Brunch runs plugins in the order in which they are found within the *package.json* file, so we put the `elm-brunch` plugin right at the top to ensure that the JavaScript resulting from the Elm compilation is available before any of the other JavaScript plugins start their tasks.

    ```javascript
    // package.json
    {
      ...
      "dependencies": {
        "brunch": "^1.8.5",
        "elm-brunch": "^0.3.0",
        "babel-brunch": "^5.1.1",
        ...
      }
    }
    ```

2. Return to the project root folder `cd ../..` and run `npm install`.
3. Edit your *brunch-config.json* file as follows, adding our Elm file into the watched list so that live reload will fire after any changes and making sure that `elmBrunch` is the first plugin:

    ```javascript
    // brunch-config.json
    {
      ...
      paths: {
        watched: [
          ...
          "test/static",
          "web/elm/SeatSaver.elm"
        ],
        ...
      },

      plugins: {
        elmBrunch: {
          elmFolder: 'web/elm',
          mainModules: ['SeatSaver.elm'],
          outputFolder: '../static/vendor'
        },
        ...
      },
      ...
    }
    ```

### Hooking up to the frontend

Now we need to adjust our Phoenix application to display the HTML output by the Elm application.

1. Replace *web/templates/page/index.html.eex* with the following:

    ```html
    <div id="elm-main"></div>
    ```

2. By making this change we have broken one of our tests. To keep it passing for now, let's make a small tweak to *test/controllers/page_controller_test.exs*.

    ```elixir
    test "GET /" do
      conn = get conn(), "/"
      assert html_response(conn, 200) =~ "<div id=\"elm-main\"></div>"
    end
    ```

3. Now we can hook up our Elm application by adding the following to the bottom of our *web/static/js/app.js* file:

    ```javascript
    ...
    var elmDiv = document.getElementById('elm-main')
      , elmApp = Elm.embed(Elm.SeatSaver, elmDiv);
    ```

    This grabs the `div` we just set up by its ID and then calls `Elm.embed` passing in the name of our module `Elm.SeatSaver` and the div that we just captured.

    <div class="callout">
      <code>Elm.embed</code> is not the only way to work with an Elm application. We could have avoided using an element to embed the application into by calling <code>Elm.fullscreen(Elm.SeatSaver)</code> instead.
    </div>

4. In order to keep things easier to see, let's also change the *web/templates/layout/app.html.eex*

    ```erb
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="">
        <meta name="author" content="">

        <title>Hello Phoenix!</title>
        <link rel="stylesheet" href="<%= static_path(@conn, "/css/app.css") %>">
      </head>

      <body>
        <div class="container" role="main">

          <%= @inner %>

        </div> <!-- /container -->
        <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
      </body>
    </html>
    ```

5. Firing up the Phoenix server again should build the Elm file and output the JavaScript to *web/static/vendor/seatsaver.js*, which will in turn get compiled into *priv/static/js/app.js* (providing we made no further changes to *brunch-config.json*).

    ```shell
    iex -S mix phoenix.server
    ```

6. If you point your browser to [http://localhost:4000](http://localhost:4000) now you should see something like this:

    ![Phoenix with Elm](/images/phoenix-elm/5.png)


## Summary

We now have a basic Phoenix application setup and the beginnings of an Elm application embedded inside it. In [Part 3](/posts/phoenix-elm-3) we'll start building our Elm application into something a bit more useful.
