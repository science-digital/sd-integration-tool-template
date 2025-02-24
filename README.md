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
env VERSION="|b0af9ba|2025-02-21T15:26+11:00" \
                python /Users/ott030/src/IVCAP/Services/ivcap-python-ai-tool/tool-service.py
2025-02-21T15:26:57+1100 INFO (app): AI tool to check for prime numbers - |b0af9ba|2025-02-21T15:26+11:00
2025-02-21T15:26:57+1100 INFO (uvicorn.error): Started server process [96586]
2025-02-21T15:26:57+1100 INFO (uvicorn.error): Waiting for application startup.
2025-02-21T15:26:57+1100 INFO (uvicorn.error): Application startup complete.
2025-02-21T15:26:57+1100 INFO (uvicorn.error): Uvicorn running on http://0.0.0.0:8094 (Press CTRL+C to quit)
```

In a separate terminal, call the service via `make test-local` or your favorite http testing tool:
```
% make test-local
curl -i -X POST -H "content-type: application/json" --data "{\"number\": 997}" http://localhost:8094
HTTP/1.1 200 OK
date: Fri, 21 Feb 2025 04:21:50 GMT
server: uvicorn
content-length: 4
content-type: application/json

true%
```

A more "web friendly" way is to open [http://localhost:8094/api](http://localhost:8094/api)

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
Building docker image 'is_prime_tool' for 'linux/arm64'
docker build \
                -t is_prime_tool:latest \
                --platform=linux/arm64 \
                --build-arg VERSION="|b0af9ba|2025-02-21T15:34+11:00" \
                -f .../Dockerfile \
                ...
```

and then test it by first starting the docker service:

```
% make docker-run
docker run -it \
                -p 8094:80 \
                --platform=linux/arm64 \
                --rm \
                is_prime_tool:latest
2025-02-21T04:35:27+0000 INFO (app): AI tool to check for prime numbers - |b0af9ba|2025-02-21T15:34+11:00
2025-02-21T04:35:27+0000 INFO (uvicorn.error): Started server process [1]
2025-02-21T04:35:27+0000 INFO (uvicorn.error): Waiting for application startup.
2025-02-21T04:35:27+0000 INFO (uvicorn.error): Application startup complete.
2025-02-21T04:35:27+0000 INFO (uvicorn.error): Uvicorn running on http://0.0.0.0:8094 (Press CTRL+C to quit)
```

and then in a different terminal to already above mentioned:
```
% make test-local
curl -i -X POST -H "content-type: application/json" --data "{\"number\": 997}" http://localhost:8094
HTTP/1.1 200 OK
...
content-length: 4
content-type: application/json

true%
```




## Implementation <a name="implementation"></a>

### [tool-service.py](./tool-service.py)

Implements a simple http based service which provides a `POST /` service endpoint to test
if the number contained in the request is a prime number or not.

We first configure the logging system to use a more "machine" friendly format to simplify service monitoring on the platform.

```
from ivcap_fastapi import getLogger, service_log_config, logging_init

logging_init()
logger = getLogger("app")
```

This is followed by a standard `FastAPI` service declaration:

```
# shutdown pod cracefully
signal(SIGTERM, lambda _1, _2: sys.exit(0))

title="AI tool to check for prime numbers"
description = """
AI tool to help determining if a number is a prime number.
"""

app = FastAPI(
    title=title,
    description=description,
    version=os.environ.get("VERSION", "???"),
    contact={
        "name": "Max Ott",
        "email": "max.ott@data61.csiro.au",
    },
    license_info={
        "name": "MIT",
        "url": "https://opensource.org/license/MIT",
    },
    docs_url="/api",
    root_path=os.environ.get("IVCAP_ROOT_PATH", "")
)
```

The core function of the tool itself is accessible as `POST /`. The service signature should be kept as simple as possible. However, to be properly used by an Agent, we should provide a
comprehensive function documentation including the required parameters as well as the reply.

```
@app.post("/")
def is_prime(number: int = Body(..., embed=True)) -> bool:
    """
    Checks if a number is a prime number.

    Args:
        number: The number to check.

    Returns:
        True if the number is prime, False otherwise.
    """
    ...
```

In addition to the main "tool" implementation we need two more service
endpoints to allow the platform to obtain the tool description (`GET /`)
as well as test the liveness of the agent (`GET /_healtz`).

```
@app.get("/")
def get_metadata():
    return create_tool_definition(is_prime)

# Allows platform to check if everything is OK
@app.get("/_healtz")
def healtz():
    return {"version": os.environ.get("VERSION", "???")}
```

Finally, we need to start the server to listen for incoming requests:

```
# Start server
start_server(app, title, is_prime, logger)
```


## [service.json](./service.json)

This file contains the necessary instructions for IVCAP to provision the
tool as an IVCAP service.

> **NOTE:** The placeholders `#SERVICE_ID#` and `#DOCKER_IMG#` which will
be resolved by the `make service-register` target