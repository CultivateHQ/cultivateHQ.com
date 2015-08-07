---
title:  "How to set different layouts in Phoenix"
author: Mark Connell
description: Quick guide on setting alternative layouts within a phoenix web application.
---

> This post is based on behaviour in Elixir 1.0.5 & Phoenix 0.15.

By default, a new phoenix application provides you with a layout file called `app.html.eex`, which is super.
However, sometimes we need to use different layouts when we build specific areas of applications, like an
admin section. This is a quick guide on how to use a different layout file.

For all of the examples below, I'm assuming that there is a file `admin.html.eex` within the
`web/templates/layout` directory.

## Modify controller functions to render with the specific layout file

The first way I found which allows you to set the layout file, is to directly pass an additional argument
to the `render/3` function:

```elixir
  def index(conn, _params) do
    render conn, "index.html",
      layout: {MyApp.LayoutView, "admin.html"}
  end
```
Which works... However it does mean that if we have a lot of functions that render in our controller, we
need to duplicate this bit of code.

## Apply the layout at a controller level

The next approach is a bit nicer, which reduces the repetition of explicity declaring the layout.

```elixir
  defmodule MyApp.Admin.SomeController do
    use MyApp.Web, :controller

    plug :put_layout, "admin.html"

    def index(conn, _params) do
      render conn, "index.html"
    end
  end
```

This is nice, but we still have some duplication if we have a number of admin controllers.

## Apply the layout at the router

This is my current approach to solving the problem. Create a new pipeline with our plug and use it along
with the standard `:browser` pipeline. Declaring it as part of the plug pipeline used in the admin routing,
it covers all of our admin controllers.

```elixir
# web/router.ex
  pipeline :admin_layout do
    plug :put_layout, {MyApp.LayoutView, :admin}
  end

  scope "/admin", MyApp do
    pipe_through [:browser, :admin_layout]
    resources "/some_path", Admin.SomeController
  end
```
