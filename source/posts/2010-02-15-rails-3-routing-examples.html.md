---
title: "Rails 3: Routing Examples"
author: Mark Connell
description: Rails 3 introduced a new routing DSL that is a little bit different from the Rails 2 version. This quick guide covers a few examples of the new routes, and how they compare to Rails 2.
tags: ruby
date: 2010/02/15
---

> This post was written prior to Rails 3 being released and may contain information that is now out of date.

Rails 3 introduced a new routing DSL that is a little bit different from the Rails 2 version. This quick guide covers a few examples of the new routes, and how they compare to Rails 2.

## Simple routes

Create a basic route that will respond to `http://localhost:300/hello_world`

```ruby
# Rails 2:
map.connect 'hello_world', :controller => 'posts', :action => 'index'

# Rails 3:
match 'hello_world' => 'posts#index'
```

## Resources

A `UsersController` that responds to the typical RESTful actions `/users`, `/users/123`, `/users/123/edit` etc.

```ruby
# Rails 2:
map.resources :users

# Rails 3:
resources :users
```

Add additional `member` and `collection` actions to a resource. For a `GamesController`, adding a download action on a particular game (member) and a favourites action to display a list of favourite games (collection):

```ruby
# Rails 2
map.resources :games, :member => { :download => :get }, :collection => { :favourites => :get }

# Rails 3
resources :games do
  get :download,   :on => :member
  get :favourites, :on => :collection
end
```

`member`/`collection` blocks are also available as an alternative to the above:

```ruby
# Rails 3
resources :games do
  member do
    get :download
  end

  collection do
    get :favourites
  end
end
```

## Root mappings
The `root_url` your app points to eg. `http://localhost:3000/`

```ruby
# Rails 2
map.root :controller => 'posts', :action => 'index'

# Rails 3
root :to => 'posts#index'
```

Namespaced root mappings eg. `http://localhost:3000/admin`

```ruby
# Rails 2
map.namespace :admin do |admin|
  admin.root :controller => 'posts'
end

# Rails 3
namespace :admin do
  root :to => "admin/posts#index"
end
```

One thing to note is that if you are defining a root mapping in a namespace, it doesn't make any assumptions that the controller is in the same namespace in Rails 3.

## Optional params
Allows a mapping to be associated with multiple routes eg: `/posts/2010` and `/posts/2010/02`

```ruby
# Rails 2
map.connect 'posts/:year/:month', :controller => 'posts',
            :month => nil, :requirements => { :year => /\d{4}/ }

# Rails 3
match 'posts/:year(/:month)' => 'posts#index', :constraints => { :year => /\d{4}/ }
```

You'll notice that this mapping also makes use of the :constraints option rather than :requirements which would be found in a Rails 2 app.
