---
  layout : post
  title  : How to clear an elasticsearch index
  author : Mark Connell
---

In the event you need to tear down your elasticsearch index, there is a web API that you can take
advantage of to make this fairly straight forward:

```bash
curl http://localhost:9200/_mapping
> {"app_name":{"resource": {"123": "some-value"}}}
```

Making a GET request like the one above, where `localhost:9200` is the web interface of your elasticsearch
server, will return a mapping of all the indexes currently available on the server. To delete a specific mapping,
simply send a DELETE request to the server with the path to the index tacked on to the URL. eg.

```bash
curl -XDELETE http://localhost:9200/app_name/resource/123
```

or to delete a parent index and associated child indexes:

```bash
curl -XDELETE http://localhost:9200/app_name
```
