---
author: Valerie Dryden
title: Spacemacs: Basic Setup for Ruby Development
description: [DESCRIPTION GOES HERE]
---

# Spacemacs: Basic Setup for Ruby Development

[INTRO LINE GOES HERE]

## Installing the Ruby Layer

Spacemacs helpfully installed the Ruby layer automatically when on the opening of an .rb file. It can also be installed manually by adding ‘ruby’ to the .spacemacs file, in the configuration-layers section.

To open the config quickly, type SPC f e d. To reload the changes after saving type SPC f e R.

## RSpec

The ruby layer out of the box allows RSpec to be run inside of the Spacemacs environment, removing the need to swap between terminal tabs or sessions. The commands can be seen by typing SPC m t. At first, only a couple of options were displayed at first rather than the [full set in the documentation.](https://github.com/syl20bnr/spacemacs/tree/master/layers/%2Blang/ruby#rspec-mode)

The documentation suggests that we should choose RSpec as the ruby-test-runner to get a richer set of commands, but was a little confusing getting this to work.

These are the steps we need to follow to get this up and running:

#### 1. Update the .spacemacs file

We need to replace the previous ‘ruby’ declaration in the .spacemacs  configuration-layers section with a version that sets the test runner:

```
(ruby :variables
           ruby-test-runner 'rspec
           ruby-enable-enh-ruby-mode t)
```

At this point a richer set of commands were available but running them displayed usage instructions for Spring rather than the output of the tests.

#### 2. Add spring-commands-rspec

Add the 'spring-commands-rspec' gem to your gemfile 'test' group and bundle to fix this issue. You should now be able to run spec tests using commands such as SPC m t b etc.

### Pry

Note that if you use ‘debugger’ to drop to pry, be sure to focus the window with the breakpoint and then go to insert mode to use commands – making sure you are on the exact part of the window that says ‘byebug’.

## Rubocop

The ruby layer gives us Rubocop integration out of the box, however it does not enable a visual cue for errors on the screen.

To achieve this, uncomment the ‘syntax-checking’ layer in the .spacemacs config configuration-layers section and reload spacemacs. Putting the cursor on the highlights or underlines will explain the violation at the bottom of the screen.

## Tabs vs Spaces

To enable using 2 spaces instead of tabs, add this line to the .spacemacs configurations-layers section:

```lisp
(setq-default
	indent-tabs-mode nil
)
```
This helpful [Stack Overflow post](https://stackoverflow.com/questions/2111041/change-emacs-ruby-mode-indent-to-4-spaces) explains what to do if you need 4 spaces per tab. Tab width is set by layer, meaning you can have different settings for Python vs JavaScript vs Ruby etc.

## Column Width

In Atom it was nice to have a visual rule of 80 set on the screen, a feature not present in Spacemacs out of the box. Rubocop does a good job of alerting us of the violation but does not show how far beyond the limit we are.

The Emacs package [whitespace](https://www.emacswiki.org/emacs/WhiteSpace) will visually highlight characters that go over the default 80 character limit, as well as do some other useful highlighting like trailing whitespace.

Add this line to the .emacs.d/init.el file and reload spacemacs to pick up the change:

```lisp
(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)
```

The important part here is lines-tail, which will highlight and characters that are beyond the 80 character limit.
