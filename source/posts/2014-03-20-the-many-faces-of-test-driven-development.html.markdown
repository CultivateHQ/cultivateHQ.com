---
title:  "The Many Faces of Test Driven Development"
date:   2014-03-20 10:41:21
author: Paul Wilson
---

Like many religious wars, the Test Driven Development debate seems interminable, unpleasant, and not a little tedious. "Mocks Suck and cause brittle tests." "No, including real collaborators in your tests makes them brittle." "That's not a unit test". "It's not about testing, it's about design." "No, it's about documentation."

It's not experience and facts that are missing from these debates: it's nuance; it's an appreciation of trade-offs.

There is no One True Way of Test Driven Development. Like most things in the real world, there is not just one benefit (or disadvantage) of practicing TDD.

Most days I cycle to work because it's faster than walking or getting the bus, because it's a reasonable way of getting regular exercise, and because I resent the way our cities have been taken over by the motor car and want to reclaim the streets. I cycle for all of these reasons. If it was all about speed, I'd buy a small motorbike; I could get the exercise on a static bike in the gym. It's great to get a combination of benefits for the same time and effort.

For me, TDD's benefits are:-

It gives me confidence that my code does what I think it does It confers the ability to refactor code without the fear that I have broken something It encourages a testable, and hence modular, design The tests describe the behaviour of the code I value all those benefits, but I do value them in that order. I give greater weighting to confidence than design so I tend to favour a more classical style, with only light use of Mocks.

Others give more preference to the way tests influence design, and use the mock-heavy GOOS style.

This is fine - we are just choosing different tradeoffs. Put like that, it doesn't seem worth getting caremad about. Does it?
