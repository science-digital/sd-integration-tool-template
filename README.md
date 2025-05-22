# IVCAP "AI Tool" Demo

This repo template contains an implementation of a
basic _AI Agent Tool_ usable for various agent frameworks
like [crewAI](https://www.crewai.com).

The actual tool implemented in ths repo provides a simple test if a provided
number is a prime number or not.

* [Use](#use)
* [Test](#test)
* [Build & Deploy](#build)
* [Implementation](#implementation)

## Use <a name="test"></a>

Below is an example of an agent query which uses this tool:
```
{
  "$schema": "urn:sd-core:schema:llama-agent.request.1",
  "name": "Agent query test",
  "msg": "is 997 a prime number?",
  "tools": [
    "urn:sd-core:ai-tool:is_prime"
  ],
  "verbose": true
}
```

## Test <a name="test"></a>

In order to quickly test this service, follow these steps:

* `pip install -r requirements.txt`
* `make run`

```
% make run
env VERSION="v0.1.0|edd6b1f|2025-05-22T18:42+10:00" \
                poetry run python tool-service.py --port 8078
2025-05-22T18:42:03+1000 INFO (app): AI tool to check for prime numbers - v0.1.0|edd6b1f|2025-05-22T18:42+10:00 - v0.7.1
2025-05-22T18:42:03+1000 INFO (uvicorn.error): Started server process [85624]
2025-05-22T18:42:03+1000 INFO (uvicorn.error): Waiting for application startup.
2025-05-22T18:42:03+1000 INFO (uvicorn.error): Application startup complete.
2025-05-22T18:42:03+1000 INFO (uvicorn.error): Uvicorn running on http://0.0.0.0:8078 (Press CTRL+C to quit)
```

In a separate terminal, call the service via `make test-local` or your favorite http testing tool:
```
% make test-local
curl -i -X POST -H "content-type: application/json" --data "{\"number\": 997}" http://localhost:8078
HTTP/1.1 200 OK
date: Thu, 22 May 2025 08:42:39 GMT
server: uvicorn
job-id: urn:ivcap:job:1f036e8b-87d0-690a-b52a-7fc7a4ea5307
content-length: 67
content-type: application/json
ivcap-ai-tool-version: 0.7.1

{"$schema":"urn:sd:schema.is-prime.1","number":997,"is_prime":true}
```

A more "web friendly" way is to open [http://localhost:8078/api](http://localhost:8078/api)

<img src="openapi.png" width="400"/>

## Build & Deploy <a name="build"></a>

The tool needs to be packed into a docker container, and the, together with an IVCAP service description
deployed to an IVCAP platform.

> **Important**: If you adopt this repo template, please make sure to first change the first two variables
`SERVICE_NAME` and `SERVICE_TITLE` at the top of the [Makefile](./Makefile).


> **Note:** Please make sure to have the IVCAP cli tool installed and configured. See the
[ivcap-cli](https://github.com/ivcap-works/ivcap-cli) repo for more details.

The following [Makefile](./Makefile) targets have been provided

* `make docker-build`: Build the docker container
* `make service-register`: Published the container as well as registers the service

You may first want to locally test the build and execution of the docker container.

```
% make docker-build
Building docker image 'is_prime_tool-arm64'
docker build \
                -t is_prime_tool-arm64 \
                --platform=linux/arm64 \
                --build-arg VERSION="|6f2ada2|2025-03-05T14:06+11:00" \
                -f .../Dockerfile \
                ...
```

and then test it by first starting the docker service:

```
% make docker-run
Building docker image 'is_prime_tool-arm64'
docker build \
  ...
docker run -it \
                -p 8078:8078 \
                --platform=linux/arm64 \
                --rm \
                is_prime_tool-arm64 --port 8078
2025-05-22T08:43:39+0000 INFO (app): AI tool to check for prime numbers - v0.1.0|edd6b1f|2025-05-22T18:39+10:00 - v0.7.1
2025-05-22T08:43:39+0000 INFO (uvicorn.error): Started server process [1]
2025-05-22T08:43:39+0000 INFO (uvicorn.error): Waiting for application startup.
2025-05-22T08:43:39+0000 INFO (uvicorn.error): Application startup complete.
2025-05-22T08:43:39+0000 INFO (uvicorn.error): Uvicorn running on http://0.0.0.0:8078 (Press CTRL+C to quit)
```

and then in a different terminal to already above mentioned:
```
% make test-local
curl -i -X POST -H "content-type: application/json" --data "{\"number\": 997}" http://localhost:8078
HTTP/1.1 200 OK
...
content-length: 67
content-type: application/json

{"$schema":"urn:sd:schema.is-prime.1","number":997,"is_prime":true}%
```

## Implementation <a name="implementation"></a>

### [tool-service.py](./tool-service.py)

Implements a simple http based service which provides a `POST /` service endpoint to test
if the number contained in the request is a prime number or not.

We first import a few library functionss and configure the logging system to use a more "machine" friendly format to simplify service monitoring on the platform.

```
import math
from pydantic import BaseModel, Field
from pydantic import BaseModel, ConfigDict

from ivcap_service import getLogger, Service
from ivcap_ai_tool import start_tool_server, ToolOptions, ivcap_ai_tool, logging_init

logging_init()
logger = getLogger("app")
```

We then describe the service, who to contact and other useful information used whne deploying the service

```
service = Service(
    name="AI tool to check for prime numbers",
    contact={
        "name": "Max Ott",
        "email": "max.ott@data61.csiro.au",
    },
    license={
        "name": "MIT",
        "url": "https://opensource.org/license/MIT",
    },
)
```

The core function of the tool itself is accessible as `POST /`. The service signature should be kept as simple as possible.
We highly recommend defining the input as well as the result by a single `pydantic` model, respectively.
However, for a tool to be properly used by an Agent, we should provide a
comprehensive function documentation including the required parameters as well as the reply.

Please also note the `@ivcap_ai_tool` decorator. It exposes the service via `POST \`, but also a `GET /`
to allow the platform to obtain the tool description which can be used by agents to select the right
tool but also understand on how to use it.

```
class Request(BaseModel):
    jschema: str = Field("urn:sd:schema:is-prime.request.1", alias="$schema")
    number: int = Field(description="the number to check if prime")

class Result(BaseModel):
    jschema: str = Field("urn:sd:schema:is-prime.1", alias="$schema")
    flag: bool = Field(description="true if number is prime, false otherwise")

@ivcap_ai_tool("/", opts=ToolOptions(tags=["Prime Checker"]))
def is_prime(req: Request) -> Result:
    """
    Checks if a number is a prime number.
    """
    ...
    return Result(flag=True)
```

Finally, we need to start the server
to listen for incoming requests:

```
# Start server
if __name__ == "__main__":
    start_tool_server(service)
```

## [resources.json](./resources.json)

This file contains the resource requirements for this tool. This will depend on the computational and memory
requirements for the specific tool. If it is not provided a default will be used which is likely very similar
to this file.