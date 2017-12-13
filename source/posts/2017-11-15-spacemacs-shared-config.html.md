---
title: Spacemacs shared configuration - custom private layers
author: Fernando Briano
description: How we use a shared configuration file for Spacemacs and managed to add personal configurations on each machine too.
tags: text editors
---

Some of us at Cultivate are using [**Spacemacs**](http://spacemacs.org/) as our preferred text editor. It really brings the best of two worlds together: Vim and Emacs. Most people at the office are used to Vim, I'm used to Emacs. With Spacemacs, we can toggle between the two with a single key stroke. Emacs can also be used in the terminal, so it made it easy for us to do pair programming via [tmate](https://tmate.io/) while I was working remotely.

Check Val's [Spacemacs Basic Setup for Ruby Development](/posts/spacemacs-basic-setup-for-ruby-development/) if you want to read more about how we use Spacemacs.

Since we started using Spacemacs, we've been keeping a shared configuration file. We started with the default `.spacemacs` file, modified it and added stuff we found useful along the way. The shared configuration has allowed us to have a familiar experience when pair programming in someone else's computer.

Sometimes we want to add custom configurations which don't necessarily need to go into the repo. For example, a theme. The way Spacemacs works, if each person uses a different theme from a different package, and adds it to the shared configuration, everyone would have each other person's theme installed in their local setup. The same goes for different modes, some more useful than [others](https://github.com/johanvts/emacs-fireplace). This may go against the idea of a shared configuration, so it's important to keep a balance between what goes into our custom configuration and what goes into the shared one, so the general experience doesn't differ that much between different computers.

In my particular case, I wanted Spacemacs to always start in Emacs mode. As I mentioned, most people are used to Vim, so it makes sense that the default setting is Vim. But it was annoying having to switch to `holy-mode` every time. So I started looking into ways of adding a custom configuration file to Spacemacs without adding it to our shared repository.

After some searching and reading, I found out about *private layers* in Spacemacs. It sounded a bit overkill at first, so I started writing an initial simpler solution. I'm not very good at elisp, so I had to try several different options before I could make it work, with some help from the community. The first attempt consisted of adding this short snippet in `dotspacemacs/user-config ()`, the configuration function for user code in `.spacemacs`:

```elisp
(when (file-exists-p "~/.personal-config.el")
  (load-file "~/.personal-config.el")
  )
```

This code will check for a `.personal-config.el` file in the user's home directory. If it exists, it will load it and run its code. I created a spacemacs-config repository to keep my notes and any custom stuff - a required feature of this custom configurations for me was to be able to keep it under version control too, just separate from the shared config. I added this file, and symlinked it from my home directory so that Spacemacs would find it.

This worked fine at first, but it still felt like I should be using private layers, Spacemacs' way of solving the personal configuration issue. I also wanted to install some new packages which may or may not make sense in the company wide shared configuration, and I couldn't find an easy way of doing it with the `personal-config.el` file approach. This looked like a good excuse to try using a private layer to solve this problem.

The content of the `private` directory in Spacemacs is ignored by Git and it's the default place to store private configuration layers. To create a new configuration layer, we need to call `configuration-layer/create-layer` (`M-x` in Emacs mode and `SPC SPC` in Vim mode). This asks us the directory where we want our layer to be and its name. It creates the directory, a `packages.el` file and (optionally) a `README.org` file. A cool thing I noticed while going through all of this is GitHub recognizes org-mode's files and parses their format just as with markdown.

Just like I did with the personal-config.el file, the directory for the personal configuration layer could be a symlink in `~/.emacs.d/private`. You can read about other options in [managing private configuration layers](http://spacemacs.org/doc/DOCUMENTATION.html#managing-private-configuration-layers) in Spacemacs' official documentation.

The first link you should take a look at before trying to write your own layer is in Spacemac's documentation: [Configuration Layers](https://github.com/syl20bnr/spacemacs/blob/master/doc/LAYERS.org). This blog post won't assume you read it though, but it's a good read for some context.

I named my layer `personal-config`, created it in my workspace folder and symlinked to it from `~/.emacs.d/private`.

### Installing packages

If you try to install packages "the Emacs way" in Spacemacs, you will find out it behaves in a peculiar way (unless you never restart Emacs). Usually you would use `list-packages` or `package-install`. But if you do, next time you start Spacemacs, it's going to remove any packages you've installed since it considers them "orphan". Spacemacs packages are managed from the `.spacemacs` file. You can either add a layer which includes a package, or add them to the `dotspacemacs-additional-packages` variable under the `dotspacemacs/layers` function in your dotfile.

By creating a private layer, you can install custom packages that are not going to be listed in the shared config. You can add packages to the `packages.el` file that was created for us when generating the new layer. This file must define a variable called `personal-config-packages` with a list of the needed packages.

```elisp
(defconst personal-config-packages
  '(
    fireplace
    )
```

 You can also add configuration to the packages, such as the location (local packages, ELPA compliant repositories, MELPA). You may define `pre-init`, `init` and `post-init` functions for each package to load and configure stuff. To get Spacemacs to automatically install the packages on boot, you need to define *at least* the `init` function.

```elisp
(defun personal-config/init-fireplace())
```

Just declaring the init function for each package will make Spacemacs install it on boot if it's not already installed.

### Custom functions

As the title says, there's a file for us to write our layer's custom functions. This is `funcs.el`. It's a good place to store functions we've written or found online. For example, I added the `open-with` function to open a visited file in the default external program [by Bod zhidar Batsov](http://emacsredux.com/blog/2013/03/27/open-file-in-external-program/).

### Configurations

For custom configurations, we have to create a `config.el` file. We use it to declare layer variables and general setup. This looked like the best file for me to include the Emacs as a default setting:

```elisp
;;; Set emacs mode as default
(setq dotspacemacs-editing-style 'emacs)
```

I also added some org-mode stuff, and the theme I wanted to use.

```elisp
;;; THEME
(spacemacs/load-theme 'gruvbox)
(load-theme 'gruvbox-dark-medium)
```

(I had to add the `gruvbox` package to my `packages.el` file for this to work):

### Keybindings

There is a file for custom keybindings, `keybindings.el`, where we can add stuff like this:

```elisp
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "M-h") 'backward-kill-word)
```

Since I'm the only Emacs user so far, most people won't use these two. But if another Emacs user started using our shared config, we should probably agree on keybindings such as `C-h` which overrides one of Emacs' keybindings.

### Anatomy of a layer

The order in which these files are loaded is: `layers.el`, `packages.el`, `funcs.el`, `config.el` and finally `keybindings.el`. Check [Anatomy of a layer](https://github.com/syl20bnr/spacemacs/blob/master/doc/LAYERS.org#anatomy-of-a-layer) to learn more. As you can see, I didn't use all these files for my private layer, just the ones that I needed.

### Wrap it all up

Once my `.el` files were done, the next step was to add my new layer to `.spacemacs`:

```elisp
   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
        ...
        personal-layer
        )
```

If everything went well, we can restart Spacemacs and any new packages we listed in `packages.el` should be installed, and our layer's configurations should be applied. We can also run `SPC f e R` (in Vim mode) or `M-m f e R` (in Emacs mode) to reload our dot file without restarting Spacemacs.

If you have any feedback or questions about this post, tweet at us [@cultivatehq](https://twitter.com/cultivatehq).
