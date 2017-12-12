---
title:  "9 Things to Consider When Choosing a JavaScript MV* Framework"
author: Dan Munckton
description: You may find it useful to consider this list of factors when deciding between several JavaScript MV* frameworks. We’re not going to lecture you about which solution you should choose – we’ll leave that up to you.
tags: javascript
---

## tl;dr
You may find it useful to consider this list of factors when deciding between several JavaScript MV* frameworks. We’re not going to lecture you about which solution you should choose – we’ll leave that up to you.

## The problem
There are lots of JavaScript MV* frameworks to choose from. They don’t all have exactly the same goals and several of them subscribe to fundamentally different design principles.

Conducting a realistic trial of just a few of them is a substantial exercise; without building something moderately complicated, it is difficult to get past the introductory material and really get a feel for a framework. Plus, a lot of the tutorials omit any coverage of testing — presumably to reduce cognitive load on those looking for a basic introduction. Of course, there is TodoMVC, which is a fantastic resource, but comparing pre-made examples only answers some of the questions you need to work through to make an informed choice.

## What do you need to think about when choosing?
There is no magic solution for this problem. But, having evaluated several frameworks ourselves, we wanted to share the list of differentiating factors we feel are important. We hope they will be useful for you too.

### 1) Magic
A common design goal among the available frameworks is to allow the developer to do more with less. To us, it appears this results in a trade-off between:

* Completely transparent/explicit code – clarity with the cost of being more verbose, and
* Convention over configuration – more power with less code, but in some cases can appear rather magical to the unfamiliar user

Some frameworks, [Backbone](http://backbonejs.org) for example, achieve the goal simply by providing you a structure to work in; so you can focus more on the what rather than the how. At the other end of the scale, there are frameworks such as [Ember](http://emberjs.com/); you work to its conventions and in return it will do a lot for you without you needing to ask.

Some questions to think about:

1. Who will be the future maintainer of the application? Will they be familiar with your chosen framework?
2. What productivity features do you want? E.g. do you want to use 2-way data binding? Are you happy for the framework to automatically create objects in the background unless you want to customise them?
3. Do you prefer code to be as transparent and explicit as possibly at the cost of it being more verbose? Or are you happy to conform with conventions in order to do more with less code?
4. Are you planning on specialising in the framework and/or investing in training your team?

We stumbled upon a handy litmus test for this quality: run through a practical intro-tutorial for each of the technologies on your short list, then come back a week later and re-read the code. Can you explain with confidence how it works and how long does it take you to understand it again?

### 2) Routing
A key feature of single page applications is the ability to present several screens to the user without needing to completely reload the page each time.

Several of the available frameworks provide a convenient implementation of this by adapting the URL-routing concept, borrowed from server-side frameworks such as [Rails](http://guides.rubyonrails.org/routing.html), for use with the [URL fragment](http://en.wikipedia.org/wiki/Fragment_identifier). Others provide no such support, which means you would need to either parse window.location yourself or look for a plugin.

Key questions:

1. Is your application transferring enough data on each full page load that making it a single-page app would bring significant benefits? E.g. more responsiveness in terms of latency or reduced data transfer costs.
2. If you decide to use a single-page architecture, do your users need the ability to share links to sub-screens within the interface? If so look for a framework that routes based on the URL.
3. Does the framework have built-in support for routing?
4. Does the framework support routing as an add-on (e.g. [Angular](https://angularjs.org/))?

### 3) Templating
Some frameworks have been built to use a specific templating technology exclusively, others allow a free choice. Tighter integration with a specific framework is possibly about enabling more interesting features e.g. 2-way-data binding and custom components, but this comes at the cost of choice.

Some favour, or at least enable, embedding markup within the JavaScript code ([React](http://facebook.github.io/react/) for example).

Key questions:

1. Do you prefer to use templates or embed HTML markup within your JavaScript code?
2.Does the framework under consideration force you to use a specific templating solution or are you free to use any of your choice? If the former is true, are there enough advantages that it’s worth putting up with it?

### 4) Dependencies
Does the framework depend on any 3rd party libraries (e.g. [jQuery](http://jquery.com/))? If so, does this present a conflict with any libraries you want to use (e.g. [Zepto](http://zeptojs.com/)) or force you to use specific versions?

### 5) Module Loaders
If you are using an [AMD module loader](http://requirejs.org/docs/whyamd.html), such as [RequireJS](http://requirejs.org/), is the framework compatible with it?

For example, the Ember team are not convinced by the AMD approach to module loading, which may or may not mean that the two will work well together. Angular has its own built-in solution for modularity and dependency resolution, but can still be used with an AMD style loader if desired.

### 6) Testability
How easy is it to test the code you produce within the framework?

Key questions:

1. Do you need to do a lot of complicated set-up to isolate the unit you want to test?
2. Is it obvious how to get at and test the features of the unit under test? Or do you need to learn a new API?
3. Are you locked into using certain test frameworks? Or at least, if there is a recommended framework, what are the costs/obstacles likely to be if you try to use an alternative? E.g. choosing to test an Ember app with Mocha instead of QUnit.
4. Is it easy to write end-to-end system tests (using Karma or similar)?

### 7) Remote API Integration
For basic AJAX calls most of the frameworks either provide an HTTP client service or you can choose your own, e.g. jQuery.getJSON or similar.

The majority also provide some sort of convenient model abstraction. Where the details of the underlying persistence method – which may be a REST API or browser local storage – are hidden. So you only have to manipulate JavaScript objects.

We discovered an important gotcha here for REST API integration: each of the frameworks we reviewed assumed slightly different JSON response schemas. So unless you can tailor your remote API responses you may have to do extra work to plug the framework into your API.

You must also consider caching and synchronisation of any data you load from the server. Particularly if you have multiple users editing data concurrently.

Key questions:

1. Does the framework provide its own HTTP client service or do you have to choose your own?
2. Does the framework support a model abstraction with REST integration? If so, what schema does it expect the JSON replies to use?
3. Do you have control over the design of the external API or will you have to write adaptors? If the latter, how does the framework support custom API adapters?
4. Will multiple users be able to edit your application data? If so, how and when should shared data get reloaded from the server? Will it be cached by the framework or explicitly by your own code? When will the cache be invalidated and resynced with the server?

### 8) Documentation
Good documentation is crucial. Incomplete or incorrect reference material can make developing with a new technology feel a lot like marching through mud.

Key questions:

1. Is the available documentation up to date?
2. For frameworks with unstable APIs (e.g. Ember-Data at the time of writing), is the documentation clearly linked to software release version?
3. Is it easy to retrieve documentation for previous releases? The framework may advance quickly, but it may be difficult for you to upgrade if you’ve written a sizeable portion of your application already.
4. Does the reference material contain relevant examples for both typical and advanced use-cases?
5. Is there a good mix of material e.g. articles, tutorials, videos, developer guides, API references?
6. Is there a healthy community discussing / supporting / writing about it?

### 9) Browser Compatibility
MV* frameworks tend to be forward-looking. If your users are likely to be using anything but the latest browsers, then care should be taken to check the minimum versions supported. E.g. AngularJS 1.3 dropped support for IE8. So those of you with user-bases still tied to IE6 – we all know they’re out there – maybe out of luck.

Key questions:

1. What are the minimum browser versions supported by the framework and how to they compare with the versions you need for your project?
2. Will you be able to gracefully degrade certain features in order to support less capable browsers?

## Summary
So, lots of things to think about and this is by no means an exhaustive list. Depending on the constraints you are working to, you may need to consider other qualities such as rendering performance or download size. Nevertheless, we hope this list serves as a good introduction to the basic issues worth thinking about.

If you’d like to suggest something that we should include, then we’d love to hear from you.

Further Reading

[TodoMVC](http://todomvc.com/)

[Journey Through The JavaScript MVC Jungle](http://www.smashingmagazine.com/2012/07/27/journey-through-the-javascript-mvc-jungle/)

[Code School Blog – Angular, Backbone, or Ember: Which is Best for your Build?](http://blog.codeschool.com/post/85819292538/angular-backbone-or-ember-which-is-best-for-your)
