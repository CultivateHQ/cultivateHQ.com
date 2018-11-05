---
author: "Valerie Dryden"
title: "Circuit Breakers"
description: "A short introduction to the concept of circuit breaking in programming."
tags: tools, patterns
date: 2018/11/05
---

By the end of this article you should have an understanding of:

* What we mean by the term 'circuit breaker' in programming.
* What some of the terminology around circuit breaking means.
* What the benefits of a circuit breaker are.

### Assumed Knowledge

This article assumes the reader has:

* A high level understanding of how apis are consumed.  
* A basic understanding of the request / response lifecycle.

## Scenario

In this example we have an app, CatTastic, that collects cat gifs from lots of sources then serves them up to users. It also serves up its own api for other apps to consume, one of which is the CatTastic Mobile App.

![Introduction-Diagram](2018-10-30-circuit-breakers/01-intro-explainer.svg)

If everything is healthy, the third party gif site will return quickly, say less than a second, and CatTastic will continue doing its job of sending back gifs to users in the web app and results back from it's api to the mobile app and third party apps.

## A World Without Circuit Breakers

Imagine that one of the third party gif sites, Gifatron, goes down and each request from CatTastic takes a minute to timeout. That's a minute before we can respond to anything calling the api, or the user of the web app.

![Introduction-Diagram](2018-10-30-circuit-breakers/02-gifatron-fail.svg)

In the meantime the caller of CatTastic web has sent us many more requests which are all stacking up to be processed. This is further compounded if we retry the failed attempts, because not only are we receiving new responses we are retrying the old ones as well which will again timeout after a minute.

We are still hammering the Gifatron service which is already struggling to process anything, reducing its chances of recovery.

Eventually we are going to run out of memory and processing power on the CatTastic web app because we are not freeing up any resources and continually queuing up more work.

When we run out of resources on the CatTastic app, the caller is going to start receiving timeouts from our app too, so now both Gifatron AND CatTastic web are down and timing out. Again we have to wait a minute for any user of the CatTastic api to find this out, meaning new requests to it are continually stacking up.

![Introduction-Diagram](2018-10-30-circuit-breakers/03-api-fail.svg)

Eventually the mobile app will stop responding and the third party apps hitting the api are now also getting timeouts and falling over too, then any app that calls them also go down and so on...

![Introduction-Diagram](2018-10-30-circuit-breakers/04-everything-fail.svg)

We call this a _cascading failure_ where the result of one system going down brings down everything that depends on it.

## What is a Circuit Breaker?

Let's revisit this scenario with circuit breakers involved. Before we address what 'circuit breaker' relates to in terms of programming, we should first look at it's origins because it helps us to understand some of the terminology that is used to describe them.

In electrical engineering, we make use of circuits in the transport of electricity. For example the lights in our house: when we turn on the light switch, the circuit that connects the light to the source is 'closed' and the electricity is able to pass through and the light turns on; when we turn off the light switch, the circuit is 'open' and the electricity is stopped from passing through to the light and it stays off.

A 'circuit breaker' in this sense is a safety device that can automatically 'open' a circuit to stop the flow of electricity - this is what happens when the cat knocks the milk into the toaster and all of the lights in the house go off.

In programming, we can use this same concept to stop our app from keeling over when one of its dependencies goes down.

## A World with Circuit Breakers

Let's return to our CatTastic example at the point where Gifatron goes down, but this time CatTastic Web is protected by a circuit breaker.

![Introduction-Diagram](2018-10-30-circuit-breakers/05-circuit-breakers-win.svg)

Gifatron is down and initially nothing is different. We get timeouts that we need to wait a minute for, and we can't respond to our callers. However, after a certain threshold of calls and errors received from Gifatron we 'open' the circuit so that no more requests are being made to that service.

With the circuit breaker set to a `request threshold` of 1000 and an `error rate` of 20% we would open a circuit if 200 errors were observed out of these 1000 requests and we would not make another request within a defined `sleep window` of say 5 seconds. After these 5 seconds have passed, we let a trial request through to Gifatron to see if it is back up. If not, we kick in another sleep window of 5 seconds and if it's back alive we let requests back through normally.

This requires some careful consideration about what happens to those requests that do not successfully go through. Do we store them ourselves to retry later? Is it the circuit breakers responsibility to store them and do the work for us? Some libraries will come with this functionality built in, in various shapes and forms, and others will not so it's really up to us to make that decision.

### Terminology Recap
* `Open circuit` - our app is stopping requests to the suffering service and then checking if it is up again.
* `Request Threshold` - the amount of request we care about in a given period (this period may or may not be configurable depending on what library you use) that we will compare against errors to decide if we need to open a circuit.
* `Error Rate` - the % or count of errors to check against when we are deciding if we should open a circuit. Used in tandem with the request threshold.
* `Sleep Window` - the amount of time to block requests to the failing service before letting through a test to see if it is up again

There are a lot of different implementations of circuit breakers that have their own ways of doing things, but it shouldn't be too dissimilar from this in concept.

## TL;DR

Using a circuit breaker is great because:

* When Gifatron is down, we immediately respond to the caller to say it is down rather than waiting a minute to do so and stacking up requests and blocking other apps
* We stop hammering Gifatron and give it a chance for recovery
* We free up resources on CatTastic stopping our own app from going down
* We avoid the cascading failure scenario

## Further Resources

Martin Fowler has an article on [how to make your own circuit breaker](https://martinfowler.com/bliki/CircuitBreaker.html) to further your understanding.

There are circuit breaking libraries for most modern programming languages, here are some examples that we have used successfully in production that you can look at:

[Go - Hystrix](https://github.com/Netflix/Hystrix)  
[Ruby - Circuit Box](https://github.com/yammer/circuitbox)



