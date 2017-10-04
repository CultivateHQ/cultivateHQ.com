---
author: Valerie Dryden
title: Spacemacs Basic Setup for Ruby Development
description: Brief intro into how to set up Spacemacs for Ruby development, including RSpec and Rubocop.
---

# Spacemacs: Basic Setup for Ruby Development

We each have our own environments and editors that we favour in the office and because we often pair, we get exposed to lots of new and exciting toys. Recently we had a situation where our colleague was remote working from Uruguay on a Linux machine (we all have Macs in the office) and was unable to use ScreenHero to screenshare his environment for pairing.

This prompted the other project members to learn [Spacemacs](http://spacemacs.org/), so that they could share terminal sessions using tmate/tmux, regardless of the operating systems being used. The great thing about Spacemacs is that you can easily toggle between Vim or Emacs mode, giving greater flexibility when pairing. It's much more of a cognitive leap to move from Vim to Emacs than it is to swap from Atom to VS Code, so this is really helpful.

My only exposure to Vim was through using it to do Git commits, I liked that I could edit text in place rather than having Atom pop up into the foreground. Other than that, I had certainly never considered using it as my main editor - I was just chuffed that I knew how to get it to close!

I was intrigued about what Spacemacs was like and heard a lot of buzz about it in the office, so I decided to dive in and give it a try myself. This is a short guide based on what I learned when I was setting up my Spacemacs environment for Ruby development.

## Installing the Ruby Layer

Emacs Version: 27.0.50
Ruby Version: 2.4.1

Spacemacs helpfully installed the Ruby layer automatically when on the opening of an .rb file. It can also be installed manually by adding ‘ruby’ to the .spacemacs file, in the configuration-layers section.

To open the .spacemacs config quickly, type `SPC f e d`. Be sure to reload the changes after saving using `SPC f e R`.

I was so happy to see that matching `do` and `ends` are highlighted, great news for people like me who tend to misplace these from time to time.

## RSpec

The ruby layer out of the box allows RSpec to be run inside of the Spacemacs environment, removing the need to swap between terminal tabs or sessions. The commands can be seen by typing SPC m t. At first, only a couple of options were displayed at first rather than the [full set in the documentation.](https://github.com/syl20bnr/spacemacs/tree/master/layers/%2Blang/ruby#rspec-mode)

The documentation suggests that we should choose RSpec as the ruby-test-runner to get a richer set of commands, but was a little confusing getting this to work.

We need to do a couple of things to get this up and running:

#### 1. Update the .spacemacs file

We need to replace the previous ‘ruby’ declaration in the .spacemacs  configuration-layers section with a version that sets the test runner:

```
(ruby :variables
           ruby-test-runner 'rspec
           ruby-enable-enh-ruby-mode t)
```

At this point a richer set of commands were available but running them displayed usage instructions for Spring rather than the output of the tests.

#### 2. Add spring-commands-rspec

Add the 'spring-commands-rspec' gem to your gemfile 'test' group and bundle. You should now be able to run spec tests using commands such as `SPC m t b` and so forth. So exciting!

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

In Atom it was nice to have a visual rule of 80 set on the screen and while Rubocop does a good job of alerting us of the violation,it does not show how far beyond the limit we are. We can use the toggile a visual rule on and off in Spacemacs using the fill-column-indicator, `SPC t f`. You can see other settings that can be toggled on and off by hitting `SPC t` and having a look at the options.

The Emacs package [whitespace](https://www.emacswiki.org/emacs/WhiteSpace) can also help us out by visually highlighting characters that go over the default 80 character limit, as well as do some other useful highlighting like trailing whitespace.

Add this line to the .emacs.d/init.el file and reload spacemacs to pick up the change:

```lisp
(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)
```

The important part here is lines-tail, which will highlight and characters that are beyond the 80 character limit.

We can toggle this off and on using `SPC t w`.

## Auto Insert Newline

We often want to [insert a newline](https://stackoverflow.com/questions/729692/why-should-text-files-end-with-a-newline) automatically at the end of a file. We can achive this in Spacemacs by adding the following lines to the user-config section of the .spacemacs file:

(setq-default
 require-final-newline t
 mode-require-final-newline t
)

## Fun in Space

I'm really enjoy using Spacemacs - I'm always accidentally finding new shortcuts and cool bits and bobs that make life a little easier. I hope this guide helps you get set up and you have a lot of fun, too!
