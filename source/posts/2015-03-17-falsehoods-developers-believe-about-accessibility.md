---
title:  "Accessibility Debt: What Happens When You Do Accessibility Last"
author: Caden Lovelace
description: "By leaving our assumptions about disabled users unchallenged until the end of a project, we don't only do a bad job, we also create technical debt."
---

Here's how you probably make an accessible website:

1. Conceive the website.
2. Design the website.
3. Build the website.
4. Make it accessible.

That last step takes ages, and the reason is simple: you've left it until last. Anything that's left until last takes ten times longer than it should. Let me explain why.

Let's say I ask you for a recipe website. I want the recipes to have tags, so I can tag them with `delicious` or `vegetarian` or `poisonous`. Simple enough, so you make it.

A few months later, I come back. Don't Worry, it's all going great with my recipe site, but I want to change something. The tags are great, but I want them to be nested like categories, so each tag has a parent — then I can have breadcrumbs for my recipes.

You can fill in the rest.

This is what nearly every accessible web project does. We conceive, design, and build it with the minimum of thought to accessibility. Then, at the end, we sprinkle it on — the finishing touches.

But it doesn't work that way, and 'adding accessibility' gets a reputation for being unpleasant and confusing.

The root of the problem is our assumptions — about the user, and how they will use what we're building. We carry these assumptions through the whole project. We wait until the end of the project to invalidate those assumptions and 'see what happens'.

Let's call this what it is: technical debt.

Accessibility debt.

Instead of letting this accrue interest from the word go, let's challenge these assumptions throughout. But before we can do that, we need to broaden our understanding of what users are really like.

## Some common assumptions about users

### Perception

* [Users can see.](http://webaim.org/articles/visual/)
* [Users can see more than one area of the screen at once.](https://www.youtube.com/watch?v=4ZRVDgeMpXc)
* [Users can distinguish between colours.](http://24ways.org/2012/colour-accessibility/)
* [Users can easily ignore motion or colour change if they need to.](https://www.webaccessibility.com/best_practices.php?technology_platform_id=11)
* [Users can read text that is low contrast.](http://www.w3.org/WAI/EO/Drafts/eval/checks#contrast)
* [Users can read text that is high contrast.](http://www.w3.org/WAI/EO/Drafts/eval/checks#contrast)
* [Users can hear.](http://webaim.org/articles/auditory/)
* [Users can access videos.](https://www.youtube.com/watch?v=yx7hdQqf8lE&t=363)

### Operation

* [Users will know how to access accessibility features.](http://webaim.org/projects/screenreadersurvey4/#landmarks)
* [Users use a keyboard.](https://www.youtube.com/watch?v=kJKQmTumFP0)
* [Users use a mouse.](https://www.youtube.com/watch?v=rl3D8alghog)
* [Partially sighted users will use a screen reader.](http://joeclark.org/appearances/atmedia2005/atmedia-NOTES-2.html#li-75)
* [Users can navigate through an interface based on the order elements appear on the page.](http://www.w3.org/TR/WCAG20-TECHS/C27.html)

### Understanding

* [Users can read English.](http://bbc.co.uk/news/uk-21259401)
* [Users can read to an average standard.](http://www.literacytrust.org.uk/adult_literacy/illiterate_adults_in_england)
* [Users understand any given word or phrase.](http://www.w3.org/TR/UNDERSTANDING-WCAG20/meaning-idioms.html)
* [Users understand 'basic' technical vocabulary.](https://www.youtube.com/watch?v=o4MwTvtyrUQ)

In addition to the above, there are a lot of myths that circulate about accessibility. They can be very destructive — [particularly that one about Javascript](http://webaim.org/projects/screenreadersurvey5/#javascript). They prevent us from using useful techniques like [ARIA Live Regions](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/ARIA_Live_Regions). In the worst case, they can cause projects to give up on accessibility or hide functionality from some groups of users.

When I learned about all of this I felt quite dispirited. Most of the techniques I had been applying were inadequate, or totally misguided.

## What can I do about this?

The truth is that you can't make a website accessible just by applying techniques. That approach is called _Technical Accessibility,_ and it has a lot of flaws. You have to design with accessibility in mind from the start.

WebAIM has [an excellent series of articles](http://webaim.org/articles/pour/) that outline a _people-focused_ approach to accessibility. It's based on four principles, called POUR:

* __Perceivable__  
  The user has to be able to __perceive__ your interface. For example, a blind user cannot perceive a visual diagram, so some description or alternative content can be provided.
* __Operable__  
  The user needs to have a way of __operating__ your interface. For example, a user who navigates with a keyboard only will be unable to operate an interface that requires a mouse.
* __Understandable__  
  The user needs to be able to __understand__ your interface. For example, if your instructions use a word that a user does not know and cannot understand from the context, they will be unable to act on your instructions.
* __Robust__  
  The above points should be implemented __robustly__. They should work across as wide a range of devices and technologies — past, present, and future — as is practical.

When you read it, you'll notice that it feels like a much more modern approach. Here's an excerpt:

> When developers focus on technical specifications, they may achieve technical accessibility, but they may not achieve usable accessibility. To make a comparison, a large office building may be technically accessible to a person who is blind—meaning that this person may be able to walk through all the hallways, use the elevators, open the doors, etc.—but without an explanation (or perhaps a tactile map) of how the building is arranged, where the elevators and doors are, and which offices are on which floors, the building will be quite difficult to navigate, especially at first. The person may try to find locations through a process of trial and error, but this is a very slow and cumbersome process. The building is accessible, but not very usable.

> In a similar way, web developers can create web sites that are possible for people with disabilities to access, but only with great difficulty. The technical standards are important, but they may be insufficient on their own. Developers need to learn when and how to go beyond the technical standards when necessary.

Stop just applying techniques. Start solving problems for your users.

Doesn't that sound far more interesting?
