---
author: 'Valerie Dryden and Alan Gardner'
title: 'Putting a Phoenix in your Jira'
description: 'How we added features to Jira via a Phoenix app.'
date: 2019/01/22
tags: elixir, phoenix, jira
---

# Wait ... what?

The question most likely fighting to be asked right now is "Dear god why?" and we'd entirely forgive you for asking this. Why indeed would one want to stick a Phoenix application into Jira? What do we even mean by that? It would probably help if we started by telling you what we were trying to accomplish before we move on to how we set about doing so.

As a consultancy we use a variety of project management tools depending on the client we're working with. One of those tools happens to be Jira. We also have a standard way (when possible) of reporting progress towards goals; the [burnup chart](). Whilst Jira does have burnup charts, one of the clients we are currently working with works in sprints, and Jira will only give you burnups for a given sprint not towards a given release (yes, we know that the sprint should _be_ the release but let's for know acknowledge that life is rarely ideal and that we have good, pragmatic reasons for not following this rule). So, what we want to do is to build our own burnup chart that will let us view the chart that we want and to easily share this with the client.

As a first pass at this we created a Python script that hit the Jira REST API and copied the current day's progress values to the clipboard. We then paste that into a Google Sheet which collates all the entries we've pasted over time and displays a chart. We then link to this chart in our daily email. We can have a chart per release and so multiple teams working on different releases can show their progress on a chart.

Jira has the concept of [Connect apps](). These are applications that can be written in any language that can be registered with Jira through an uploaded JSON config file. This will then place a link in the sidebar in Jira that, when clicked, will display the given URL within an iframe to the right of the sidebar. That means that you can serve pretty much anything you like, such as a custom burnup for example, as long as it works inside of an iframe.

# The moving parts

## A Phoenix umbrella app

## Deploy/serve app somewhere Jira can see

## Atlassian Connect requirements

```json
// apps/see_ra_web/assets/static/atlassian-connect-staging.json
{
  "name": "See-Ra",
  "description": "A tool that interacts with Jira to give you insights",
  "key": "com.cultivatehq.see-ra",
  "baseUrl": "https://see-ra-staging.herokuapp.com",
  "vendor": {
    "name": "Cultivate",
    "url": "http://cultivatehq.com"
  },
  "authentication": {
    "type": "none"
  },
  "apiVersion": 1,
  "modules": {
    "generalPages": [
      {
        "url": "/",
        "key": "see-ra",
        "location": "system.top.navigation.bar",
        "name": {
          "value": "See-Ra"
        }
      }
    ]
  }
}
```

Now make it publicly available by opening **apps/see_ra_web/lib/see_ra_web/end_point.ex**

```elixir
plug Plug.Static,
  at: "/",
  from: :see_ra_web,
  gzip: false,
  only: ~w(css fonts images js favicon.ico robots.txt atlassian-connect-staging.json)
```

In Jira:

1. Jira settings
2. Apps
3. Manage apps

First time you need to click Settings and "enable development mode".

Click upload button and point to <https://your-url.com/atlassian-connect-staging.json>

Once it's installed you should see a button titled See-Ra that will show your app in the main page. However we have some more work to do before we can do that.

## Displaying something in the Jira iframe

1. Create a plug to remove "X-Frame-Options" (see mini bloggo)
2. Add all.js and the css file
3. Create a section with the class required to resize the iframe to fit the available space

## Jira REST APIs

# Wiring everything together
