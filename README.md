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

## Setup

1. Clone the repository
1. Install `poetry` and add the `ivcap` plugin:
   ```bash
   pip install poetry
   poetry self add poetry-plugin-ivcap
   ```
1. Install the IVCAP cli tool. Instructions can be found [following this link](https://github.com/ivcap-works/ivcap-cli?tab=readme-ov-file#install-released-binaries).
1. Install dependencies:
   ```bash
   poetry install --no-root
   ```

## Test <a name="test"></a>

In order to quickly test this service, follow these steps:

* `poetry ivcap run`

```
% poetry ivcap run
Running: poetry run python tool-service.py --port 8078
2025-05-28T16:24:14+1000 INFO (app): AI tool to check for prime numbers - 0.2.0|b4dbd44|2025-05-28T16:24:13+10:00 - v0.7.2
2025-05-28T16:24:14+1000 INFO (uvicorn.error): Started server process [6311]
2025-05-28T16:24:14+1000 INFO (uvicorn.error): Waiting for application startup.
2025-05-28T16:24:14+1000 INFO (uvicorn.error): Application startup complete.
2025-05-28T16:24:14+1000 INFO (uvicorn.error): Uvicorn running on http://0.0.0.0:8078 (Press CTRL+C to quit)
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

## Deploying to Platform

Deployment is a three step process:
1. Building and deploying the docker image
1. Registering the service
1. Registering the tool description

### Building and Deploying the Docker image

Run `poetry ivcap docker-publish` to publish the docker image

```bash
$ poetry ivcap docker-publish
INFO: docker buildx build -t ivcap_python_ai_tool_template_amd64:9d0abdf --platform linux/amd64 --build-arg VERSION=0.2.0|b4dbd44|2025-05-28T16:27:56+10:00 --build-arg BUILD_PLATFORM=linux/amd64 -f Dockerfile --load .
[+] Building 0.9s (14/14) FINISHED
=> [internal] load build definition from Dockerfile
...
INFO: Image size 342.2 MB
Running: ivcap package push --force --local ivcap_python_ai_tool_template_amd64:9d0abdf
 Pushing ivcap_python_ai_tool_template_amd64:9d0abdf from local, may take multiple minutes depending on the size of the image ...
...
 45a06508-5c3a-4678-8e6d-e6399bf27538/ivcap_python_ai_tool_template_amd64:9d0abdf pushed
INFO: package push completed successfully
```

### Registering the service

Run `poetry ivcap service-register` to register the service

```
$ poetry ivcap service-register
Running: ivcap package list orffinder_amd64:5913361
Running: poetry run python tool-service.py --print-service-description
Running: ivcap aspect update --policy urn:ivcap:policy:ivcap.open.metadata urn:ivcap:service:5a4f9c92-cbf9-5251-bd35-4568906405ba -f /tmp/tmpt9grzxo8
INFO: service definition successfully uploaded - urn:ivcap:aspect:f6317920-2e7d-4a60-ae38-f9cc64e32649
```

### Register the AI Tool Description

Run `poetry ivcap tool-register` to register the tool description used by the AI agents.

```
$ poetry ivcap tool-register
Running: poetry run python tool-service.py --print-tool-description
Running: ivcap aspect update --policy urn:ivcap:policy:ivcap.open.metadata urn:ivcap:service:5a4f9c92-cbf9-5251-bd35-4568906405ba -f /tmp/tmp3089n2_e
INFO: tool description successfully uploaded - urn:ivcap:aspect:40fe880a-acdf-466e-a2ad-7d7cecb817fe
```

### Test deployed Service

Run `make test-job` to execute the service to check if '997' is a prime number (`{"number": 997}`):

```
% make test-job
TOKEN=eyJhbGciOiJSUzI1Ni.. \
        curl \
        -X POST \
        -H "content-type: application/json" \
        -H "Timeout: 20" \
        -H "Authorization: Bearer $TOKEN" \
        --data "{\"number\": 997}" \
        https://develop.ivcap.net/1/services2/urn:ivcap:service:3c51bd86-fd86-53bc-a932-91ff3a1e2fee/jobs?with-result-content=true | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    82  100    67    0    15      3      0  0:00:22  0:00:18  0:00:04    18
{
  "$schema": "urn:sd:schema.is-prime.1",
  "number": 997,
  "is_prime": true
}
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