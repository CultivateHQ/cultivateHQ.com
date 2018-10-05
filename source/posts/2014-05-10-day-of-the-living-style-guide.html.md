---
title:  "Day of the Living Style Guide"
author: Alan Gardner
description: A style guide or style manual is a set of standards for the writing and design of documents, either for general use or for a specific publication, organization or field. The implementation of a style guide provides uniformity in style and formatting within a document and across multiple documents.
tags: style guide
date: 2014/05/10
---

> A style guide or style manual is a set of standards for the writing and design of documents, either for general use or for a specific publication, organization or field. The implementation of a style guide provides uniformity in style and formatting within a document and across multiple documents. [http://en.wikipedia.org/wiki/Style_guide](http://en.wikipedia.org/wiki/Style_guide)

## The style guide as a paper document
The first time I worked with a style guide it was a paper document. The company that had been contracted to do the brand work and graphic design for the web site had handed over a folder containing a printed document that contained the style guide and a CD that contained all of the assets.

I thought this was great. We had clear direction and everything we needed to create a pixel perfect rendition of the website. Then reality hit: as the process of developing the website began, updates needed to be made and the design document had to be revised. This represented effort and friction, and so the style and the guide diverged.

## The style guide as an electronic document
The next incarnation of the style guide that I worked with was the electronic document, which was basically the pdf version of the paper document. Whilst this was easier to work with as a developer (because you could just copy and paste markup or hex codes into your HTML and CSS), from a maintenance and curation point of view nothing had changed. It was just as likely to go stale as its printed predecessor.

## We don't need no steenkeen' style guides ...
As a result of the above issues, I began to hate style guides. They went from being a useful tool to communicate intent between the graphic designers and the developers, to being an extra overhead to curate and maintain. As I was involved in more and more agile-style projects, style guides came to represent the big upfront design documentation of waterfall projects.

Besides, I had discovered a new and refreshing way of approaching web design; designing in the browser.

By designing in the browser the designers and developers worked collaboratively to built a website. Everyone sat in the same room, sometimes at the same desk, and worked things out as they went. Assets, elements and widgets were designed when they were needed and any design issues were worked out collaboratively as you hit them.

This approach works brilliantly and, as a result, I even more strongly associated style guides with the old, waterfall way of working.

## ... or maybe we do
The problem comes with scale. When there two or three people working together in the same room, a style guide loses its one key advantage; communication. As you add more people to a team, things start to get a little more chaotic. Pair A build a page that needs a Cancel button and so they create one. At the same time Pair B does the same. You now have two different Cancel buttons, which is easily fixed, but represents wasted time and effort.

So is there a way that we can retain the good parts of having a style guide (the communication, the single source of truth) whilst mitigating the bad parts (the maintenance overhead, the stagnation)?

## The style guide as a living document
The latest project that I worked on is the first on which I've used a living style guide. A living style guide is one that uses the same HTML and CSS that the website itself uses. Changing the style of the app automatically updates the style guide thus reducing the maintenance overhead to curating the adding of new elements/blocks/etc and the removal of old ones. The style guide does not become stagnant because it is being updated automatically every time the website itself is updated.

Now we have all the benefits of an agile, collaborative approach to designing the website, with all of the advantages of having that single point of truth for the design that the style guide gives us.

![Example Style Guide](/images/2014-05-10-style-guide.png)
