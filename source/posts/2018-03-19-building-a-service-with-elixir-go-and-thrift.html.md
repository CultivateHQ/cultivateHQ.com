---
author: "Dan Munckton"
title: "Building a service with Elixir, Go and Thrift"
description: "A tutorial showing how to use Thrift with Go and Elixir to create a cross-language services"
---
# So what's this going to be about?

Together we are going to build a small toy service in [Go lang](https://golang.org/) with [Apache Thrift](http://thrift.apache.org/), then consume that service using [Elixir](https://elixir-lang.org/). The goal is to demonstrate how easy it is to build a cross-language API and client using Thrift.

### Why Thrift?

[Thrift](http://thrift.apache.org/) will generate code for us so we don't need to write our own data serialization/deserialization and model structures. It also provides server and client code so we don't need to write that either. Of course we still need to bootstrap our client and server, but much less code will need to be written by us.

And ... we get a really advanced and efficient choice of application protocols for our server and client to communicate using.

### Why Go?

[Go](https://golang.org/) is a popular language for backend service development. It has a simple _imperative_ syntax that is easy to read. So it should be good to use for code examples.

### Why Elixir?

Well ... because [Cultivate LOVES Elixir](/posts/tag/elixir/)! Seriously though, [Elixir](https://elixir-lang.org/) is also an excellent language to use for developing services. We will imagine the Elixir code is another service that needs to use the service presented by our Go server. Like Go, it is similarly clear and easy to read, but follows a _functional_ paradigm rather than _imperative_. The two should contrast nicely and most importantly demonstrate the language agnostic and paradigm neutral nature of Thrift.

### Ok I'm in. Show me stuff ...

Great! Before we do anything else we need to set up a source tree to contain our Thrift definitions, client and server code. We don't _need_ to keep them together, but it will make things more convenient for this tutorial.

Choose a parent folder to hold our project then make a directory called `thrift_go_elixir_tut`. We are going to assume you are using a Bash shell, and we will use the `$` character to represent the command prompt.

```
$ mkdir thrift_go_elixir_tut
$ cd thrift_go_elixir_tut
$ mkdir go-server ex-client thrift-defs
$ tree
.
├── ex-client
├── go-server
└── thrift-defs
```

## Writing Thrift interface definitions

Thrift provides an [IDL (Interface Definition Language)](https://en.wikipedia.org/wiki/Interface_description_language) to specify our data structures and service interface ([API](https://en.wikipedia.org/wiki/Application_programming_interface)). With these we can use the Thrift code generation engine to generate code for us in both our chosen languages.

<span style="background-color: yellow">TODO write the IDL and explain it</span>

## Let's get ... Go-ing ... on the server

We're all about the puns here at Cultivate. Anyway ...

Usually, the Go lang toolset expects a very specific source organisation. Projects must be nested in specific folders within a parent folder listed in the `GOPATH` environment variable. But we're going to keep everything together so our client and server can live within the same overall project folder.

<span style="background-color: yellow">TODO how?</span>

Run the service:

```
$ go-server/bin/go-service
Starting the simple server ... on  localhost:9090
```

Then in a separate shell, run the client that was generated for us:

```
$ go-server/bin/guitars-remote -P json all
[Guitar({ID:0 Brand: Model:})] <nil>
```
