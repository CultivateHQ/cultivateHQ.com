---
title:  "Screen Readers"
author: Mark Connell
description: "Introducing screen readers: this is the first post in a series of posts focusing on accessibility and user experience considerations when developing for the web."
tags: accessibility
---

This is the first post in a series of posts focusing on accessibility and user experience considerations when developing for the web.

I'm kicking this off with a post demonstrating what a screen reader user experiences.

## Why a blog post on screen readers?
Knowing that screen readers exist and people use them, to actually become a screen reader user turned out to be an enlightening experience. I found that tasks which are normally relatively straight-forward, suddenly become just that little bit more tedious. Sometimes things can even be quite difficult to do. In worse-case scenarios, they can simply just be not possible to do.

My journey with screen readers began at the tail-end of last year while working on projects where screen reader accessibility was a requirement. Up until that point, I thought I had a pretty good handle on many aspects of web development including accessibility. Turned out I actually had quite a gap in my knowledge. For a bit of context, I've been making things for the web for about 15 years now, back when [Netscape](http://en.wikipedia.org/wiki/Netscape) was a thing, [WAP](http://en.wikipedia.org/wiki/Wireless_Application_Protocol) and smart phones were becoming a thing. And [Lynx](http://en.wikipedia.org/wiki/Lynx_(web_browser)) was that thing (and still is) to see how a text-only user / web scraper might see your site. Catering for different types of browsers; small screen sizes; or text only readers is one thing. To add in screen readers, requires some additional consideration for your users.

It's hard to describe some of the situations without going into detailed examples. So to get started, it's easier to fire up a screen reader and see for yourself the types of issues people encounter. I've created a short video just to show a comparison of trying to get to some latest sporting news as a normal user, to trying to acheive the same task with just a screen reader.

<iframe src="//player.vimeo.com/video/116171521" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

In the VoiceOver example from the video, you can see that by just having it enabled, the extra actions and the time to complete a task can become a bit of a frustrating experience. Now consider a process that requires a user to spend a few minutes filling in forms or navigating a substantial amount of content. Anything that can be done to reduce pain points and make things faster and easier for users, to me, is a worthwhile thing to be doing.

Here is quick rundown of some screen readers and some helpful links to point you in the direction of getting started with them.

## Mobile Screen Readers

### iOS
[VoiceOver](https://www.apple.com/uk/accessibility/ios/voiceover/) — Standard screen reader that is provided by apple. It's free, already on your device and just needs to be enabled to use.

### Android
[Talkback](https://support.google.com/accessibility/android) — This is the main screen reader for Android that is likely to already be installed on your device. If not, you can get it from the [Google Play store](https://play.google.com/store/apps/details?id=com.google.android.marvin.talkback).

It's worth noting that depending on your Android device and OS version, the user experience of TalkBack can be a bit different. We're fortunate to have [device lab](http://www.devicelab.org) in the same building as us which makes testing devices quite convenient. If you have access to a device testing lab, it is worth booking a short amount of time just to test out different devices for the experience.

## Desktop Screen Readers

### Apple Mac OS X
[VoiceOver](https://www.apple.com/uk/accessibility/osx/voiceover/) — This screen reader is build into every mac – no installation required. To enable it, you'll find it within 'System Preferences > Accessibility'. This is the screen reader I've mainly been using for testing purposes.

### Windows
For Windows machines, there are a number of free and paid-for products:

[JAWS](http://www.freedomscientific.com/Products/Blindness/JAWS) — This screen reader has been around for a number of years and from what I can tell, is possibly the most popular screen reader on the market.

[NVDA](http://www.nvaccess.org) — Another screen reader that has been around for a while, except is a free piece of software.

[Narrator](http://windows.microsoft.com/en-us/windows/hear-text-read-aloud-narrator#1TC=windows-8) — Like OS X, Windows 8 ships with it's own built-in screen reader. I've not seen it used as a screen reader for accessibility reports. This is not to disregard it, as it may still be useful to test with it for an alternative perspective.

### Linux
[Orca](https://wiki.gnome.org/action/show/Projects/Orca?action=show&redirect=Orca) — I've not had an opportunity to test screen readers on linux yet, but [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Web_applications_and_ARIA_FAQ) on [ARIA](http://www.w3.org/TR/wai-aria/) support, lists Orca with Firefox as a possibility to try.

Here is a more comphrensive [wikipedia article](http://en.wikipedia.org/wiki/List_of_screen_readers) listing available screen readers and what operating systems they work on.

## What Next?
So hopefully from reading this and watching my short video demo, I've intrigued you enough to go and have a play with a screen reader just to get a feel for how much effort is actually required for a user.

As a final tip, before you enable any of the built-in screen readers. It's worth taking a couple of minutes to read the documentation on how to navigate with the screen reader and it disable the reader if you need to!
