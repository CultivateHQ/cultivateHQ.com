---
title:  "Practice Makes Perfect"
author: Paul Wilson
---

> This article originally appeared in the February 2013 version of [Test Magazine](http//www.testmagazine.co.uk).

In December last year, around 3,000 programmers in 160 cities around the world gave up their Saturday to write code - code they deliberately threw away. They were not being weird or frivolous. They were there to take part in The Global Day of Code Retreat, and improve their craft.

Musicians do not practise by only playing symphonies. Marathon runners do not train by running marathons. They engage in directed practise such as playing musical scales or interval runs. A Code Retreat is a community event to help programmers engage in directed practice. They work on improving their code, free of the constraints of time-pressure or having to finish the task.

## Playing the game

The Code Retreat format consists of multiple sessions of implementing Conway's Game of Life:

Each session lasts for 45 minutes.

* The code is written in pairs, meaning that two people share one computer and collaborate.
* It is also Test Driven, which means that an automated unit test is written before each piece of code and the code is improved before writing the next test.
* Pairs are swapped after every session.
* Code is deleted after every session.

After each session the group shares their experience in a short retrospective. The retrospective concentrates on anything learnt. The main focus of the retrospective is to make the group think about the extent to which each pair has managed to follow the XP rules of simple design. These are:

1. The code passes all the tests, implying that automated tests have been written and the code does what is intended
2. The code reveals intent. This is a measure of how easy it is to understand what each piece of code is supposed to do.
3. There is no duplication, also known as the Once and Only Once Rule. Duplicate code can be considered bad code as it is hard to change and understand. Duplication can be as obvious as code copied and pasted from one place to another but can also be subtle, where a rule is expressed in two different places in the code.

Time pressure can be detrimental to this kind of deliberate practise. Throwing the code away and implementing the 45 minute time limit on each session is designed to relieve the pressure of finishing the problem. Most pairs do not manage to implement Conway's Game of Life during a session, and that is desirable: unlike a programmer's day-job or even a hack-session, the value of Code Retreat lies in improving skills rather than producing useful code.

The problem, [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life), is chosen as it is fairly complex to implement but easy to understand. A problem that was hard to understand would get in the way of concentrating purely on improving code skills.

## Tell, don't ask
After the first iteration, the facilitators introduce a constraint for each subsequent iteration. As well as keeping the exercise interesting, the constraints are designed to provoke different ways of thinking and working with code. A common constraint is "no return values", which often leads to a more Object Oriented way of working known as Tell Don't Ask.

Code Retreat came out of a discussion at the Code Mash conference in Ohio. [Corey Haines](https://twitter.com/coreyhaines), a well known figure in the [Software Craftsmanship](http://en.wikipedia.org/wiki/Software_craftsmanship) community, helped create the format and is responsible for popularising it since then. For the last two years there has been a Global Day of Code Retreat: Code Retreats on the same day in different cities around the world.

On December 8, 2012, Neo hosted and facilitated the Edinburgh chapter of Global Day of Code Retreat. After the first zero-constraints session, also known as The Warm Up session, we introduced a single constraint per session.

1. _Ping Pong_: One member of the pair writes a failing test and it is up to the other member to implement the test. Pairs that were more experienced with TDD swapped roles, while those who were new to that discipline did not. This is a good ice-breaker and gets people comfortable with pairing.

2. _Mute Ping Pong_: Like Ping Pong, but the pairs were not allowed to communicate with each other except through the tests or code. This becomes an exercise in writing focussed and expressive unit tests.

3. _No returns_. After a method performs a calculation, the participants were banned from returning the result to the method: they had to find other ways to pas on the information. This was a particularly challenging exercise for many of the participants. While many did find value in it, we might have coached the others a little better.

4. _Back to back_: one straightforward iteration was performed without any constraints. This time the code was not deleted, but the pairs were told to write down the areas of the code that they could have done better. After the retrospective the pairs were kept the same but the code was swapped: other pairs were given the task of trying to improve the previous pair’s code.

The feedback at the end of the day was overwhelmingly positive. It is amazing how enjoyable failing to implement the same problem several times can be. The most gratifying part was winning over the participants who were initially sceptical about Pair Programming and Test Driven Development.
