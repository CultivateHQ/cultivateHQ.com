---
author: Paul Wilson
title: JSON Serialisation of Ecto Models in Phoenix Channels (and views)
description: This week I upgraded from 0.13.x to 0.15.0 (through 0.14.x) and hit problems with models that I'd been sending over channels to the Javascript client. Here's how it panned out.
tags: elixir
date: 2015/08/11
---

I have an Phoenix app that is deliberately over-using channels, to see how far I can push it and shake out the gotchas.

Last week I upgraded from 0.13.x to 0.15.0 (through 0.14.x) and hit problems with models that I'd been sending over channels to the Javascript client.

```elixir
def handle_in("project_email_recipients", _, socket) do
  # Retrieves all the models for the project
  recipients = ProjectEmailing.project_recipients(
    socket.assigns[:project_id])
  {:reply,
    {:ok, %{project_email_recipients: recipients}},
    socket}
end
```

This was serialising  just fine and being received as maniputable JSON at the client. On upgrade it broke. On investigation I discovered that Ecto upgraded from 0.13.1 to 0.14.3. Under 0.13.1, a model's (Project model) ```__meta__``` value looks something like this:

```elixir
%Ecto.Schema.Metadata{source: "projects", state: :loaded}
```

Under 0.14.3 it looks like:

```elixir
%Ecto.Schema.Metadata{source: {nil, "projects"}, state: :loaded}
```
The [Poision encoder](https://github.com/devinus/poison/blob/master/lib/poison/encoder.ex) doesn't cope with the tuple, and leads to this error:

```bash
** (Poison.EncodeError) unable to encode value: {nil, "projects"}
    (poison) lib/poison/encoder.ex:213: Poison.Encoder.Any.encode/2
```

On reflection, serialising everything in the model record to JSON, including the ```__meta__``` field was silly; I should be more picky. There's two sensible ways to achieve this:

### Custom Poison Encoders

Implement the ```Poison.Encoder``` protocol for your model. eg

```elixir
defimpl Poison.Encoder, for: ProjectStatus.StatusEmail do
  def encode(model, opts) do
    model
      |> Map.take([:name, :id, :email, :subject, :content,
                   :project_id, :sent_date, :status_date])
      |> Poison.Encoder.encode(opts)
  end
end
```

Whenever the model is sent as payload on a channel (or as a JSON Object via a view) it will serialise to just those selected fields.

### Select the fields in the channel

Alternatively you might want to save bandwidth by providing just those fields required by the client. This tightly couples the _Phoenix Channel_ code to the client, but you might argue that it's tightly coupled in any case.

eg if the client only needs the model's ```id``` and ```subject``` fields.

```elixir
def handle_in("get_project_status_emails", %{}, socket) do
  status_emails = socket.assigns[:project_id]
    |> ProjectEmailing.project_status_emails
    |> Enum.map(&(Map.take(&1, [:id, :subject])))
  {:reply, {:ok, %{status_emails: status_emails}}, socket}
end
```

Right now I am going with the simpler first approach, _custom encoders_; I'll worry about bandwidth when it becomes a problem.
