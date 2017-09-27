---
author: Paul Wilson
title: Communicating with C from Elixir using Ports
description: On occasion your Elixir is going to want to interact with an external program. This may be for speed, but more likely you are going to want to take advantage of a library that has been written in C. The most common options are using Ports and Native Interface Functions (NIFs).
---

On occasion your Elixir is going to want to interact with an external program. This may be for speed, but more likely you are going to want to take advantage of a library that has been written in C. The most common options are using [Ports](http://erlang.org/doc/tutorial/c_port.html) and [Native Interface Functions (NIFs)](http://erlang.org/doc/tutorial/nif.html).

Let's write a simple port example with a C application that just echoes back whatever is sent to it. Warning: there's going to be a lot more C than Elixir.

(The examples were developed with Elixir 1.5.1 and Erlang 20.1, though it really should not make any difference. The C is standard ANSI with some POSIX headers.)

## Step 1 - Create our Mix project with some C inside

```elixir
mix new porty --sup
```

[`elixir_make`](https://hex.pm/packages/elixir_make) simplifies compiling from a `Makefile` as part your Elixir compilation, so let's include that in our `mix.exs` `deps` and them run `mix deps.get`.

```elixir
defp deps do
  [
    {:elixir_make, "~> 0.4"},
  ]
end
```

And we are going to want to include `elixir_make` as a project compiler with the line `compilers: [:elixir_make | Mix.compilers],`:

```elixir
def project do
  [
    app: :porty,
    version: "0.1.0",
    elixir: "~> 1.5",
    start_permanent: Mix.env == :prod,
    compilers: [:elixir_make | Mix.compilers],
    deps: deps()
  ]
end
```

Next we will need a `Makefile` in the project root.

```
CFLAGS= -g

HEADER_FILES = src

SRC =$(wildcard src/*.c)

OBJ = $(SRC:.c=.o)

DEFAULT_TARGETS ?= c_priv priv/c/echo

priv/c/echo: c_priv $(OBJ)
	$(CC) -I $(HEADER_FILES) -o $@ $(LDFLAGS) $(OBJ) $(LDLIBS)

c_priv:
	mkdir -p priv/c

clean:
	rm -f priv/c $(OBJ) $(BEAM_FILES)
```

This will compile C files in the directory `src/` and create an executable in the directory `priv/c`. So, we'd better give it something to compile

`src/echo.c`

```c
#include<stdio.h>

int main(int argc, char *argv[]) {
  printf("Hello you fake Port program.\n");
  return 1;
}
```

Now if we run `mix compile` we should get an executable `priv/c/echo`. Calling `./priv/c/echo` will print out our "hello" message.


## Step 2 - Write the C program

> **tl;dr** a full C program is in [here](https://github.com/paulanthonywilson/portynif/blob/master/apps/porty/src/echo.c).

### Reading from `STDIN`

We have our executable, but it is not suitable for communicating over _erlang ports_, which use `STDIN` and `STDOUT` for communication with the Erlang VM. Let's write a C function for reading a fixed number of bytes from `STDIN`.

```c
#include <unistd.h>
#include <err.h>
#include <errno.h>
#include <stdlib.h>

int read_fixed(char *buffer, int len) {
  int read_count = 0;
  while(read_count < len) {
    int this_read = read(STDIN_FILENO, buffer + read_count, len - read_count);

    // 0 is returned from read if EOF is STDIN has been closed.
    if (this_read == 0) {
      return -1;
    }

    // errno is set to EINTR if interrrupted by a signal before any data is sent, otherwise
    // there has been an error.
    if(this_read < 0 && errno != EINTR) {
      err(EXIT_FAILURE, "read failed");
    }
    read_count += this_read;
  }
  return len;
}
```

Bytes are read from stdin up to `len` characters using the Unix [read](https://linux.die.net/man/2/read) function into the `buffer`. The code is a little more complicated than otherwise, as we are handling the case of a read being interrupted by a signal. Checking for 0 being returned from read is very important, otherwise when you close the port (or the Erlang VM node) the read loop will become infinite, turning the process into a CPU-eating zombie.

To round it all off, here's a function to read a fixed length message from `STDIN` and zero-terminate the buffer.

```c
void read_in(char *buffer, int len) {
  read_fixed(buffer, len);
  buffer[len] = '\0';
}
```

We can now read data for a certain length from `STDIN`, but how do we know what length that is? We will configure our `port` such that the first two bytes tell us the length of the remaining. Here is a function for reading those first two bytes and returning that length. Note that the most significant byte is the first.

```c
int to_read_length() {
  unsigned char size_header[2];
  int r = read_fixed((char*) size_header, 2);
  if(r < 0) {
    return -1;
  }
  return (size_header[0] << 8) | size_header[1];
}
```


As Columbo might say, just one more thing: how do we know that we have something useful to read? We will make use of [poll](https://linux.die.net/man/2/poll):

```c
#include <unistd.h>
#include <poll.h>

int poll_input() {
  int timeout = 5000;
  struct pollfd fd;
  fd.fd = STDIN_FILENO;
  fd.events = POLLIN;
  fd.revents = 0;
  return poll(&fd, 1, timeout);
}
```

`poll` above will block for 5 seconds (5,000 milliseconds) for data to become available, specified by the `POLLIN` flag. It will return 1 (`POLLIN`) if data is available, or 0 in case of timeout.


Now we should be able to read messages from our Elixir program, and do something with them. For now let's just print them to `STDERR`. (Printing to `STDERR` is helpful for developemnt and debugging; like `IO.inspect`s, we will remove these from the final version.

```c

#define MAX_READ 1023

int main(int argc, char *argv[]) {
  char buffer[MAX_READ + 1];
  for(;;) {
    int res = poll_input();
    if(res > 0) {
      int len = to_read_length();
      if (len > MAX_READ) {err(EXIT_FAILURE, "Too large message to read.");}

      // len being less than zero indicates STDIN has been closed - exit
      if (len < 0) {return 1;}

      read_in(buffer, len);
      fprintf(stderr, "%s\r\n", buffer);
    }
  }
}
```

Above we are looping constantly, reading from `STDIN` and echoing the result out to `STDERR`, if anything is available. (Note that I've left out forward references and includes; if you are coding along then grab them from [here](https://github.com/paulanthonywilson/portynif/blob/master/apps/porty/src/echo.c)).

Let's give it a spin

```elixir
iex -S mix

iex> port = Port.open({:spawn, :code.priv_dir(:porty) ++ '/c/echo'}, [{:packet, 2}])
#Port<0.513>
iex> Port.command(port, "hello matey")
hello matey
true
iex> Port.close(port)
```

Note a couple of things:
 * We set the packet size to 2 above. This is how we configure the port to prepend the length of the message using two bytes at the beginning.
 * We find the executable with `:code_priv_dir(:porty) ++ '/c/echo'`. This will allow us to find it even when we are packaged for a release.

### Writing back to Elixir through `STDOUT`

Not too surprisingly, writing back is similar to the reading. Let's start with a function to write a fixed length buffer to `STDOUT`

```c
void write_fixed(char *msg, int len, char *reason) {
  int written = 0;
  while(written < len) {
    int this_write = write(STDOUT_FILENO,  msg + written, len - written);
    if (this_write <= 0 && errno != EINTR) {
      err(EXIT_FAILURE, "%s: %d", reason, this_write);
    }
    written += this_write;
  }
}
```

Similar concerns to the reading, apply concerning signal interruptions. A closed socket will cause an error, in this case, so there is less need to worry about infinite loops.

When writing we also need to prepend the size of the message using the first two bytes.

```c
void write_back(char *msg) {
  unsigned long len = strlen(msg);
  char size_header[2] = {(len >> 8 & 0xff), (len & 0xff)};
  write_fixed(size_header, 2, "header write");
  write_fixed(msg, len, "data write");
}
```

We are now ready to string it all together, and echo back what has been sent to us instead of printing to `STDERR`.

```c
int main(int argc, char *argv[]) {
  char buffer[MAX_READ + 1];
  for(;;) {
    int res = poll_input();
    if(res > 0) {
      int len = to_read_length();
      if (len > MAX_READ) {err(EXIT_FAILURE, "Too large message to read.");}

      // len being less than zero indicates STDIN has been closed - exit
      if (len < 0) {return 1;}

      read_in(buffer, len);
      write_back(buffer);
    }
  }
}
```

Let's give it one more spin. Note that messages coming from the port are received as messages to the owning process.

```
iex -S mix

iex> Process.flag(:trap_exit, true)
false
iex> Port.open({:spawn, :code.priv_dir(:porty) ++ '/c/echo'}, [{:packet, 2}])
#Port<0.4973>
iex> Port.command(port, "hello sailor")
true
iex> flush
{#Port<0.4973>, {:data, 'hello sailor'}}
:ok
iex> Port.close(port)
true
iex> flush
{:EXIT, #Port<0.4973>, :normal}
:ok
iex>
```

Notice that the string is coming through as a character list, rather than a binary.

Now we have communication between a C program and Elixir. The example project is [here](https://github.com/paulanthonywilson/portynif/tree/master/apps/porty), with some tested Elixir code.

A real port would of course be more sophisticated and involve encoding commands and data into the messages.

## References

The following resources were useful while investigating this:

* [The Erlang Port Documentation](http://erlang.org/doc/tutorial/c_port.html)
* [Ports vs. NIFs](https://spin.atomicobject.com/2015/03/16/elixir-native-interoperability-ports-vs-nifs/) by Tony Baker at [Atomic Object](https://atomicobject.com) was a good starting point, but is now quite out of date.
* [The Elixir ALE project](https://github.com/fhunleth/elixir_ale) uses Ports to communicate with hardware on Linux. The source code is great for poking around.
* Reading the documentation of [read](https://linux.die.net/man/2/read), [write](https://linux.die.net/man/2/write) and [poll](https://linux.die.net/man/2/poll) helped.
