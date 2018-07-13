---
title: How we built a Visual Studio Code extension for IoT prototyping
author: "Dan Munckton"
date: 2018-07-13 10:40 UTC
description: "We recently had the opportunity to make a Visual Studio Code extension that needed to communicate with an embedded device. This post explains the architecture we chose to achieve that and the decisions that led to it."
tags: rust,iot,vscode
image: /images/posts/vscode-rust-iot/Artboard.svg
---

We recently had the opportunity to make a [Visual Studio Code](https://code.visualstudio.com/) extension that needed to communicate with an embedded device. This post explains the architecture we chose to achieve that and the decisions that led to it. We will also talk about how the [Rust language](https://www.rust-lang.org/) with standard I/O streams and the [serialport-rs crate](https://crates.io/crates/serialport) allowed us to glue everything together.

![Banner showing Rust, VSCode and a development board](/images/posts/vscode-rust-iot/Artboard.svg)

# The brief

Our client wanted us to build a VSCode extension that would provide an IDE, with a good user experience, for their customers prototyping firmware with JavaScript on their IoT devices.

Our client's firmware already supported a serial protocol for uploading, deleting, listing and running scripts. We needed to make these use cases possible from within the Visual Studio Code IDE.

# How does a Visual Studio Code extension work?

In case you've not come across it yet, [Visual Studio Code](https://code.visualstudio.com/) is an advanced text editor, armed with features to make developers' lives easier. It is written in the [TypeScript](http://www.typescriptlang.org/) superset of JavaScript, on top of the [Electron](https://electronjs.org/) platform. Electron makes it possible to use JavaScript, HTML and CSS for cross-platform development of desktop applications, and is essentially an integration of [Chromium](https://www.chromium.org/) and [Node.js](https://nodejs.org/en/).

An extension allows third parties to add new features to the editor, e.g. to support languages not in the core editor, or integrations such as the one proposed here.

Extensions are built as [Node.js modules](https://docs.npmjs.com/getting-started/creating-node-modules) in JavaScript (or anything that transpiles to JavaScript). To be able to load an extension, Visual Studio Code expects an extension module to provide a custom `package.json` file containing extra properties that describe the features that the extension provides. The extension module must also export a function called "activate", which the editor calls when an extension should be loaded. You can configure an extension to load for various reasons, e.g. when a file of a certain type is opened or if the user takes a certain action in the user interface.

I won't go deeper than this, as they have [an excellent guide to extension building](https://code.visualstudio.com/docs/extensions/overview) in the Visual Studio Code docs.

# Problem: how to integrate with native code?

Some native code was going to be necessary somewhere in the architecture in order to bridge from the TypeScript application code to operating system services for serial communication. The question was, where?

One option was to use the [serialport Node.js extension](https://www.npmjs.com/package/serialport). This is a native Node.js extension written in C++. It presents a JavaScript API binding to call into its native code directly from JavaScript executing in the Node.js virtual machine. Its C++ code interfaces with operating system services to perform serial I/O and port discovery for JavaScript.

This would be very convenient for the extension as the API is relatively simple and even supports notifications for hotplugging of devices.

However, it had two important costs:

* It complicated the build process - we could not rely on the normal native compilation that happens when npm installs the package on your system. The C++ code needs to be recompiled separately for the exact ABI (application binary interface) version of the Node.js embedded in the version of Electron currently used by VSCode. See [Using Native Node Modules](https://github.com/electron/electron/blob/master/docs/tutorial/using-native-node-modules.md) for more.
* If and when VSCode updates the version of Electron it depends upon, the extension would need to be recompiled. This could force our customer to make a maintenance release of their extension, possibly at a point in time when they would not otherwise have needed to. Even if this might be an infrequent occurrence, it is an inconvenience we preferred not to pass on to their maintenance team.

The other option was to use a separate executable. We had already seen this being done successfully in [Microsoft's Arduino extension](https://github.com/Microsoft/vscode-arduino/) which [executes the CLI build tools](https://github.com/Microsoft/vscode-arduino/blob/0dc710ab8c7725bf1ff88becb038e6934ea49899/src/arduino/arduino.ts#L96) from the [Arduino IDE](https://www.arduino.cc/en/Main/Software) in order to compile and upload Arduino sketches.

This capitalises on two ubiquitous integration mechanisms: child process execution and interprocess communication via the standard I/O streams (stdin, stdout and stderr). These facilities are present both in Windows and in all Unix-derived operating systems.

If we used these standard integration mechanisms we (and ultimately our customer) would *own* the interface between the extension and our native code and would never need to change it due to external forces.

So we chose the second option and built an out-of-process executable to handle this part of the integration.

An added benefit was that the command line executable would easily enable other integrations. Indeed, before our project was finished our customer had already started using the command line tool in parts of their hardware test harness and created a proof of concept Emacs extension.

# Problem: distributing the native code

Because we need to ship native code, we have to find a way to bundle a build of the executable compiled for each platform we want to support.

We surveyed what existing extensions were doing about this:

* [Microsoft's C/C++ extension](https://github.com/Microsoft/vscode-cpptools) downloads a platform-specific version of the Intellisense binary as part of its first run activation.
* The [Rust RLS extension](https://github.com/rust-lang-nursery/rls-vscode) prompts the user to install the toolchain and Rust Language Server if it cannot detect them when it activates.

Both are very nice because they avoid shipping redundant binaries to users. However, we didn't want to force our customer to host binaries for download separately to the extension.

Also, for the initial release our client wanted to ship the extension to their customers outside of the public marketplace. So for the sake of simplicity, we decided to bundle the executable within the extension package, and build a package for each of the three supported platforms.

# Why Rust?

The next decision was whether to use C/C++ or Rust for the command line executable.

Our team was made up of developers with experience of C/C++ systems engineering *and* developers for whom this was their first systems-level project and statically compiled language.

Both appreciated the extra comfort, guidance and security provided by the Rust compiler. Rust allowed the experienced developers to move fast and develop features quickly with less errors, and allowed those exploring systems development for the first time to move forward with confidence, curiosity and protection from the "gotchas" of C/C++.

Additionally, Rust's tooling ([rustup](https://doc.rust-lang.org/book/second-edition/ch01-01-installation.html) and [cargo](https://doc.rust-lang.org/book/second-edition/ch01-03-hello-cargo.html)) made cross platform development a breeze. No complicated Makefiles, no need to adapt for different compilers from platform to platform and easy standardised integration of third-party libraries from [crates.io](https://crates.io/). [Cargo](https://doc.rust-lang.org/cargo/) got us from zero to code quickly and [Rust's built-in testing facilities](https://doc.rust-lang.org/book/second-edition/ch11-00-testing.html) gave us all we needed to test-drive our features.

# The outcome

![End to end architecture diagram](/images/posts/vscode-rust-iot/Diagram.svg)

The diagram above shows the end-to-end architecture.

The extension itself runs inside Visual Studio Code's "Extension Host" process. The Rust code is a separate executable that the extension spawns when the user executes commands in the editor UI.

![Diagram showing the integration between the Rust binary and VSCode extension](/images/posts/vscode-rust-iot/detail.svg)

Each command in the extension, e.g. List Serial Ports, Send Files and so on, maps to a subcommand in the Rust executable. By subcommand I mean we use a git/svn-style command line user interface, where the first argument to the executable is the name of a specific action to take, like this:

```shell
cli list-ports

cli send-files <port name> <list of files …>

cli monitor <port name>
```

Each subcommand takes additional arguments for serial port (COM port on Windows, device path on Unix) and the [baud rate](https://en.wikipedia.org/wiki/Baud).

For short-lived commands, input passes from the extension's command handlers to the Rust executable via command line arguments. We used the excellent [clap crate](https://clap.rs/) to handle command line parsing for us in Rust. Output is then obtained by reading the standard output stream from the Rust child process.

For long-lived commands such as the serial-monitoring feature, the Rust executable is spawned and stays running until the user explicitly runs a "stop monitoring" command. At that point the extension closes the child process's stdin stream, signaling to Rust that it should now stop monitoring and shut down. While it is running we are able to channel input from the user over the Rust child process's stdin stream. Output from the attached device is streamed over the stdout stream from Rust, then read in the extension and displayed in an editor output pane.

We were able to make great use of the [serialport-rs crate](https://crates.io/crates/serialport) to do the actual serial I/O in Rust. This was great as it abstracts the differences in serial I/O across Unix and Windows platforms and pretty much gave us cross-platform support for Mac, Windows and Linux for free. Since our client project finished we have made some open source contributions back to this excellent project ([here](https://gitlab.com/susurrus/serialport-rs/merge_requests/40) and [here](https://gitlab.com/susurrus/serialport-rs/merge_requests/46)).
