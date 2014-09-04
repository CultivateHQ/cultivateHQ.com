---
  title: "Rails 3: HTML Escaping"
  author: Mark Connell
  description: So you've been working on Rails apps for a while, and like all good developers, you've been escaping any content rendered in your views that your application's users might have entered, right?
---

## Rails 2
So you've been working on Rails apps for a while, and like all good developers, you've been escaping any content rendered in your views that your application's users might have entered, right?

eg. like this:

```erb
<%= h some_string %>
```

## Rails 3
Now in Rails 3, all strings are html escaped automatically, so:

```erb
<%= h some_string %>
# is now
<%= some_string %>
```

No string by default is considered safe to render, and subsequently are HTML escaped. If you need to render html without it being escaped you need to effectively whitelist it as safe to render. This is done via `.html_safe`

    <%= some_string.html_safe %>


For a more detailed explanation, checkout:
[SafeBuffers and Rails 3.0 by Yehuda Katz](http://yehudakatz.com/2010/02/01/safebuffers-and-rails-3-0/)
