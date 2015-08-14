---
title:  "How to add and test HTTP basic authentication in a Phoenix web application"
author: Mark Connell
description: Short tutorial on how to add basic authentication to a phoenix web app.
---

If you are coming from a Rails background, you'll be used to having a convenience
method `http_basic_authenticate_with`. Which you simply throw into your controller
and just like magic, have a password protected portion of your web app.

Phoenix by default, doesn't include any authentication. So to add HTTP basic auth
(or any other type of authentication), you either need to roll your own, or make use
of some of the many Plug packages that are popping up to help you along.

I wrote [BasicAuth](https://github.com/cultivatehq/basic_auth), a Plug that lets you add
Rails-like basic authentication at controller or router level using a snippet like:

```elixir
# add the package to your mix.exs deps
{:basic_auth, "~> 1.0.0"}
```

```elixir
# drop this in a controller or router pipeline
plug BasicAuth, realm: "Admin Area", username: "admin", password: "secret"
```

If you're interested in how this works under the covers, here's the
[implementation](https://github.com/CultivateHQ/basic_auth/blob/master/lib/basic_auth.ex).

## How do you test basic auth in Phoenix?
Adding in basic auth is fairly straightforward when we use plugs, but if you have tests for
your controllers, you're going to start seeing a whole load of failures because of the
behaviour change.

To crudely summarise how HTTP basic auth works at the client-side, your browser needs to
send a request header that looks a bit like:

```
Authorization:Basic YWRtaW46c2VjcmV0
```
Where `YWRtaW46c2VjcmV0` is the basic auth username and password combined in a string
like `"admin:secret"`, and then base64 encoded.

In elixir, we can do this with the help of the `Base` module, which is part of the
[Elixir standard library](http://elixir-lang.org/docs/v1.0/elixir/Base.html). We can test
this out in an IEx session:

```elixir
iex(1)> Base.encode64("admin:secret")
"YWRtaW46c2VjcmV0"
```

So to create the full content for our header we can do something like:

```elixir
iex(1)> "Basic " <> Base.encode64("admin:secret")
"Basic YWRtaW46c2VjcmV0"
```

When writing controller tests, we're making use of
[`Plug.Test`](http://hexdocs.pm/plug/0.8.1/Plug.Test.html), which is where the `conn()` function
comes from. So for example, a really simple test case might look something like:

```elixir
test "GET /" do
  conn = conn()
  |> get("/")
  assert html_response(conn, 200)
end
```

Now the problem at hand is, we want to make the `GET` request to `/`, but we need to add the
`authorization` header into our request. With the pipe operator (`|>`), this becomes quite an
easy task actually. We simply add in an additional line for setting our request header:

```elixir
put_req_header(conn, "authorization", "Basic " <> Base.encode64("admin:secret"))
```

Dropping that into our previous test case (removing the first argument as it is piped), we get something that looks like:

```elixir
test "GET /" do
  conn = conn()
  |> put_req_header("authorization", "Basic " <> Base.encode64("admin:secret"))
  |> get("/")
  assert html_response(conn, 200)
end
```

This can be tidied up and made a bit nicer, but is everything you need to know in order to
get started with testing HTTP basic auth. For more details, checkout the
[README](https://github.com/cultivatehq/basic_auth/blob/master/README.md) on the BasicAuth
github repository.
