---
title: Open sourcing our shared configuration for remote pairing
author: Fernando Briano
description: We open sourced our shared configuration for tmux, Spacemacs and other tools we use daily for development
tags: tools, open source
date: 2018/07/12
---

We do pair programming a lot at Cultivate. Sometimes remotely, sometimes on the same computer. Looking for solutions to make remote pairing a smooth experience, we built our own shared configuration repository. This is a way to get a consistent experience across different systems with common tools. Switching computers should be cheap.

A while ago we decided to open source this shared configuration project, in the hopes it may become useful for anyone else and we can learn from users outside the company. You can find the [Cultivate Shared Config on GitHub](https://github.com/CultivateHQ/cultivate_shared_config).

## Text Editors

Having Vim and Emacs users among the developers, we decided to use [Spacemacs](http://spacemacs.org/), an Emacs distribution _"with Vim built-in"_. We tinkered around with a single `.spacemacs` file and added features, layers and different configurations. It became Spacemacs' default dot file plus a few things we knew most of us would use. Eventually it grew into something more customisable that you can read about here:
[Spacemacs shared configuration - custom private layers](/posts/spacemacs-shared-config/)

We also have configuration files for <a href="https://neovim.io/" target="_blank">Neovim</a>, because there's nothing like a text editor holy war to get your morning started.

## Remote sharing

We tried a few different tools for interacting remotely. Sharing your screen is rather easy nowadays thanks to WebRTC, all you need is a proper web browser. There are many services that provide audio and video calls and screen sharing such as [talky](https://talky.io/). But we needed a way to collaborate on the same source code.

We tried a few tools, and they really didn't work as smoothly as we expected. One of the biggest issues we found is most of them are not multi-platform. We use Mac and Linux in the team, so at least these operating systems needed to be supported.

We found out about [`tmate`](https://tmate.io/), a fork of `tmux` that allows you to share your terminal remotely. tmux is a terminal multiplexer which allows you to use several sessions inside a single terminal. Some of us already used tmux by the time we found tmate, so we added that tool to our set.

Our basic tmux configuration changes the commands prefix to `a`. So you run commands with `Ctrl + a` instead of the default of `b`. This was hard to get used to at first since `Ctrl + a` is a shortcut in the terminal and Emacs, but we also added a configuration to be able to send `Ctrl + a` to applications by pressing it twice.

tmate behaves just like tmux, except when you start a session it gives you an ssh command you can share for other people to connect to this session remotely. tmate and tmux can coexist in your system. So you can use tmux locally and start a tmate session when you need a remote pairing partner. It would be great to plug a running tmux session into tmate, but that's not supported yet. There's [an issue for it](https://github.com/tmate-io/tmate/issues/26) in the project's GitHub, so fingers crossed.

By default, tmate will use `tmate.io` as a server for the connection. But the [server side code](https://github.com/tmate-io/tmate-slave) is also free software, so you can host your own tmate server. The communication goes through ssh so it's mostly safe, but it's always a good idea not to rely on third parties for such important services. We set up a tmate server in our infrastructure, and we can all use it by default using our shared configuration.

I recently learned you can also share an Emacs server and open multiple `emacsclients` in different systems, having several cursors in the same file. I think this is interesting enough to check out eventually. But tmate has been working fine for us so far.

## Conclusion

Sharing a common configuration in a team makes pairing easier, both remote and locally, since everyone becomes familiar with a common set of tools. Even when you are unfamiliar with the operating system, keyboard, or general setup on a co-worker's computer, there's a common ground.

If you're interested, check out the repository and let us know what you think: [Cultivate Shared Config on GitHub](https://github.com/CultivateHQ/cultivate_shared_config). And If you have any feedback or questions about this post, tweet at us [@cultivatehq](https://twitter.com/cultivatehq).


