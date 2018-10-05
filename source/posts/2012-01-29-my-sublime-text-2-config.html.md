---
title: My Sublime Text 2 Config
author: Mark Connell
description: Sublime Text 2 has been my editor of choice for about a year now. It's a great piece of software, but gradually I've been adding my own config options to make it just that little bit nicer for working with on a daily basis. I like it, and the guys in the office like it enough that it's the default config on our pairing machines at the moment.
tags: text editors
date: 2012/01/29
---

Sublime Text 2 has been my editor of choice for about a year now. It's a great piece of software, but gradually I've been adding my own config options to make it just that little bit nicer for working with on a daily basis. I like it, and the guys in the office like it enough that it's the default config on our pairing machines at the moment.

## Launching Sublime from the command-line
Sublime comes with a command-line tool named subl. For convenience, create a symlink to a directory that is in your `$PATH`. I have `/usr/local/bin` in my path, so I have a symlink that allows me to use `sublime some_file.txt`:

```bash
ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" /usr/local/bin/sublime
```

## Bash
If you want to make Sublime your default editor for things like git commit messages etc. Drop this into `~/.profile`:

```bash
export EDITOR='sublime -w'
```

## User Preferences
A summary of my preferences:
Soft tabs, 2 characters wide; White on Black text theme; Auto save when window loses focus; Trim unwanted whitespace.

Add the following snippet to `Preferences -> File Settings - User`:

```python
{
  "color_scheme": "Packages/Color Scheme - Default/Twilight.tmTheme",
  "font_face": "Monaco",
  "font_size": 12,
  "draw_white_space": "selection",
  "trim_trailing_white_space_on_save": true,
  "tab_size": 2,
  "translate_tabs_to_spaces": true,
  "tab_completion": true,
  "save_on_focus_lost": true,
  "highlight_line": true
}
```
