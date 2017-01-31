---
author: Peter Aitken and Valerie Dryden
title: Elixir - alias, import, require and use
description: "In this post we aim to demystify when you should use __'alias, import, require or use'__ to bring in code modules within your Elixir code, as we found it tricky to get to grips with what exactly each of these was for."
---
# Elixir: alias, import, require and use

Here at Cultivate HQ we've been getting up-to-speed with Elixir and Phoenix and a number of things have proven tricky.

This blog post covers the minimum you need to know when using __alias, import, require or use__ to bring in  modules within your Elixir code and how they differ.

## Introduction

In all of these examples we'll be seeing how a student, __Sarah__, interacts with their __Anime Library__ when they want to relax from all that hard work studying.

Let's get started by defining a new module which will be the library of films that Sarah might want to watch.

```elixir
defmodule AliasExample.AnimeLibrary do
  def movies do
    [
      "Akira",
      "Gundam Wing",
      "Pokemon"
    ]
  end
end
```

Now let's take a look at how Sarah can use AnimeLibrary without any dependency keywords.

```elixir
defmodule AliasExample.Sarah do
  def yesterdays_viewing do
    hd(AnimeLibrary.movies())
  end
end
```

As you can see __AliasExample.AnimeLibrary__.movies() is called with the full module name. Let's have a look at other ways we can access functionality provided by other modules.

## alias

__alias__ is typically used to allow us to refer to another module with the last part of the module name.
You can see this below in the `:tonights_viewing` function.

```elixir
defmodule AliasExample.Sarah do
  alias AliasExample.AnimeLibrary

  def yesterdays_viewing do
    hd(AnimeLibrary.movies())
  end

  def tonights_viewing do
    hd( tl(AnimeLibrary.movies()) )
  end
end
```

There is a also a cheeky way to completely change the name of AnimeLibrary too by using the `as:` option with __alias__. You can see the new name (__MyMovies__) being used in `tomorrows_viewings()`

```elixir
defmodule AliasExample.Sarah do
  alias AliasExample.AnimeLibrary
  alias AliasExample.AnimeLibrary, as: MyMovies

  def yesterdays_viewing do
    hd(AnimeLibrary.movies())
  end

  def tonights_viewing do
    hd( tl(AnimeLibrary.movies()) )
  end

  def tomorrows_viewing do
    hd( tl( tl(MyMovies.movies()) ) )
  end
end
```

## import
In this set of examples we will have a slightly different __AnimeLibrary__, where we now have public and private functions.

```elixir
defmodule ImportExample.AnimeLibrary do
  def movies do
    [
      "Akira",
      "Gundam Wing",
      weekend_movie()
    ]
  end

  defp weekend_movie do
    "Pokemon"
  end
end
```

__import__ works much the same way as __alias__, however we are now able to completely remove __ImportExample.AnimeLibrary__ when calling it's public `movies()` function - as if it had been declared in the scope of __Sarah__.

```elixir
defmodule ImportExample.Sarah do
  import ImportExample.AnimeLibrary

  def tonights_viewing do
    hd(movies())
  end
end
```

This is very much like modules from ruby, with the added bonus that __Sarah__ is unable to access __ImportExample.AnimeLibrary.weekend_movie()__ as it is private.

One last thing to note is that if __movies__ was a macro rather than a function the behaviour would be exactly the same. For example:

```elixir
defmodule ImportExample.AnimeLibrary do
  defmacro movies do
    [
      "Akira",
      "Gundam Wing",
      weekend_movie()
    ]
  end

  defp weekend_movie do
    "Pokemon"
  end
end
```


## require
Rather than having access to *functions* from a module with __alias__ and __import__, we're now going to pull in *macros* with __require__. Although you will consume them often, actually creating macros is a fairly advanced topic that you can read about [in the docs](http://elixir-lang.org/getting-started/meta/macros.html)

__require__ allows us to pull in a bunch of macros that we would like to use, much like we did with with __import__.

```elixir
defmodule RequireExample.AnimeLibrary do
  defmacro movies do
    ["Akira", "Gundam Wing"]
  end
end
```

However, unlike __import__ after we __require__ the  __RequireExample.AnimeLibrary__ we then need to provide the full module name, followed by a call to the macro.

```elixir
defmodule RequireExample.Sarah do
  require RequireExample.AnimeLibrary

  def tonights_viewing do
    hd(RequireExample.AnimeLibrary.movies())
  end
end
```

A common use case for __require__ is when accessing the Logger module.

## use

The last piece of the puzzle we need to look at is __use__.

At its simplest __use__ is similar to __import__ in that it has inline use of all public functions from the module. However our module looks very different.

```elixir
defmodule UseExample.AnimeLibrary do
  defmacro __using__(opts) do
    quote do
      def movies do
        [
          "Akira",
          "Gundam Wing",
          weekend_movie()
        ]
      end

      defp weekend_movie do
        "Pokemon"
      end
    end
  end
end
```

You can see that all the code is defined in a special macro called __\_\_using\_\___.
Everytime a client calls __use__ to bring in a dependency then this macro is called.

At this point everything within the __quote__ block is applied to the client. [Quoting](http://elixir-lang.org/getting-started/meta/quote-and-unquote.html) and unquoting is another advanced topic related to macros which is outwith the scope of this post.

```elixir
defmodule UseExample.Sarah do
  use UseExample.AnimeLibrary

  def tonights_viewing do
    hd(movies())
  end
end
```
Notice that the public function (__:movies__) is now available inline on the client as you can see within `:tonights_viewing`, much like import did with functions.

However we can see that the (__:movies__) function is also available on Sarah's public interface...

```elixir
$ iex
iex(1)> UseExample.Sarah.movies()
["Akira", "Gundam Wing", "Pokemon"]
```

### Opts

We just have one little last thing to talk about here.

Looking back in the __UseExample.AnimeLibrary__ __\_\_using\_\___ macro, you can see there is an __opts__ parameter passed in.

In the [repo](https://github.com/CultivateHQ/elixir_dependency_blog_post_examples) for these examples we've made use of __opts__ to conditionally, and trivially, add different variations of functions if you'd like to nosy.

One place we've seen this used is in the web.ex file generated by [Phoenix](https://github.com/phoenixframework/phoenix/blob/master/installer/templates/new/web/web.ex#L89). (Bare in mind this is a template used to generate the web.ex file).

We hope this post has been helpful on your journey to learn Elixir.

## Summary table
 Access  | alias | import | require | use |
 ------------ | :-----------: | -----------: | -----------: | -----------: |
Call with *Example.AnimeLibrary.movies() |✅ |✅ |✅ | ❌    |
Call with AnimeLibrary.movies()          | ✅ |  ❌        | ❌  |❌     |
Call with \<CustomName\>.movies()          | ✅ |  ❌        | ❌  |❌     |
Call with movies()                       |❌|    ✅      |     ❌   | ✅  |
Allows Sarah access to private functions |❌  | ❌    |❌|❌ |
Allows Sarah access to public functions  |✅  | ✅          | ✅  | ✅  |
Allows access to public functions from Sarah  |❌  | ❌         |  ❌   | ✅  |
Allows Sarah access to macros  |❌  |✅            | ✅  | ✅  |
