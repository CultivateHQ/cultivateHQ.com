---
title: How to be a kinder more effective code reviewer
date: 2018-12-17 18:14 UTC
author: Dan Munckton
description: The reviewer holds the balance of power in code reviews. Here is a simple framework we can follow to become kind and helpful reviewers.
tags: compassionate-coding
---

Over the years, I've had both good and bad experiences with code reviews. A.k.a "pull requests" if you're using GitHub/GitLab or similar. Given this experience, I have some thoughts about how we can change our behaviour to have more positive experiences, more often.

Although a code review takes place between a reviewer and a reviewee (code author), for this article I am going to focus on the role of the reviewer. There is definitely a whole other post to write about how to be a good reviewee. But, I want start with the reviewer because they have the most "power" and thus the most influence on the outcome.

I am going to suggest a simple framework we can follow to get us into a good habits as reviewers.

## What does bad look like?

### When your handwriting isn't good enough

Sometimes reviewers feel like they are the last point of defence against invading code changes.

This can happen in open source projects, where someone may be maintaining a personal project that has grown popular. But also when new coders join any existing team, especially if they are contractors or less experienced.

When the time comes to ask for a review, you can be left feeling like a code-minion; with no power to influence the incumbant team at all. Even if you have made a good case for how you did things, you get told to rewrite against your better judgement.

This type of review demotivates contributors.

### When it isn't clear what action the reviewer wants you to take

A reviewer might leave a comment like, "maybe don't do like this?", which invites, "Why? What are you suggesting then?"

If the feedback given is ambiguous the reviewee will need to post a question, which starts another round of request and response.

This type of feedback costs time for both parties.

### When it's too terse

At the opposite end of the scale, when the feedback becomes too clear. "Change to X", "rewrite as Y".

Most likely the reviewer is hurrying and their intentions are good. But these statements are orders. They _demand_ change without any rationale. Is the reviewer sure? What is it they know that I don't? Are these actually suggestions? Can I push back?

In teams with a long history and a lot of trust, this kind of feedback may be tolerable. But in other cases this type of feedback can become quite toxic rapidly.

## What does good look like?

When it's clear from the first comment exactly how the reviewee should respond.

When it's clear whether the reviewee can decide for themselves what to do, or whether they _must_ make a change.

When, with no further discussion, they can go directly to a code change.

When the reviewee is shown trust and respect.

When the reviewer shows an appreciation of the effort it took to get the work ready for review.

When the reviewer is open to discussion and new ways of looking at things.

## Ok how can we do this? 

Some people have natural talent for delivering feedback. Others have to work at things. If you're in the latter camp, like me, it's a confusing sometimes anxiety inducing journey trying to work out what how to get good outcomes. If you're not sure how to be a good reviewer, I suggest trying the following framework. It has helped me.

## The framework

The most efficient use of both parties' time is when the feedback given is **actionable**.

It seems to me that all **actionable** feedback I would ever **need** to give on a pull request, can be expressed as one of the following types of statement:

- A question
- A Suggestion
- A change request

These kinds of comments can very often be crafted so that it is immediately obvious what action the reviewee should take.

There is a fourth category of **un-actionable** feedback that I sometimes **want** to give:

- A reaction

Let's look at each in detail.

### When to use a question?

When you don't have enough information to understand why something has been done as it has.

This maybe for your own benefit in understanding. Or because you suspect there is a suggestion that could be made, or change to request, but you need to check a detail first.

### When to use a suggestion?

When:

- You know another, possibly better, way to achieve the same outcome
- You may have misunderstood, but think an outcome should be achieved differently
- You are unsure if the reviewee has already evaluated the approach you want to suggest. But you want to check in case they were not aware of an alternative

But most importantly: **when you don't mind if the author chooses not to use what you're suggesting.**

### When to use a change request?

When you definitely need the author to make change. Happily, I find I use this mode the least. Use it if:

- You can prove a bug exists
- You know of a stylistic change, that will make the code more consistent with the project/team approach
- You know of a design change, that will make the code more consistent with the project/team approach

**Always use "suggestion" instead when there are minor things that you would personally have done differently.**

Note that we are not demanding change, but requesting it. We're saying "request" to communicate that a thing needs to be done, with importance. But making it ok for the author to push back if they have information we as the reviewer do not.

### When to leave a reaction?

You might want to express surprise because you learned something. But most importantly, you might want to compliment the author for their work.

This category is **very important** because we can use it to tell a person they have done good work. This is very motivational. But we should be careful as it is **not actionable**. Too many comments like this can make it hard to see the things that require a response.

So while we should _definitely_ leave comments like this, we should sprinkle them lightly. A "LGTM!" as you leave your approval may be all that's required.

## Examples

### Prefixes

To start with, something that helped me was to prefix my comments explicitly:

<blockquote class="pullquote">
Question: could you explain why this ended up having to be here?"
</blockquote>

<blockquote class="pullquote">
Suggestion: you may have come across this already, but we might be able to use XYZ for this.
</blockquote>

<blockquote class="pullquote">
Change request: sorry, I appreciate the effort it took to get it this far. But the team already agreed to solve this using XYZ. So I'm going to have to ask you to rework this. Let me know if I can help.
</blockquote>

Or drop to abbreviations if everyone is used to your approach.

<blockquote class="pullquote">
[Q] could you explain why this ended up having to be here?
</blockquote>

<blockquote class="pullquote">
[S] you may have come across this already, but we might be able to use XYZ for this.
</blockquote>

<blockquote class="pullquote">
[CR] sorry, I appreciate the effort it took to get it this far. But the team already agreed to solve this using XYZ. So I'm going to have to ask you to rework this. Let me know if I can help.
</blockquote>

The value in the prefixes is that the reviewee can easily see what kind of action they are going to need to take. The value to you as the reviewer is to keep yourself in the right mode as you craft your comment.

## Keeping things clear

Often it is necessary to back up your request with some kind of rationale or discussion. As a reviewee I find it very hard to pick out the request if it's too mixed up in paragraphs of discussion. Yet, as the reviewer I'm not always sure what I'm asking for until I've rambled through a bit of rationale.

For the best of both worlds pull the **actionable** part of your comment to the top once you know what it is. Then add any discussion below. Like this:

<blockquote class="pullquote">
[type]: [actionable request]
<br />
<br />
[rationale or discussion]
</blockquote>

For example:

<blockquote class="pullquote">
Suggestion: you may have come across this already, but we might be able to use XYZ for this because blah blah blah etc.
</blockquote>

becomes

<blockquote class="pullquote">
Suggestion: use XYZ.

You may have come across this already, but we might be able to use XYZ for this because blah blah blah etc."

</blockquote>

## Other do's and don'ts

As a parting shot, here's a mixed bag of other tips I've learned the hard way.

### Don’t be a code formatter. Do be a linter. If possible don’t be a linter either.

If you find yourself pointing out white-space errors, or telling people to use single-quoted strings, you are wasting your time.

Look to see if you can use a tool like [Rubocop](https://github.com/rubocop-hq/rubocop) or [ESLint](https://eslint.org/) that can deal with these issues automatically.

### Use a friendly avatar

I know you think your avatar is cool and represents you in some deep way, only expressible online. But be careful that your digital-identity isn't colouring your feedback with an aggressive tone.

I experienced this in an open source project. My contribution received some pretty terse feedback from a busy person with a cartoon monster avatar.

It sounds ridiculous but as I read the feedback, some weird primordial part of me kept reacting to the picture too. It was hard to avoid responding defensively.

Sure it was tolerable. But it made the situation that bit more stressful.

### Take protracted discussions elsewhere   

Sometimes a big issue comes up that needs more lengthy discussion. Don't be that person who plasters the entire review with their opinion and offers no actionable way forward.

Suggest a face-to-face discussion. If that is not feasible try a video call, or even an IM discussion.

Try to offer ways forward. Don't respond if you're feeling angry.

### Scope creep

Consider whether what you're asking for is really within the scope of the work being reviewed.

When you spot small issues unrelated to the task in hand, it's tempting to ask the author to make fixes. But be careful to consider how much extra noise this will add that distracts from the intent of the work. It might make it harder for other reviewers.

Also consider how much time the reviewee has already invested. It is really annoying being asked to do one more thing just as your work is about to be accepted.
