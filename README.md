# Cultivate HQ Website

This is the codebase for the Cultivate website. We use middleman to generate a static website.

## Setting up

middleman is a ruby-based site generator, however there are javascript dependencies using bower.
You'll need to make sure you have node and npm installed.

    git clone git@github.com:CultivateHQ/cultivateHQ.com.git
    cd cultivateHQ
    ./bin/install_deps
    ./bin/serve

All being well, you'll have a server running on [localhost - port 4567](http://0.0.0.0:4567)

## Creating a new blog post

Two options are available.

The first wraps the `middleman article` command:

```
./bin/new_post "Title of your blog post here"
```

But remember to add the extra `date`, `author` and `description` front matter necessary to support Twitter Cards & OpenGraph (see below).

Also, if it's your first blog-post, add yourself to, or uncomment yourself from the `data/authors.yml`

Or use `bin/gen.rb` which is a wizard:

```
$ ./bin/gen.rb
Tell me your title
Well I don't have one
Who the hell are you?
Me of course
Ok, give me a brief description
Well, it will be a bit of this ... a bit of that
```

It will then open the new post in whatever editor you have configured in your `EDITOR` environment variable.

## Publishing Changes

We have had some issues now with using `middleman-deploy` to deploy over `sftp` to a static site. Issues as in it was missing all the stylesheets
and JavaScript or, on upgrading, it fails with a message saying that deploy is an old an usupported plugin type. So to deploy, run

```
./bin/deploy
```

Of course you will have had to have submitted your public ssh key to https://github.com/CultivateHQ/cultivate-infrastructure/blob/master/playbook/user_keys/public_keys
before the playbook was last run for you to have access to the server.

## Testing the deploy

Do a quick test to check the deploy has gone well:

* Go to https://cultivatehq.com. Does it look ok? Click round a few pages.
* Is the new content there?
* Check the console with developer tools. Any errors? Any resources failing to load?
* Check it on mobile

## Rolling back deployed changes

A dated version of the each deploy is put in `/home/static` on the server. Simply ssh in to `static@cultivatehq.com`,

```
rm -rf cultivatehq.com
mkdir cultivatehq.com
cd cultivatehq.com
tar -zxvf ../[the version you wish to restore]
```

## Twitter Cards & OpenGraph

This is about including extra meta tags within a blog post so that when you share a blog URL on Slack, Twitter or Facebook etc. they automatically show a nice feature _card_ with the title, description and optionally an image.

If you want to set an image for Twitter Cards (we're using [Summary with lage image](https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/summary-card-with-large-image)) and the [Open Graph protocol](http://opengraphprotocol.org/) (the image displayed when a blog post is shared in Facebook and other sites), set the `image` variable in the post's metadata. Example:

```
---
title: Getting started with Docker - images and containers
author: Fernando Briano
description: A quick guide to get you up and running with Docker.
tags: docker
image: /images/posts/docker.jpg
---
```

The image file should be placed in `source/images/posts` (or any other directory you create in `source/images`).

## Layout Styling

There are different layouts across each part of the Cultivate website. These are broken down as far as possible into modules.

Usually, just taking a look at another page and cloning it will be enough for you to get the right classes for the right layout, but below are some use case examples.

Aside from the blog posts, all pages will need HTML tweaks to keep the desired look and feel.

### Shout outs

If you want to create a "Shout out" panel, with the larger text (see About Us) as an example.

You can use this code to create a shout out div...

    <div class="shout-out">
      <p>Content in here</p>
    </div>

If you want a div with a line divider under it, add the `divider` class...

    <div class="shout-out divider">
      <p>Content in here</p>
    </div>

Both of these divs must be in inside a `page-layout` div for the font sizes and links to work properly.

e.g.

    <div class="page-content min-width padding-large">
      <div class="shout-out divider">
        <p>Content in here</p>
      </div>
    </div>

### Blog posts

For blog posts, I've kept it backwards compatible with all of the posts, code snippets work in the same way and so does the use of

    <section class="callout">
        Content in here
    </section>

Which gets put in a little grey box.

### Full Width content

In order to get a full width rows, you need to break the content div. For example, they should be a outer div and an inner div, one for the page layout one to set a minimum width, so you'd close those off then insert your row or testimonial code

#### Row

    <div class="row row--image-feature">IMAGE</div>

#### Testimonial
    <blockquote class="testimonial-quote-macro">
     <div class="min-width">
        <div class="testimonial-quote__image">IMAGE</div>
         Quote
         <cite>Cite</cite>
       </div>
    </blockquote>

 Then you'll need to re-open the page layout divs again e.g.

    <div class="page-content padding-large-top">
        <div class="min-width">
        Content
        </div>
    </div>
