# Sciansa Tool Integration

If you are new to development for Sciansa see (https://github.com/csiro-internal/sciansa-integration) for higher level
topics.


# Design

Before integrating your tool into Sciansa make sure you consider how your tool will fit into the system architecture.
Ultimately Sciansa is a modular system with each unit having inputs and outputs. How well you define your tools
abstraction and the precision of the inputs and outputs for your tool module will effect how useful your tool is within
the Sciansa ecosystem. Higher level modular design principles can be found in
(https://github.com/csiro-internal/sciansa-integration).


# Beginners

If you are just starting out it is recommended that you use this repo as a template to guide your development. This repo
is a GitHub template TODO explain how to use GitHub template.

This guide targets developers who want to integrate classical tools with well defined inputs and outputs. If you want to
support an agent interaction pattern see the
[Hybrid section in the Sciansa Docs](https://github.com/csiro-internal/sciansa-integration?tab=readme-ov-file#hybrid-advanced)


# Assessing Integration Complexity

The following list will help you to identify how complex it will be to integrate your tool with Sciansa:
- Dependencies: How well do you understand your dependencies? Have you tried to put your technology in a Docker
                container?
  - Tools with well understood dependencies or have been containerised before are easier to integrate.
- Dependency Compaitability: Is the tool compaitable with the Sciansa dependency set? See: [Technologies](#technologies)
  - Identify any significant incompaitabilities between the dependencies used by Sciansa and the technologies that you
    use.
- State: Does the tool maintain an internal state or is is stateless?
  - Stateless tools are easier to integrate then tools that require state preservation between calls.
- Resources: What are the compute resources required?
  - If your tool requires subtaintial compute or GPU resources talk with the Sciansa team in the first instance to see
    if your compute requirements can be accomdated by the platform.
- Inputs and Outputs: What are the expetations on the Inputs and Outputs for your tool?
  - Tools that can accomodate inputs and outputs in standardised formats and that can be written to take these inputs
    and outputs as parameters (rather then hard coded files) are easier to integrate.
- Extend This List: Thought that your tool would be easy to integrate based on the above list and then found it
                    harder then you expected?
  - Please reach out for help and support.
  - Please make sure this list is updated to reflect the additional constraints that made the integration more
    complex.


# Technologies

These are the technologies that you will need to use to integrate your tool into Sciansa:

The following matrix defines the technologies ... to integrate your tool. If you are starting from scratch it is
recommended that you use the default options. If you are integrating an existing tool the matrix highlights
compaitability.

Type                     | Technology | New Project  | Existing Compatability
-------------------------|------------|--------------|-------------------------
Language                 | Python     | Mandtory     | Mandatory
Library                  | Pydantic   | Madatory     | Mandatory
Test Framework           | Unknown    | Recommended  | TBA - TODO
Build System             | Make       | TODO Replace | TODO Replace
Dependency Managment     | Poetry     | Recommened   | Recommended but optional
Deployment               | Docker     | Mandatory    | Mandatory
Infrastructure Framework | IVCAP      | Mandatory    | Mandatory


If you are not familiar with IVCAP the best brief introduction can be found in the IVCAP section of the [Sciansa
Developer Documentation](https://github.com/csiro-internal/sciansa-integration#IVCAP).


TODO In Progress:
Should we do an active deployment first? Then work backwards testing locally and then updating....I think that could
work as a model. It's what I'd want to do if I were developing.


# Local Development / Testing.

- TODO: Explain local development and testing workflow.

# Remote Deployment

There are 2 options for remote deployment:

| | |
|---------------------------------|-------------------------------------------|
| Automated deployment (Prefered) | - Requirment: All code / models pushed to github repo. </br> - Runs an automated job to build and deploy the container. </br> Advantage: Reproducable |
| Manual deployment               | - Requirement: Developer must understand deployment process. - You manually build and upload your tool. |

## Automated Deployment

- TODO

## Manual Deployment

- TODO


-----

Old readme follows. To remove at some point in the future.

# IVCAP "AI Tool" Demo

> __Note:__ This is template repository to help you get started with building a new service for the IVCAP platform. If you are still unfamilar with
IVCAP, you may want to first checkout the [Gene Ontology (GO) Term Mapper](https://github.com/ivcap-works/gene-onology-term-mapper) tutorial.

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
curl -i -X POST \
    -H "content-type: application/json" \
    --data @tests/request.json \
    http://localhost:8078
HTTP/1.1 200 OK
date: Tue, 22 Jul 2025 06:32:39 GMT
server: uvicorn
job-id: urn:ivcap:job:1f066c5a-a3b4-6f84-a5f7-9eae9cc90b25
content-length: 67
content-type: application/json
ivcap-ai-tool-version: 0.7.15

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

> For a more in-depth description, please refer to [Step 8: Deploying to IVCAP](https://github.com/ivcap-works/gene-onology-term-mapper?tab=readme-ov-file#step-8-deploying-to-ivcap-) in the [Gene Ontology (GO) Term Mapper](https://github.com/ivcap-works/gene-onology-term-mapper) tutorial.

Deployment is a three step process:
1. Building and deploying the docker image
1. Registering the service
1. Registering the tool description

All this can be accomplished with a single command:

```
poetry ivcap deploy
```


### Test deployed Service

Run `poetry ivcap job-exec tests/request.json` to execute the service to check if '997' is a prime number (`{"number": 997}`):

```
% poetry ivcap job-exec tests/request.json
...
Creating job 'https://develop.ivcap.net/1/services2/urn:ivcap:service:3c51bd86-..../jobs'
{
  "$schema": "urn:sd:schema.is-prime.1",
  "is_prime": true,
  "number": 997
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