---
title:  Putting an Elm in your Phoenix
author: Alan Gardner
---

> I've recently been playing around, with [Phoenix](http://phoenixframework.org) and [Elm](http://elm-lang.org). I'm really enjoying using both and so I thought I would see how easy it would be to combine the two, with Phoenix serving a data API and Elm consuming it.
> This is Part 3 in a series of 4 posts. In [Part 1](#part_1) we walked through setting up a basic Phoenix data API. In [Part 2](#part_2) we walked through setting up a basic Elm client that consumed the data from that API. In Part 3 we will walk through combining the Phoenix and Elm projects together. Finally, in [Part 4](part_4), we will add support for Phoenix channels.


## What we built

We built a really simple Contact Manager tool called ConMan. So simple in fact that ConMan just fetches a single contact from our Phoenix data API and displays it using Elm. Whilst this might seem too simple, it's enough to see all the moving parts of Phoenix and Elm that we need to for this exercise.


## Up and running

If you want a step-by-step tutorial on how the Phoenix data API was built then you can follow along with [Part 1](#part_1).

If you want a step-by-step tutorial on how the Elm client application was built then you can follow along with [Part 2](#part_2).

If you'd rather not go through the steps, you can get to the current state of play by opening a terminal and doing as follows:

```bash
mkdir conman && cd conman

# elm
git clone git@github.com:cultivate/conman_ui.git

# phoenix
git clone git@github.com:cultivate/conman_data.git
cd conman_data
iex -S min phoenix.server
```

You should now be able to open the `conman/conman_ui/index.html` file in your browser to see the application as is.


## Introduction

One way or another you should now have a Phoenix data API and an Elm client that reads data from that API. We're going to take a look at three different ways in which we can combine our Phoenix and Elm projects.

1. **Independently** - the Phoenix and Elm apps will exist as separate codebases and will be run independently.
2. **Inserted** - the Phoenix and Elm apps will exist as separate codebases, but the JavaScript resulting from compiling the Elm app will be manually inserted into the Phoenix app and run from there.
3. **Embedded** - the Phoenix and Elm apps will exist as a single codebase. The Elm app will be embedded into the Brunch workflow so that any changes to the Elm code automatically compiles it and the resulting JavaScript is then immediately available to the app as a whole.


### 1. Running the two apps independently

The first way is to work with them as separate apps entirely. This is what we have just now without doing any extra work. If you open `conman/conman_ui/index.html` in your browser you will see that we are fetching a contact by its ID from the data API and displaying it to the user.

<TODO insert image >

This approach works well and gives you a great separation of concerns. However if the two are really two parts of the one application, and neither have much function without the other, you could argue that having them in separate version controlled projects is not ideal. To be clear, _I'm not advising one way or the other_, I haven't yet made up my mind how best to run these two technologies together, and I suspect that the architecture would change from project to project. However, let's look at two ways in which our Elm application can live inside our Phoenix application.


### 2. Using the Elm generated JavaScript within the Phoenix app

The first way in which we can combine the two is also the simplest. We just vendor the JavaScript file that is built by Elm. You can either compile directly to your Phoenix project's `web/static/vendor` folder, or compile and then manually copy the resulting JavaScript file over. In order to use this file on the site we'll need to make a slight tweak to the Phoenix application.

1. Change the `web/templates/layout/app.html.eex` as follows.

  ```html.eex
  <body>
    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
    <script>
      var app = Elm.fullscreen(Elm.ConMan);
    </script>
  </body>
  ```

2. Now copy the `conman.js` file over from the Elm app to `web/static/vendor` (if you haven't already) and point your browser at [http://localhost:4000](http://localhost:4000). You should see the contact appearing as before (albeit with some Phoenix default styling added in).

  <TODO insert image https://www.dropbox.com/s/p0daix3th3muvc5/Screenshot%202015-08-27%2014.38.38.png?dl=0 >

3. We can safely take the CORS Plug that we added in [Part 1](#part_1) out now if we want to.

This method could be seen to give us the best of both worlds. We still have a clear line of separation between the two apps, but the result of building the Elm application is embedded in the Phoenix application so the project will work for anyone getting our application from version control without them necessarily having to also get the Elm application code.

On the other hand it could be see to be the worst of both worlds, we still have to keep two version controlled projects and anyone working with the front end is going to have to know that the JavaScript must be compiled from the Elm application.

The third way allows us to embed the whole Elm application inside our Phoenix application and even hook it into the Phoenix Brunch pipeline.


### 3. Embedding the Elm app inside the Phoenix app

In order to add Elm to the existing Brunch pipeline that Phoenix has, we can use the [Elm Brunch Plugin](https://github.com/madsflensted/elm-brunch). Let's set that up first.

> CAVEAT: you might it better to stop the Phoenix server at this point. If Elm Brunch is not setup properly you can find yourself with an `elm-stuff` folder and `elm-config.json` in the root of your Phoenix project. If that does happen, simply deleting them and fixing the Elm Brunch config should get things back on track.

1. All that Brunch needs in order to know to run a plugin is to add it to our `package.json` as a dependency. Add it before the `javascript-brunch` line as these will get called in order by Brunch.

  ```json
  {
    "repository": {
    },
    "dependencies": {
      ...
      "elm-brunch": "^0.3.0",
      "javascript-brunch": ">= 1.0 < 1.8",
      ...
    }
  }
  ```

2. Now run `npm install` in the root of your Phoenix project to install the plugin.
3. We can now configure the plugin to work with our app inside the `brunch-config.js`. Change the plugins section so that it looks similar to the following.

  ```json
  // Configure your plugins
  plugins: {
    elmBrunch: {
      elmFolder: 'web/elm',
      mainModules: ['ConMan.elm'],
      outputFolder: '../static/vendor'
    },

    ...
  },
  ```

4. And then change your watched list to look like the following.

  ```json
  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["deps/phoenix/web/static",
              "deps/phoenix_html/web/static",
              "web/static", "test/static",
              "web/elm/ConMan.elm", "web/elm/Contact.elm"],

    // Where to compile files to
    public: "priv/static"
  },
  ```

5. As you can probably tell from the configuration we just added, we're going to copy our Elm project into `web/elm`. Before we do this we want to make sure that Brunch isn't going to pick up any JavaScript that might be in our `web/elm` folder. We do this by adjusting the files section to look like the below.

  ```json
  files: {
    javascripts: {
      joinTo: {
        'js/app.js': /^(web\/static)/
      }
    },
    ...
  }
  ```

6. Finally we can take out the existing `conman.js` in `web/static/vendor`. We don't need to do this as Brunch will just build over the top of it, but it's always a good sense check that our build pipeline is set up correctly to see the file actually being built.
7. Now we can create our `web/elm` folder and copy the `ConMan.elm`, `Contact.elm` and `elm-package.json` files over from our Elm project folder. We don't need the rest of the files. Anything else that we need will be built for us.
8. Once that's all in place, fire up the Phoenix server `iex -S mix phoenix.server` and head to [http://localhost:4000](http://localhost:4000) to see the result ... which is of course the same!
9. To check that everything is working, let's change the URL we're calling in the `web/elm/Contact.elm` file so that we get a different contact. If you keep the browser and the editor side-by-side whilst you do this you will be able to see it all happen in real time! Oh the giddy excitement!

  ```elm
  -- EFFECTS

  fetchContact =
    Http.get decodeContact "http://localhost:4000/api/contacts/2"
      |> Task.toMaybe
  ```


## Conclusions

So, there we have it. Three different ways that you can put an Elm in your Phoenix. I've only just started playing about with these technologies, so I've yet to come to any strong conclusions about how they best work together. Hopefully this post has at least given you some food for thought as to how you might get these two playing nicely together.

My next move is to [add channels into the mix](#part_4) so that we can bring some real-time action to the application.

If you have any feedback, pointers or questions [I'd love to hear them](mailto:alan@cultivatehq.com).
